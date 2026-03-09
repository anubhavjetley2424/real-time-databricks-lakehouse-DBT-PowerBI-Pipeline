resource "databricks_job" "smart_pest_pipeline" {
  name = "Smart_Pest_End_to_End_Pipeline"

  git_source {
    url      = "https://github.com/anubhavjetley2424/flick-pest-dbt.git"
    branch   = "main"
    provider = "gitHub"
  }

  # Task 1: Ingestion
  task {
    task_key = "ingestion_streaming"
    
    new_cluster {
      num_workers   = 1
      spark_version = "13.3.x-scala2.12"
      node_type_id  = "Standard_DS3_v2"
    }

    notebook_task {
      notebook_path = "notebooks/ingest_telemetry" # Path relative to git root
    }
  }

  # Task 2: dbt Transformation
  task {
    task_key = "dbt_transformations"
    depends_on { task_key = "ingestion_streaming" }

    dbt_task {
      project_directory = "dbt_project"
      commands          = ["dbt build"]
      warehouse_id      = databricks_sql_endpoint.power_bi_server.id
      catalog           = "main"
      schema            = "analytics_gold"
    }
  }

  schedule {
    quartz_cron_expression = "0 0 * * * ?"
    timezone_id            = "Australia/Sydney"
  }
}