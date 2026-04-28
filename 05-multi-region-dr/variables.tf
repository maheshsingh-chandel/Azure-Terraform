variable "primary_location" {
  description = "Primary Azure region."
  type        = string
  default     = "eastus"
}

variable "secondary_location" {
  description = "Secondary Azure region."
  type        = string
  default     = "westus2"
}

variable "project_name" {
  description = "Resource name prefix."
  type        = string
  default     = "multi-region-dr"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "prod"
}

variable "sql_admin_login" {
  description = "Azure SQL admin login."
  type        = string
  default     = "sqladminuser"
}
