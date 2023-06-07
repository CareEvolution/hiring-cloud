output "security_group_id" {
  value = aws_security_group.webserver.id
}

output "instance_role_name" {
  value = aws_iam_role.webserver.name
}

output "webserver_ids" {
  value = values(aws_instance.webserver)[*].id
}