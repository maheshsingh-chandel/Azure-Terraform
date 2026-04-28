locals {
  name         = "${var.project_name}-${var.environment}"
  compact_name = substr(replace(local.name, "-", ""), 0, 16)
  tags = {
    project     = var.project_name
    environment = var.environment
    managed_by  = "terraform"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "random_password" "vm" {
  length  = 24
  special = true
}

resource "random_password" "sql" {
  length  = 24
  special = true
}

resource "azurerm_resource_group" "primary" {
  name     = "rg-${local.name}-primary"
  location = var.primary_location
  tags     = local.tags
}

resource "azurerm_resource_group" "secondary" {
  name     = "rg-${local.name}-secondary"
  location = var.secondary_location
  tags     = local.tags
}

resource "azurerm_public_ip" "primary" {
  name                = "pip-${local.name}-primary"
  resource_group_name = azurerm_resource_group.primary.name
  location            = azurerm_resource_group.primary.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_public_ip" "secondary" {
  name                = "pip-${local.name}-secondary"
  resource_group_name = azurerm_resource_group.secondary.name
  location            = azurerm_resource_group.secondary.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_traffic_manager_profile" "this" {
  name                   = "tm-${local.name}"
  resource_group_name    = azurerm_resource_group.primary.name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "tm-${local.name}-${random_id.suffix.hex}"
    ttl           = 30
  }

  monitor_config {
    protocol = "HTTP"
    port     = 80
    path     = "/"
  }

  tags = local.tags
}

resource "azurerm_traffic_manager_azure_endpoint" "primary" {
  name               = "primary"
  profile_id         = azurerm_traffic_manager_profile.this.id
  target_resource_id = azurerm_public_ip.primary.id
  priority           = 1
}

resource "azurerm_traffic_manager_azure_endpoint" "secondary" {
  name               = "secondary"
  profile_id         = azurerm_traffic_manager_profile.this.id
  target_resource_id = azurerm_public_ip.secondary.id
  priority           = 2
}

resource "azurerm_virtual_network" "primary" {
  name                = "vnet-${local.name}-primary"
  resource_group_name = azurerm_resource_group.primary.name
  location            = azurerm_resource_group.primary.location
  address_space       = ["10.50.0.0/16"]
  tags                = local.tags
}

resource "azurerm_virtual_network" "secondary" {
  name                = "vnet-${local.name}-secondary"
  resource_group_name = azurerm_resource_group.secondary.name
  location            = azurerm_resource_group.secondary.location
  address_space       = ["10.60.0.0/16"]
  tags                = local.tags
}

resource "azurerm_subnet" "primary" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.primary.name
  virtual_network_name = azurerm_virtual_network.primary.name
  address_prefixes     = ["10.50.1.0/24"]
}

resource "azurerm_subnet" "secondary" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.secondary.name
  virtual_network_name = azurerm_virtual_network.secondary.name
  address_prefixes     = ["10.60.1.0/24"]
}

resource "azurerm_lb" "primary" {
  name                = "lb-${local.name}-primary"
  resource_group_name = azurerm_resource_group.primary.name
  location            = azurerm_resource_group.primary.location
  sku                 = "Standard"
  tags                = local.tags

  frontend_ip_configuration {
    name                 = "public"
    public_ip_address_id = azurerm_public_ip.primary.id
  }
}

resource "azurerm_lb" "secondary" {
  name                = "lb-${local.name}-secondary"
  resource_group_name = azurerm_resource_group.secondary.name
  location            = azurerm_resource_group.secondary.location
  sku                 = "Standard"
  tags                = local.tags

  frontend_ip_configuration {
    name                 = "public"
    public_ip_address_id = azurerm_public_ip.secondary.id
  }
}

resource "azurerm_lb_backend_address_pool" "primary" {
  name            = "backend"
  loadbalancer_id = azurerm_lb.primary.id
}

