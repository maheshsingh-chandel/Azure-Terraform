variable "location" {
  description = "Azure region."
  type        = string
  default     = "eastus"
}

variable "project_name" {
  description = "Resource name prefix."
  type        = string
  default     = "serverless-api"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "prod"
}

variable "publisher_name" {
  description = "API Management publisher name."
  type        = string
  default     = "Platform Team"
}

variable "publisher_email" {
  description = "API Management publisher email."
  type        = string
  default     = "platform@example.com"
}
