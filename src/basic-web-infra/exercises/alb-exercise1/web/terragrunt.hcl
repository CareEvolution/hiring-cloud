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
    "${get_terragrunt_dir()}/../../vpc"
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
terraform  {
  source = "${get_terragrunt_dir()}/../../../modules/web//"
}

inputs = {
  deployment_long_name  = include.account.locals.deployment_long_name
  deployment_short_name = include.account.locals.deployment_short_name
  deployment_role       = include.env.locals.deployment_role

  vpc_id                = dependency.vpc.outputs.vpc_id
  vpc_cidr_block        = include.env.locals.vpc_cidr
  instance_subnet_id    = dependency.vpc.outputs.public_subnets_ids[0]
  suffixes              = [ "01A", "02A" ]
  instance_type         = "t3.medium"
  keypair_name          = "${include.account.locals.deployment_long_name}-${include.env.locals.deployment_role}"
  tags                  = include.env.locals.tags
  patch_group           = "Windows Automatic Reboot"

  allow_remote_access   = include.env.locals.allow_remote_access
  remote_access_cidrs   = include.env.locals.remote_access_cidrs
}