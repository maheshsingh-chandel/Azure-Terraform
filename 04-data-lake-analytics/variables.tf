variable "location" {
  description = "Azure region."
  type        = string
  default     = "eastus"
}

variable "project_name" {
  description = "Resource name prefix."
  type        = string
  default     = "data-lake-analytics"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "prod"
}

variable "sql_admin_login" {
  description = "Synapse SQL administrator login."
  type        = string
  default     = "sqladminuser"
}
