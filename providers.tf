terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  # backend "azurerm" {} 
}

provider "azurerm" {
  features {}
  # subscription_id = var.subscription_id
  # tenant_id       = var.tenant_id

  skip_provider_registration = true
}

