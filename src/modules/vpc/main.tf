data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.0"

  name = var.deployment_short_name
  cidr = var.vpc_cidr

  azs = [
    data.aws_availability_zones.available.names[0],
    data.aws_availability_zones.available.names[1]
  ]

  public_subnets = [
    cidrsubnet(var.vpc_cidr, 8, 1),
    cidrsubnet(var.vpc_cidr, 8, 3),
  ]

  private_subnets = [
    cidrsubnet(var.vpc_cidr, 8, 2),
    cidrsubnet(var.vpc_cidr, 8, 4)
  ]

  enable_nat_gateway  = true
  enable_vpn_gateway  = true
  enable_s3_endpoint  = true
  enable_dhcp_options = true

  enable_dns_hostnames = true
  enable_dns_support   = true


  public_subnet_suffix = "public"
  public_subnet_tags = {
    "Name"    = "${var.deployment_long_name} public (${var.deployment_role})"
    "Purpose" = var.deployment_role
  }
  public_route_table_tags = {
    "Name"    = "${var.deployment_long_name} public (${var.deployment_role})"
    "Purpose" = var.deployment_role
  }

  private_subnet_suffix = "private"
  private_subnet_tags = {
    "Name"    = "${var.deployment_long_name} private (${var.deployment_role})"
    "Purpose" = var.deployment_role
  }
  private_route_table_tags = {
    "Name"    = "${var.deployment_long_name} private (${var.deployment_role})"
    "Purpose" = var.deployment_role
  }

  manage_default_security_group  = true
  default_security_group_name    = "default"
  default_security_group_ingress = []
  default_security_group_egress  = []
  default_security_group_tags    = { "Name" = "default (No Access)" }

  tags = {
    "Name"    = "${var.deployment_long_name} (${var.deployment_role})"
    "Purpose" = var.deployment_role
  }
}

