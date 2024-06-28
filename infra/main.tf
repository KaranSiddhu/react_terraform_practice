terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

# Resource group
resource "azurerm_resource_group" "rg" {
  name     = "testing_resource_name"
  location = "eastus"
}

# Storage account
# Name needs to be globally unique
resource "azurerm_storage_account" "sa" {
  name                     = "testingstorageaccount12"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Storage container
resource "azurerm_storage_container" "sc" {
  name                  = "web-app-react"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

# Service plan
resource "azurerm_app_service_plan" "asp" {
  name                = "test_app_service_plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku {
    tier = "Free"
    size = "F1"
  }
}

# Service
# Name needs to be globally unique
resource "azurerm_app_service" "app" {
  name                = "6a072510-2597-4518-86a7-e542d84889e0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.asp.id

  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE = "https://${azurerm_storage_account.sa.primary_blob_endpoint}${azurerm_storage_container.sc.name}/app.zip${azurerm_storage_account.sa.primary_access_key}"
  }
}
