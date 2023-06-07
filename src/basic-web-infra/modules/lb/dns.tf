
resource "aws_route53_record" "loadbalancer_A" {
  provider = aws.public_infrastructure
  zone_id  = data.aws_route53_zone.certificate.zone_id
  name     = var.default_subdomain
  type     = "A"

  alias {
    name                   = aws_lb.loadbalancer.dns_name
    zone_id                = aws_lb.loadbalancer.zone_id
    evaluate_target_health = true
  }
}
