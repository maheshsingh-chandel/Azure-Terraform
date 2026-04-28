variable "location" {
  description = "Azure region."
  type        = string
  default     = "eastus"
}

variable "project_name" {
  description = "Resource name prefix."
  type        = string
  default     = "microservices-aks"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "prod"
}
