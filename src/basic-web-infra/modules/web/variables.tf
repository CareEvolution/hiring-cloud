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

variable "vpc_cidr_block" {
  type        = string
  description = "The CIDR block of the vpc."
}

variable "instance_subnet_id" {
  type        = string
  description = "The subnet ids for the web EC2 instances."
}

variable "instance_type" {
  type        = string
  default     = "m5.2xlarge"
  description = "The size of the instance."
}

variable "suffixes" {
  type        = set(string)
  default     = ["01A"]
  description = "List of suffixes to append to each unique instance. 01A, 01B, 02A, etc...."
}

variable "keypair_name" {
  type        = string
  description = "The name of the EC2 key pair used to decrypt the administrator password."
}

variable "additional_security_groups" {
  type        = list(string)
  default     = []
  description = "Other security groups to attach to the instances."
}

variable "allow_remote_access" {
  type        = bool
  description = "Enables or disables external remote access."
}

variable "remote_access_cidrs" {
  type        = list(string)
  description = "List of CIDRS for external remote access (WMI, etc...)."
}

variable "patch_group" {
  type        = string
  description = "Patch group for the instance"
}

variable "tags" {
  type        = map(any)
  description = "Custom tags to apply."
  default     = {}
}

variable "root_block_device_tags" {
  type        = map(any)
  description = "Custom tags to apply strictly to the root block device."
  default     = {}
}