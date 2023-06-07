variable "vpc_id" {
  type        = string
  description = "The id of the vpc."
}

variable "public_subnets" {
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


variable "db_host" {
  description = "The hostname of the database"
  type        = string
  default     = null
}

variable "db_name" {
  description = "The name of the database"
  type        = string
  default     = null
}

variable "db_username" {
  description = "The username of the database"
  type        = string
  default     = null
}

variable "db_port" {
  description = "The port of the database"
  type        = number
  default     = null
}

variable "db_password" {
  description = "The password of the database"
  type        = string
  default     = null
}
