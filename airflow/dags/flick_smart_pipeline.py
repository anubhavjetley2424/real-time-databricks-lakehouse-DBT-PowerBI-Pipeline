# dags/flick_smart_pipeline.py
from airflow import DAG
from airflow.providers.databricks.operators.databricks import DatabricksRunNowOperator
from airflow.providers.docker.operators.docker import DockerOperator
from datetime import datetime

with DAG('flick_pest_pipeline', start_date=datetime(2026, 3, 1), schedule_interval='@hourly') as dag:

    # 1. Trigger the Streaming Ingestion Notebook
    ingest_streaming = DatabricksRunNowOperator(
        task_id='ingest_to_bronze',
        job_id=12345, # The ID of your configured Databricks Job
        databricks_conn_id='databricks_default'
    )

    # 2. Run dbt transformations (Containerized)
    run_dbt = DockerOperator(
        task_id='dbt_transform_silver_gold',
        image='flickacr.azurecr.io/dbt-pest-control:latest',
        command='dbt build --profiles-dir .',
        docker_url='unix://var/run/docker.sock',
        network_mode='bridge'
    )

    ingest_streaming >> run_dbt