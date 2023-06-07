data "aws_caller_identity" "current" {}
data "aws_elb_service_account" "main" {}

resource "aws_security_group" "loadbalancer" {
  vpc_id = var.vpc_id

  tags = merge(var.tags, {
    Name        = "LoadBalancer (${var.deployment_role})"
    Description = "LoadBalancer security group (${var.deployment_role})"
  })
}

resource "aws_security_group_rule" "https" {
  security_group_id = aws_security_group.loadbalancer.id
  type              = "ingress"
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  to_port           = 443
  description       = "Allows open access to https"
}

resource "aws_security_group_rule" "http" {
  security_group_id = aws_security_group.loadbalancer.id
  type              = "ingress"
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  to_port           = 80
  description       = "Allows open access to https"
}

resource "aws_security_group_rule" "outbound" {
  security_group_id = aws_security_group.loadbalancer.id
  type                      = "egress"
  protocol                  = "-1"
  from_port                 = 80
  to_port                   = 80
  source_security_group_id  = var.target_security_group_id
  description               = "Allows egress to the instances sg."
}

resource "aws_lb" "loadbalancer" {
  name                       = "${var.deployment_short_name}-${var.deployment_role}"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [
    aws_security_group.loadbalancer.id
  ]

  enable_deletion_protection = false
  drop_invalid_header_fields = true

  subnets = var.loadbalancer_subnets

  access_logs {
    bucket  = aws_s3_bucket.logging_bucket.bucket
    enabled = true
  }

  tags = merge(var.tags, {
    Owner       = var.deployment_long_name
    Purpose     = "LB"
    Deployment  = upper(var.deployment_short_name)
    Environment = upper(var.deployment_role)
  })
}

resource "aws_wafv2_web_acl_association" "web_acl" {
  resource_arn = aws_lb.loadbalancer.arn
  web_acl_arn  = aws_wafv2_web_acl.waf_acl.arn
}

resource "aws_lb_target_group" "targetgroup" {
  name        = var.default_subdomain
  port        = var.target_port
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id
  slow_start  = 300

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 90
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 60
    unhealthy_threshold = 2
  }

  stickiness {
    cookie_duration = 28800
    enabled         = true
    type            = "lb_cookie"
  }
}

resource "aws_lb_target_group_attachment" "targetgroup" {
  for_each         = var.target_instances
  target_group_arn = aws_lb_target_group.targetgroup.arn
  target_id        = each.value
  port             = var.target_port
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.loadbalancer.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
  certificate_arn   = aws_acm_certificate.certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.targetgroup.arn
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.loadbalancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
