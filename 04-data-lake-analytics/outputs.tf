output "storage_account_name" {
  description = "ADLS Gen2 storage account."
  value       = azurerm_storage_account.lake.name
}

output "raw_filesystem" {
  description = "Raw data filesystem."
  value       = azurerm_storage_data_lake_gen2_filesystem.raw.name
}

output "eventhub_name" {
  description = "Event Hub for ingestion."
  value       = azurerm_eventhub.events.name
}

output "data_factory_name" {
  description = "Data Factory name."
  value       = azurerm_data_factory.this.name
}

output "synapse_workspace_name" {
  description = "Synapse workspace name."
  value       = azurerm_synapse_workspace.this.name
}
