variable "vpc_id" {
  type        = string
  description = "The id of the vpc."
}
variable "db_subnets" {
  type        = set(string)
  default     = null
  description = "The subnets for the database"
}
