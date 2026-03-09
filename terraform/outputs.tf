# This outputs the connection string for your Python Generator
output "eventhub_connection_string" {
  value     = azurerm_eventhub_namespace.smart_ns.default_primary_connection_string
  sensitive = true # Keeps it hidden in logs; use 'terraform output -raw eventhub_connection_string' to see it
}

# This outputs the Databricks Workspace URL for your reference
output "databricks_host" {
  value = azurerm_databricks_workspace.flick_dw.workspace_url
}