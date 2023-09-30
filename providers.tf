terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.75.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.43.0"
    }
  }
}


provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
}

# Configure the Azure Active Directory Provider
provider "azuread" {
  tenant_id       = var.azure_tenant_id
}
