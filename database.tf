resource "azurerm_private_dns_zone" "mssql" {
  name                = "privatelink.database.windows.net"
  resource_group_name = data.azurerm_resource_group.main.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "mssql" {
  name                  = "mssql-vnet-link"
  resource_group_name   = data.azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.mssql.name
  virtual_network_id    = azurerm_virtual_network.spoke1.id
}

resource "azurerm_mssql_server" "main" {
  name                          = "sql-contoso-db-server"
  resource_group_name           = data.azurerm_resource_group.main.name
  location                      = data.azurerm_resource_group.main.location
  version                       = "12.0"
  administrator_login           = var.db_admin_username
  administrator_login_password  = var.db_admin_password
  public_network_access_enabled = false
}

resource "azurerm_mssql_database" "argocd" {
  name                 = "sql-argocd-db"
  server_id            = azurerm_mssql_server.main.id
  sku_name             = var.db_sku_name
  max_size_gb          = 2
  storage_account_type = "Local"
}

resource "azurerm_private_endpoint" "mssql" {
  name                = "pe-sql"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  subnet_id           = azurerm_subnet.db.id

  private_service_connection {
    name                           = "psc-sql"
    private_connection_resource_id = azurerm_mssql_server.main.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "mssql-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.mssql.id]
  }
}
