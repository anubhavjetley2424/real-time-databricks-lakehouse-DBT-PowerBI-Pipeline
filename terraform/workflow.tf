resource "databricks_job" "smart_pest_pipeline" {
  name = "Smart_Pest_End_to_End_Pipeline"

  # Single source of truth for your notebooks and dbt code
  git_source {
    url      = "https://github.com/anubhavjetley2424/flick-pest-dbt.git"
    branch   = "main"
    provider = "gitHub"
  }

  environments {
    environment_key = "dbt_env"
    spec {
      client = "dbt"
    }
  }

  # -----------------------------------------------------------------------
  # TASK 1: Ingestion (Spark Streaming)
  # -----------------------------------------------------------------------
  task {
    task_key = "ingestion_streaming"
    
    new_cluster {
      num_workers   = 1
      spark_version = "13.3.x-scala2.12"
      node_type_id  = "Standard_DS3_v2"

      # Terraform injects the Event Hub key directly into the cluster memory
      spark_conf = {
        "spark.eventhub.connectionString" = azurerm_eventhub_namespace.smart_ns.default_primary_connection_string
      }
    }

    notebook_task {
      notebook_path = "notebooks/ingest_telemetry"
    }
  }

  # -----------------------------------------------------------------------
  # TASK 2: dbt Transformation (Using Serverless SQL Warehouse)
  # -----------------------------------------------------------------------
  task {
    task_key = "dbt_transformations"
    depends_on { task_key = "ingestion_streaming" }

    # Link to the environment defined at the top of the resource
    environment_key = "dbt_env" 

    dbt_task {
      project_directory = "dbt_project"
      commands          = ["dbt build"]
      warehouse_id      = databricks_sql_endpoint.power_bi_server.id
      catalog           = "main"
      schema            = "analytics_gold"
    }
  }

  # -----------------------------------------------------------------------
  # SCHEDULE: Runs at the top of every hour
  # -----------------------------------------------------------------------
  schedule {
    quartz_cron_expression = "0 0 * * * ?"
    timezone_id            = "Australia/Sydney"
  }
}