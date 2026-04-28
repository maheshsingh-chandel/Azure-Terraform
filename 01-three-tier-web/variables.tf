variable "location" {
  description = "Azure region."
  type        = string
  default     = "eastus"
}

variable "project_name" {
  description = "Resource name prefix."
  type        = string
  default     = "three-tier-web"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "prod"
}

variable "admin_username" {
  description = "VM administrator username."
  type        = string
  default     = "azureuser"
}

variable "db_admin_username" {
  description = "MySQL administrator username."
  type        = string
  default     = "mysqladmin"
}
