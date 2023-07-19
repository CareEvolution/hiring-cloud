
locals {
  deployment_role       = "exercises"
  vpc_cidr              = "10.45.0.0/16"

  allow_remote_access   = false
  remote_access_cidrs = [
  ]

  terragrunt_tags = {
    created_by        = "terraform"
    terraform_path    = "/${lower(path_relative_to_include())}"
  }

  tags = {
    ce_resource_path = "/HIRING/EXERCISES"
    created_by       = "terraform",
    project          = "exercises"
    cost_center      = "hiring"
  }
}