terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0"
    }
  }

  # Update this block with the location of your terraform state file
  backend "azurerm" {
    resource_group_name  = "agitbusinesscard"
    storage_account_name = "agitbusinesscardstorage"
    container_name       = "tfagitbusinesscard"
    key                  = "agitbusinesscard.tfstate"
    use_oidc             = true
  }
}

provider "azurerm" {
  features {}
  use_oidc        = true
  client_id       = var.client_id
  tenant_id       = var.tenant_id
  client_secret   = var.client_secret
  subscription_id = var.subscription_id
}

# Create the resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Create the Windows App Service Plan
resource "azurerm_service_plan" "appserviceplan" {
  name                = "ASP-agitbusinesscard-bed6"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Windows"
  sku_name            = "F1"
}

# Create the web app, pass in the App Service Plan ID
resource "azurerm_windows_web_app" "app" {
  name                = "agitbusinesscard"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.ASP.id

  auth_settings_v2 {
    auth_enabled           = true
    excluded_paths         = []
    unauthenticated_action = "AllowAnonymous"
    http_route_api_prefix  = "/.auth"

    active_directory_v2 {
      client_id            = var.client_id
      tenant_auth_endpoint = var.tenant_auth_endpoint
    }
    login {
      cookie_expiration_convention = "FixedTime"
      logout_endpoint              = "/.auth/logout"
      nonce_expiration_time        = "00:05:00"
      token_refresh_extension_time = 72
      token_store_enabled          = true
      token_store_path             = ""
      token_store_sas_setting_name = ""
      validate_nonce               = true
    }
  }

  site_config {
    always_on = true

    application_stack {
      current_stack  = "dotnet"
      dotnet_version = "6.0"
    }

    virtual_application {
      physical_path = "site\\wwwroot"
      preload       = false
      virtual_path  = "/"
    }
  }
  sticky_settings {
    app_setting_names = [
      "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"
    ]
    connection_string_names = []
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
  name                  = "media"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
}

