resource "databricks_job" "smart_pest_pipeline" {
  name = "Smart_Pest_End_to_End_Pipeline"

  git_source {
    url      = "https://github.com/anubhavjetley2424/flick-pest-dbt.git"
    branch   = "main"
    provider = "gitHub"
  }

  # Task 1: Ingestion (Spark Streaming)
  task {
    task_key = "ingestion_streaming"
    
    new_cluster {
      num_workers   = 1
      spark_version = "13.3.x-scala2.12"
      node_type_id  = "Standard_DS3_v2"
      spark_conf = {
        "spark.eventhub.connectionString" = azurerm_eventhub_namespace.smart_ns.default_primary_connection_string
      }
    }

    notebook_task {
      notebook_path = "notebooks/ingest_telemetry"
    }
  }

  # Task 2: dbt Transformation (Using Serverless SQL Warehouse)
  task {
    task_key = "dbt_transformations"
    depends_on { task_key = "ingestion_streaming" }

    # Using the singular 'environment' block inside the task
    # This is compatible with both older and newer provider versions
    environment_key = "dbt_env"

    dbt_task {
      project_directory = "dbt_project"
      commands          = ["dbt build"]
      warehouse_id      = databricks_sql_endpoint.power_bi_server.id
      catalog           = "main"
      schema            = "analytics_gold"
    }
  }

  # Define the environment at the job level (Singular 'environment' block)
  environment {
    environment_key = "dbt_env"
    spec {
      client = "dbt"
    }
  }

  schedule {
    quartz_cron_expression = "0 0 * * * ?"
    timezone_id            = "Australia/Sydney"
  }
}