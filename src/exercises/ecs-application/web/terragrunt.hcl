include {
  path = find_in_parent_folders()
}

include "env" {
  path  = "${get_terragrunt_dir()}/../../env.hcl"
  expose = true
 }

dependency "vpc" {
  config_path = "${get_terragrunt_dir()}/../..//vpc"

  mock_outputs = {
    vpc_id                        = "vpc-test"
    private_subnets_ids           = [ "subnet-private-a", "subnet-private-b" ]
    public_subnets_ids            = [ "subnet-public-a", "subnet-public-b" ]
    private_subnets_cidr_blocks   = [ "10.1.2.0/24", "10.1.4.0/24" ]
    public_subnets_cidr_blocks    = [ "10.1.1.0/24", "10.1.3.0/24" ]
  }
}

dependency "rds" {
  config_path = "${get_terragrunt_dir()}/..//database"

  mock_outputs = {
    db_host = "db-host"
    db_name = "db-name"
    db_username = "db-username"
    db_password = "db-password"
  }
}

inputs = {
  vpc_id                      = dependency.vpc.outputs.vpc_id
  public_subnets              = dependency.vpc.outputs.public_subnets_ids
  default_domain_name         = "super-cool-domain.com"
  default_subdomain           = "awesome-app"
  db_host                     = dependency.rds.outputs.db_host  
  db_port                     = dependency.rds.outputs.db_port
  db_name                     = dependency.rds.outputs.db_name
  db_username                 = dependency.rds.outputs.db_username
  db_password                 = dependency.rds.outputs.db_password

}