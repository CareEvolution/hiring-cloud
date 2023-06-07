variable "deployment_long_name" {
  description = "The long name for the deployment (wheeling, tenantgroup, etc...)."
  type        = string
}

variable "deployment_short_name" {
  description = "The short name for the deployment (wh, tg, etc...)."
  type        = string
}

variable "deployment_role" {
  description = "The role for the deployment (qa, prod, staging, etc...)."
  type        = string
}

variable "vpc_cidr" {
  description = "The cidr for the VPC."
  type        = string
}

variable "infrastructure_dns_domain_name" {
  description = "The dns domain name for internal hosts."
  type        = string
}

variable "infrastructure_dns_server_ips" {
  description = "The list of ad DNS servers for the domain."
  type        = list(string)
}

variable "infrastructure_ntp_server_ips" {
  description = "The list of NTP servers for the vpc."
  type        = list(string)
}

variable "infrastructure_netbios_nameserver_ips" {
  description = "The list of netbios servers for the domain."
  type        = list(string)
}

variable "infrastructure_netbios_node_type" {
  description = "The node type of the netbios servers."
  type        = string
}