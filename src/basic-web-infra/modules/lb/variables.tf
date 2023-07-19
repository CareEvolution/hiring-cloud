variable "deployment_long_name" {
  type        = string
  description = "The long name for the deployment."
}

variable "deployment_short_name" {
  type        = string
  description = "The short name for the deployment."
}

variable "deployment_role" {
  type        = string
  description = "The role for the deployment (Prod, Qa, Test, etc...)."
}

variable "vpc_id" {
  type        = string
  description = "The id of the vpc."
}

variable "loadbalancer_subnets" {
  type        = set(string)
  default     = null
  description = "The subnets for the loadbalancer"
}

variable "default_domain_name" {
    description = "Domain for the certificate and DNS entry. Do not include subdomain (eg, www.)"
    type        = string
}

variable "default_subdomain" {
    description = "Subdomain for the certificate and DNS entry."
    type        = string
    default     = null
}

variable "target_instances" {
    description = "The list of instances to forward to."
    type        = set(string)
    default     = null
}

variable "target_security_group_id" {
    description = "The security group to forward to."
    type        = string
    default     = null
}


variable "target_port" {
    description = "The target port to forward to (80, 443, etc...)"
    type        = string
    default     = "443"
}

variable "tags" {
  type        = map(any)
  description = "Custom tags to apply."
  default     = {}
}