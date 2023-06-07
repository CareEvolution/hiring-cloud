include {
  path = find_in_parent_folders()
}

include "env" {
  path  = "${get_terragrunt_dir()}/../../env.hcl"
  expose = true
 }

dependency "vpc" {
  config_path = "${get_terragrunt_dir()}/../../../exercises//vpc"

  mock_outputs = {
    vpc_id                        = "vpc-test"
    private_subnets_ids           = [ "subnet-private-a", "subnet-private-b" ]
    public_subnets_ids            = [ "subnet-public-a", "subnet-public-b" ]
    private_subnets_cidr_blocks   = [ "10.1.2.0/24", "10.1.4.0/24" ]
    public_subnets_cidr_blocks    = [ "10.1.1.0/24", "10.1.3.0/24" ]
  }
}

inputs = {
  vpc_id      = dependency.vpc.outputs.vpc_id
  db_subnets  = dependency.vpc.outputs.public_subnets_ids
}