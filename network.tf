resource "azurerm_virtual_network" "spoke1" {
  name                = "vnet-spoke1-prod"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
}

resource "azurerm_subnet" "backend" {
  name                 = "snet-backend-aks"
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.spoke1.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "db" {
  name                 = "snet-db"
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.spoke1.name
  address_prefixes     = ["10.0.2.0/24"]
}





# NSG DB settings
resource "azurerm_network_security_group" "db_nsg" {
  name     = "nsg-db-protection"
  location = data.azurerm_resource_group.main.location
  #resource_group_name = azurerm_resource_group.main.name
  resource_group_name = data.azurerm_resource_group.main.name

  security_rule {
    name                       = "AllowMSSQLFromAKS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = "10.0.1.0/24"
    destination_address_prefix = "*"
  }

  #security_rule {
  #  name                       = "DenyAllInbound"
  #  priority                   = 4096
  #  direction                  = "Inbound"
  #  access                     = "Deny"
  #  protocol                   = "*"
  #  source_port_range          = "*"
  #  destination_port_range     = "*"
  #  source_address_prefix      = "*"
  #  destination_address_prefix = "*"
  # }
}

resource "azurerm_subnet_network_security_group_association" "db_assoc" {
  subnet_id                 = azurerm_subnet.db.id
  network_security_group_id = azurerm_network_security_group.db_nsg.id
}






# NSG AKS Backend settings
resource "azurerm_network_security_group" "aks_nsg" {
  name                = "nsg-aks-backend"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  security_rule {
    name                       = "AllowVnetInBound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowAzureLoadBalancerInBound"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowNginxIngress"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443"]
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  #security_rule {
  #  name                       = "DenyAllInbound"
  #  priority                   = 4096
  #  direction                  = "Inbound"
  #  access                     = "Deny"
  #  protocol                   = "*"
  #  source_port_range          = "*"
  #  destination_port_range     = "*"
  #  source_address_prefix      = "*"
  #  destination_address_prefix = "*"
  #}
}

resource "azurerm_subnet_network_security_group_association" "backend_assoc" {
  subnet_id                 = azurerm_subnet.backend.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}