resource "azurerm_lb_backend_address_pool" "secondary" {
  name            = "backend"
  loadbalancer_id = azurerm_lb.secondary.id
}

resource "azurerm_lb_probe" "primary" {
  name            = "http"
  loadbalancer_id = azurerm_lb.primary.id
  protocol        = "Http"
  request_path    = "/"
  port            = 80
}

resource "azurerm_lb_probe" "secondary" {
  name            = "http"
  loadbalancer_id = azurerm_lb.secondary.id
  protocol        = "Http"
  request_path    = "/"
  port            = 80
}

resource "azurerm_lb_rule" "primary" {
  name                           = "http"
  loadbalancer_id                = azurerm_lb.primary.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "public"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.primary.id]
  probe_id                       = azurerm_lb_probe.primary.id
}

resource "azurerm_lb_rule" "secondary" {
  name                           = "http"
  loadbalancer_id                = azurerm_lb.secondary.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "public"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.secondary.id]
  probe_id                       = azurerm_lb_probe.secondary.id
}

resource "azurerm_linux_virtual_machine_scale_set" "primary" {
  name                            = "vmss-${local.name}-primary"
  resource_group_name             = azurerm_resource_group.primary.name
  location                        = azurerm_resource_group.primary.location
  sku                             = "Standard_B2s"
  instances                       = 2
  admin_username                  = "azureuser"
  admin_password                  = random_password.vm.result
  disable_password_authentication = false
  tags                            = local.tags

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  network_interface {
    name    = "nic"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.primary.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.primary.id]
    }
  }

  custom_data = base64encode(templatefile("${path.module}/cloud-init.yaml", {
    region = var.primary_location
    role   = "primary"
  }))
}

resource "azurerm_linux_virtual_machine_scale_set" "secondary" {
  name                            = "vmss-${local.name}-secondary"
  resource_group_name             = azurerm_resource_group.secondary.name
  location                        = azurerm_resource_group.secondary.location
  sku                             = "Standard_B2s"
  instances                       = 1
  admin_username                  = "azureuser"
  admin_password                  = random_password.vm.result
  disable_password_authentication = false
  tags                            = local.tags

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  network_interface {
    name    = "nic"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.secondary.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.secondary.id]
    }
  }

  custom_data = base64encode(templatefile("${path.module}/cloud-init.yaml", {
    region = var.secondary_location
    role   = "standby"
  }))
}

resource "azurerm_mssql_server" "primary" {
  name                         = "sql-${local.name}-primary-${random_id.suffix.hex}"
  resource_group_name          = azurerm_resource_group.primary.name
  location                     = azurerm_resource_group.primary.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = random_password.sql.result
  minimum_tls_version          = "1.2"
  tags                         = local.tags
}

resource "azurerm_mssql_server" "secondary" {
  name                         = "sql-${local.name}-secondary-${random_id.suffix.hex}"
  resource_group_name          = azurerm_resource_group.secondary.name
  location                     = azurerm_resource_group.secondary.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = random_password.sql.result
  minimum_tls_version          = "1.2"
  tags                         = local.tags
}

resource "azurerm_mssql_database" "app" {
  name      = "appdb"
  server_id = azurerm_mssql_server.primary.id
  sku_name  = "S1"
  tags      = local.tags
}

resource "azurerm_mssql_failover_group" "this" {
  name      = "fog-${local.name}"
  server_id = azurerm_mssql_server.primary.id
  databases = [azurerm_mssql_database.app.id]

  partner_server {
    id = azurerm_mssql_server.secondary.id
  }

  read_write_endpoint_failover_policy {
    mode          = "Automatic"
    grace_minutes = 60
  }
}

resource "azurerm_storage_account" "dr" {
  name                     = "st${local.compact_name}${random_id.suffix.hex}"
  resource_group_name      = azurerm_resource_group.primary.name
  location                 = azurerm_resource_group.primary.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  min_tls_version          = "TLS1_2"
  tags                     = local.tags
}
