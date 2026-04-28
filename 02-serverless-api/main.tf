locals {
  name         = "${var.project_name}-${var.environment}"
  compact_name = substr(replace(local.name, "-", ""), 0, 20)
  tags = {
    project     = var.project_name
    environment = var.environment
    managed_by  = "terraform"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${local.name}"
  location = var.location
  tags     = local.tags
}

resource "azurerm_storage_account" "function" {
  name                     = "${local.compact_name}${random_id.suffix.hex}"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "ZRS"
  min_tls_version          = "TLS1_2"
  tags                     = local.tags
}

resource "azurerm_service_plan" "this" {
  name                = "asp-${local.name}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  os_type             = "Linux"
  sku_name            = "Y1"
  tags                = local.tags
}

resource "azurerm_application_insights" "this" {
  name                = "appi-${local.name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  application_type    = "web"
  tags                = local.tags
}

resource "azurerm_cosmosdb_account" "this" {
  name                = "cosmos-${local.name}-${random_id.suffix.hex}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  tags                = local.tags

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.this.location
    failover_priority = 0
  }

  capabilities {
    name = "EnableServerless"
  }
}

resource "azurerm_cosmosdb_sql_database" "this" {
  name                = "appdb"
  resource_group_name = azurerm_resource_group.this.name
  account_name        = azurerm_cosmosdb_account.this.name
}

resource "azurerm_cosmosdb_sql_container" "items" {
  name                  = "items"
  resource_group_name   = azurerm_resource_group.this.name
  account_name          = azurerm_cosmosdb_account.this.name
  database_name         = azurerm_cosmosdb_sql_database.this.name
  partition_key_path    = "/pk"
  partition_key_version = 2
}

data "archive_file" "function" {
  type        = "zip"
  source_dir  = "${path.module}/function"
  output_path = "${path.module}/build/function.zip"
}

resource "azurerm_storage_container" "packages" {
  name                  = "packages"
  storage_account_name  = azurerm_storage_account.function.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "function" {
  name                   = "function-${data.archive_file.function.output_md5}.zip"
  storage_account_name   = azurerm_storage_account.function.name
  storage_container_name = azurerm_storage_container.packages.name
  type                   = "Block"
  source                 = data.archive_file.function.output_path
}

data "azurerm_storage_account_blob_container_sas" "package" {
  connection_string = azurerm_storage_account.function.primary_connection_string
  container_name    = azurerm_storage_container.packages.name
  https_only        = true
  start             = "2026-01-01T00:00:00Z"
  expiry            = "2036-01-01T00:00:00Z"

  permissions {
    read   = true
    add    = false
    create = false
    write  = false
    delete = false
    list   = false
  }
}

resource "azurerm_linux_function_app" "api" {
  name                       = "func-${local.name}-${random_id.suffix.hex}"
  resource_group_name        = azurerm_resource_group.this.name
  location                   = azurerm_resource_group.this.location
  service_plan_id            = azurerm_service_plan.this.id
  storage_account_name       = azurerm_storage_account.function.name
  storage_account_access_key = azurerm_storage_account.function.primary_access_key
  https_only                 = true
  tags                       = local.tags

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      node_version = "20"
    }

    application_insights_connection_string = azurerm_application_insights.this.connection_string
  }

  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE = "https://${azurerm_storage_account.function.name}.blob.core.windows.net/${azurerm_storage_container.packages.name}/${azurerm_storage_blob.function.name}${data.azurerm_storage_account_blob_container_sas.package.sas}"
    COSMOS_ENDPOINT          = azurerm_cosmosdb_account.this.endpoint
    COSMOS_KEY               = azurerm_cosmosdb_account.this.primary_key
    COSMOS_DATABASE          = azurerm_cosmosdb_sql_database.this.name
    COSMOS_CONTAINER         = azurerm_cosmosdb_sql_container.items.name
  }
}

resource "azurerm_api_management" "this" {
  name                = "apim-${local.name}-${random_id.suffix.hex}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  sku_name            = "Consumption_0"
  tags                = local.tags
}

resource "azurerm_api_management_api" "this" {
  name                = "items"
  resource_group_name = azurerm_resource_group.this.name
  api_management_name = azurerm_api_management.this.name
  revision            = "1"
  display_name        = "Items API"
  path                = "items"
  protocols           = ["https"]
  service_url         = "https://${azurerm_linux_function_app.api.default_hostname}/api"
}
