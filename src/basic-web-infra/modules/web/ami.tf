data "aws_caller_identity" "public_infrastructure" {
  provider = aws.public_infrastructure
}

data "aws_ami" "server_ami" {
  most_recent = true
  owners      = [data.aws_caller_identity.public_infrastructure.account_id]
  filter {
    name   = "name"
    values = ["CE_Windows_Server-2022-Full-Base*"]
  }
}