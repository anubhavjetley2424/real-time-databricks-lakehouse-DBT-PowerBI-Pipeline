terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    # ADD THIS PART:
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
    databricks = {
      source = "databricks/databricks"
    }
  }
}

provider "azurerm" {
  features {}
}

# AND ADD THIS EMPTY BLOCK:
provider "azuread" {}

provider "databricks" {
  host = azurerm_databricks_workspace.flick_dw.workspace_url
}