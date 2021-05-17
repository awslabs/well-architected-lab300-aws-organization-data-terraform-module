variable "organisation_cron" {
  description = "interval of time to trigger lambda function"
  default     = "cron(0 6 ? * MON *)"
}

variable "function_prefix" {
  default = ""
}

variable "destination_bucket" {
  type        = string
  description = "Bucket the data will be placed into"
}

variable "account" {
  type = string
  default = "Linked"
  description = "if linked not needed if Management account put in Management"
}

variable "tags" {
  type        = string
  description = "List of tags from your Organisation you would like to include separated by a comma"
}

variable "management_account_id" {
  type        = string
  description = "Account id of your managment account so the lambda can assume role into managment"
}

variable "region" {
  type        = string
  description = "Region you are deploying in"
  default     = "eu-west-1"
}

variable "cur_database" {
  default = "managementcur"
}

variable "memory_size" {
  default = "512"
}

variable "timeout" {
  default = "150"
}