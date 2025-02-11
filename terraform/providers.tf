terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "=4.9.0"
    }
    grafana = {
      source = "grafana/grafana"
      version = "=2.9.0"
    }
  }
  backend "azurerm" {
    resource_group_name   = "grafana-stg-rg"
    storage_account_name  = "grafanastate"
    container_name        = "tfstate"
    key                   = "terraform.tfstate"
    }
}

provider "azurerm" {
  subscription_id = "*"
  features {}
}

data "azurerm_key_vault" "existing" {
  name                = "grafana-stg-kv"
  resource_group_name = "grafana-stg-rg"
}

data "azurerm_key_vault_secret" "grafana_key" {
  name         = "apikeygrafana"
  key_vault_id = data.azurerm_key_vault.existing.id
}

provider "grafana" {
  url = "https://<url>.grafana.azure.com"
  auth  = data.azurerm_key_vault_secret.grafana_key.value
}

  
