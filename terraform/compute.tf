# 1. Databricks SQL Warehouse (Power BI Server)
resource "databricks_sql_endpoint" "power_bi_server" {
  name             = "Flick_BI_Warehouse"
  cluster_size     = "2X-Small"
  max_num_clusters = 1
  auto_stop_mins   = 30 
}

# 2. Interactive Development Cluster
resource "databricks_cluster" "dev_cluster" {
  cluster_name            = "flick-dev-cluster"
  spark_version           = "13.3.x-scala2.12"
  node_type_id            = "Standard_DS3_v2"
  autotermination_minutes = 20
  num_workers             = 1

  spark_conf = {
    "spark.databricks.delta.preview.enabled" = "true"
  }
}