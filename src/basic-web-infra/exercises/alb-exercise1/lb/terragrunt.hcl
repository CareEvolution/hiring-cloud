include {
  path = find_in_parent_folders()
}

include "account" {
  path  = "${get_terragrunt_dir()}/../../../account.hcl"
  expose = true
 }

include "env" {
  path  = "${get_terragrunt_dir()}/../../env.hcl"
  expose = true
 }

dependencies {
  paths = [
    "${get_terragrunt_dir()}/../../vpc",
    "${get_terragrunt_dir()}/../web"
  ]
}

dependency "vpc" {
  config_path = "${get_terragrunt_dir()}/../../vpc"

  mock_outputs = {
    vpc_id                        = "vpc-test"
    private_subnets_ids           = [ "subnet-private-a", "subnet-private-b" ]
    public_subnets_ids            = [ "subnet-public-a", "subnet-public-b" ]
    private_subnets_cidr_blocks   = [ "10.1.2.0/24", "10.1.4.0/24" ]
    public_subnets_cidr_blocks    = [ "10.1.1.0/24", "10.1.3.0/24" ]
  }
}

dependency "web" {
  config_path = "${get_terragrunt_dir()}/../web"

  mock_outputs = {
    webserver_ids = ["i-12343459359", "i-94949494242424" ]
  }
}

terraform  {
  source = "${get_terragrunt_dir()}/../../../modules/lb//"
}

inputs = {
  deployment_long_name        = include.account.locals.deployment_long_name
  deployment_short_name       = include.account.locals.deployment_short_name
  deployment_role             = include.env.locals.deployment_role
  vpc_id                      = dependency.vpc.outputs.vpc_id
  loadbalancer_subnets        = dependency.vpc.outputs.public_subnets_ids

  default_domain_name         = "careevolution.dev"
  default_subdomain           = "alb-exercise1"
  target_instances            = dependency.web.outputs.webserver_ids
  target_security_group_id    = dependency.web.outputs.security_group_id
  target_port                 = "80"

  tags                        = include.env.locals.tags
}