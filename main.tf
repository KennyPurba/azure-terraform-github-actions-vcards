terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0"
    }
  }

  # Update this block with the location of your terraform state file
  backend "azurerm" {
    resource_group_name  = "tfagitbusinesscard"
    storage_account_name = "tfagitbusinesscard"
    container_name       = "agitbusinesscard"
    key                  = "agitbusinesscard.tfstate"
    use_oidc             = true
  }
}

provider "azurerm" {
  features {}
  use_oidc = true
}

# Create the resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Create the Linux App Service Plan
resource "azurerm_service_plan" "appserviceplan" {
  name                = "webapp-asp-${var.prefix_environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1"
}

# Create the web app, pass in the App Service Plan ID
resource "azurerm_windows_web_app" "app" {
  name                = "agitbusinesscard"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.ASP.id

  site_config {
    always_on = true
  }
}


# Create the Linux App Service Plan
resource "azurerm_service_plan" "ASP" {
  name                = "ASP-agitbusinesscard"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "B1"
  os_type             = "Windows"
}

# Create Storage Account in Resource Group
resource "azurerm_storage_account" "storage_account" {
  name                     = "agitbusinesscardstorage"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_table" "table" {
  name                 = "profile"
  storage_account_name = azurerm_storage_account.storage_account.name
  
}

resource "azurerm_storage_container" "container" {
  name                 = "media"
  storage_account_name = azurerm_storage_account.storage_account.name
  container_access_type = "private"
}

