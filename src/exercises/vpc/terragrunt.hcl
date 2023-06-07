include {
  path = find_in_parent_folders()
}

include "account" {
  path  = "${get_terragrunt_dir()}/../../account.hcl"
  expose = true
 }

include "env" {
  path  = "${get_terragrunt_dir()}/../env.hcl"
  expose = true
 }

dependency "infrastructure" {
  config_path = "${get_terragrunt_dir()}/some/dep/in/larger/project"
}

terraform {
  source = "${get_terragrunt_dir()}/../modules/vpc/"
}

inputs = {
  deployment_long_name                  = include.account.locals.deployment_long_name
  deployment_short_name                 = include.account.locals.deployment_short_name
  deployment_role                       = include.env.locals.deployment_role

  vpc_cidr                              = include.env.locals.vpc_cidr
  infrastructure_dns_domain_name        = dependency.infrastructure.outputs.dns_domain_name
  infrastructure_dns_server_ips         = dependency.infrastructure.outputs.dns_server_ips
  infrastructure_ntp_server_ips         = dependency.infrastructure.outputs.ntp_server_ips
  infrastructure_netbios_nameserver_ips = dependency.infrastructure.outputs.netbios_name_server_ips
  infrastructure_netbios_node_type      = dependency.infrastructure.outputs.netbios_node_type
}