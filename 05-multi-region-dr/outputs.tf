output "traffic_manager_fqdn" {
  description = "Traffic Manager FQDN."
  value       = azurerm_traffic_manager_profile.this.fqdn
}

output "primary_public_ip" {
  description = "Primary load balancer public IP."
  value       = azurerm_public_ip.primary.ip_address
}

output "secondary_public_ip" {
  description = "Secondary load balancer public IP."
  value       = azurerm_public_ip.secondary.ip_address
}

output "sql_failover_group_listener" {
  description = "Azure SQL failover group listener endpoint."
  value       = "${azurerm_mssql_failover_group.this.name}.database.windows.net"
}

output "storage_account_name" {
  description = "GRS storage account."
  value       = azurerm_storage_account.dr.name
}
