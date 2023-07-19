data "aws_caller_identity" "current" {}

locals {
  ce_identifier = toset([for suffix in var.suffixes : "${upper(var.deployment_short_name)}-${upper(substr(var.deployment_role, 0, 4))}-WB-${upper(suffix)}"])
}

resource "aws_iam_role" "webserver" {
  name = "${var.deployment_short_name}_${var.deployment_role}_WebRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "webserver" {
  name = "${var.deployment_short_name}${title(var.deployment_role)}WebProfile"
  role = aws_iam_role.webserver.name
}

resource "aws_iam_role_policy_attachment" "webserver_ssm" {
  role       = aws_iam_role.webserver.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "webserver_automation" {
  role       = aws_iam_role.webserver.name
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/AllowAutomationAccess"
}

resource "aws_security_group" "webserver" {
  vpc_id = var.vpc_id

  tags = merge(var.tags, {
    Name        = "Webserver (${var.deployment_role})"
    Description = "Webserver security group (${var.deployment_role})"
  })
}

resource "aws_security_group_rule" "http" {
  security_group_id = aws_security_group.webserver.id
  type              = "ingress"
  protocol          = "TCP"
  cidr_blocks       = [var.vpc_cidr_block]
  from_port         = 80
  to_port           = 80
  description       = "Allows internal access to http"
}

resource "aws_security_group_rule" "https" {
  security_group_id = aws_security_group.webserver.id
  type              = "ingress"
  protocol          = "TCP"
  cidr_blocks       = [var.vpc_cidr_block]
  from_port         = 443
  to_port           = 443
  description       = "Allows internal access to https"
}

resource "aws_security_group_rule" "egress" {
  security_group_id = aws_security_group.webserver.id
  type              = "egress"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  description       = "Allows outbound traffic"
}

resource "aws_instance" "webserver" {
  for_each      = local.ce_identifier
  instance_type = var.instance_type
  ami           = data.aws_ami.server_ami.id
  key_name      = aws_key_pair.this.key_name
  subnet_id     = var.instance_subnet_id
  vpc_security_group_ids = concat(
    var.additional_security_groups,
    [aws_security_group.webserver.id]
  )

  disable_api_termination     = true
  iam_instance_profile        = aws_iam_instance_profile.webserver.name
  ebs_optimized               = true
  monitoring                  = true
  associate_public_ip_address = false

  lifecycle {
    ignore_changes = [ami]
  }

  tags = merge(var.tags, {
    Name          = each.value
    Owner         = var.deployment_long_name
    Purpose       = "Web"
    Deployment    = upper(var.deployment_short_name)
    Environment   = upper(var.deployment_role)
    "Patch Group" = var.patch_group
    Hostname      = each.value
    "Tenable"     = "FA"
  })

  root_block_device {
    volume_size           = 1024
    delete_on_termination = true
    tags = merge(
      { "Name" = "${each.value} C:" },
      var.tags,
      var.root_block_device_tags
    )
  }
}
