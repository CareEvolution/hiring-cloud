resource "aws_efs_file_system" "data" {
  creation_token  = "data"
  encrypted       = false
  throughput_mode = "elastic"
}

resource "aws_efs_mount_target" "mount_target" {
  for_each        = var.public_subnets
  file_system_id  = aws_efs_file_system.data.id
  subnet_id       = each.value
  security_groups = [aws_security_group.open_access.id]
}
