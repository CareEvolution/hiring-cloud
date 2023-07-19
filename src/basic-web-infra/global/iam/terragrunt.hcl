include {
  path = find_in_parent_folders()
}

locals {
  terragrunt_tags = {
    created_by        = "terraform"
    terraform_path    = "/${lower(path_relative_to_include())}"
  }
}