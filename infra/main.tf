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

resource "azurerm_resource_group" "example" {
  name     = "example-resources1"
  location = "West Europe"
}

# Name should be globally unique
resource "azurerm_storage_account" "example" {
  name                     = "1ba3b78b562048ecb07ass"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "example" {
  name                  = "$web"
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "blob"
}

resource "azurerm_storage_blob" "example" {
  name                   = "index.html"
  storage_account_name   = azurerm_storage_account.example.name
  storage_container_name = azurerm_storage_container.example.name
  type                   = "Block"
  source                 = "./build/index.html"
}

resource "azurerm_storage_blob" "static_files" {
  for_each               = fileset("./build/static", "**")
  name                   = each.value
  storage_account_name   = azurerm_storage_account.example.name
  storage_container_name = azurerm_storage_container.example.name
  type                   = "Block"
  source                 = "./build/static/${each.value}"
}

resource "azurerm_static_site" "example" {
  name                = "examplestaticsite"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku_tier            = "Free"
}

output "static_site_url" {
  value = azurerm_static_site.example.default_host_name
}
