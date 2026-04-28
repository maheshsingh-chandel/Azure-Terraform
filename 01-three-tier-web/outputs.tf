output "application_gateway_ip" {
  description = "Application Gateway public IP."
  value       = azurerm_public_ip.app_gateway.ip_address
}

output "mysql_fqdn" {
  description = "Azure Database for MySQL FQDN."
  value       = azurerm_mysql_flexible_server.this.fqdn
}

output "redis_hostname" {
  description = "Azure Cache for Redis hostname."
  value       = azurerm_redis_cache.this.hostname
}
