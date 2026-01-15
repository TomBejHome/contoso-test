terraform {
  required_version = ">= 1.0"
}

data "azurerm_resource_group" "main" {
  # KodeKloud RG - fill on variables
  name = var.resource_group_name
}
