# 1. Resource Group
resource "azurerm_resource_group" "flick_rg" {
  name     = "rg-flick-smart-v2"  # Changed from prod to v2
  location = "Australia East"
}


# 2. Storage Account (ADLS Gen2 Lakehouse)
resource "azurerm_storage_account" "lakehouse" {
  name                     = "stflicklakehouseprod"
  resource_group_name      = azurerm_resource_group.flick_rg.name
  location                 = azurerm_resource_group.flick_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true 
}

# 3. Event Hub (Real-time Entry)
resource "azurerm_eventhub_namespace" "smart_ns" {
  name                = "evhns-flick-smart-prod"
  location            = azurerm_resource_group.flick_rg.location
  resource_group_name = azurerm_resource_group.flick_rg.name
  sku                 = "Standard"
}

resource "azurerm_eventhub" "telemetry" {
  name                = "pest-telemetry"
  namespace_name      = azurerm_eventhub_namespace.smart_ns.name
  resource_group_name = azurerm_resource_group.flick_rg.name
  partition_count     = 2
  message_retention   = 1
}

# 4. Databricks Workspace
resource "azurerm_databricks_workspace" "flick_dw" {
  name                = "dbw-flick-analytics"
  resource_group_name = azurerm_resource_group.flick_rg.name
  location            = azurerm_resource_group.flick_rg.location
  sku                 = "premium"
}
