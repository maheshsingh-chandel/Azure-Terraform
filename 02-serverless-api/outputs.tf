output "api_management_gateway_url" {
  description = "API Management gateway URL."
  value       = azurerm_api_management.this.gateway_url
}

output "function_hostname" {
  description = "Function App hostname."
  value       = azurerm_linux_function_app.api.default_hostname
}

output "cosmos_endpoint" {
  description = "Cosmos DB endpoint."
  value       = azurerm_cosmosdb_account.this.endpoint
}
