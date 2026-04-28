package terraform.guardrails

deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "azurerm_storage_account"
  resource.change.after.min_tls_version != "TLS1_2"
  msg := sprintf("Storage account must enforce TLS 1.2: %s", [resource.address])
}

deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "azurerm_mssql_server"
  resource.change.after.minimum_tls_version != "1.2"
  msg := sprintf("SQL server must enforce TLS 1.2: %s", [resource.address])
}

deny[msg] {
  resource := input.resource_changes[_]
  tags := object.get(resource.change.after, "tags", {})
  not tags["environment"]
  msg := sprintf("Resource is missing environment tag: %s", [resource.address])
}
