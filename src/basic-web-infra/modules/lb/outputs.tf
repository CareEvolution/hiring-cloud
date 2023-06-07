output "arn" {
  value = aws_lb.loadbalancer.arn
}

output "dns_name" {
  value = aws_lb.loadbalancer.dns_name
}

output "zone_id" {
  value = aws_lb.loadbalancer.zone_id
}

output "https_listener_arn" {
  value = aws_lb_listener.https.arn
}

output "targetgroup_arn" {
  value = aws_lb_target_group.targetgroup.arn
}