output "aks_cluster_name" {
  description = "AKS cluster name."
  value       = azurerm_kubernetes_cluster.this.name
}

output "acr_login_server" {
  description = "Azure Container Registry login server."
  value       = azurerm_container_registry.this.login_server
}

output "service_bus_topic" {
  description = "Service Bus domain events topic."
  value       = azurerm_servicebus_topic.events.name
}

output "service_databases" {
  description = "Cosmos DB database per service."
  value       = { for name, db in azurerm_cosmosdb_sql_database.service : name => db.name }
}
