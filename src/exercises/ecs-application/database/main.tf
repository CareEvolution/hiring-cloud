resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "aws_security_group" "database_security_group" {
  name        = "database_security_group"
  description = "Allow database access"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow database access"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow database access"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "public"
  subnet_ids = var.db_subnets
}

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier           = "gitea"
  engine               = "mysql"
  major_engine_version = "8.0"
  family               = "mysql8.0"
  instance_class       = "db.t2.micro"
  storage_encrypted    = false
  allocated_storage    = 5
  publicly_accessible  = true

  db_name  = "gitea"
  username = "gitea"
  port     = 3306
  password = random_password.db_password.result

  subnet_ids           = var.db_subnets
  db_subnet_group_name = aws_db_subnet_group.default.name
  vpc_security_group_ids = [
    aws_security_group.database_security_group.id
  ]

}

output "db_host" {
  value = module.db.db_instance_address
}

output "db_name" {
  value = module.db.db_instance_name
}

output "db_username" {
  value     = module.db.db_instance_username
  sensitive = true
}

output "db_port" {
  value = module.db.db_instance_port
}

output "db_password" {
  value     = module.db.db_instance_password
  sensitive = true
}
