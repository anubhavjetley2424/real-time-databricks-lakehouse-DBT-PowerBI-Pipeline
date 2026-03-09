# notebooks/ingest_telemetry.py
from pyspark.sql.functions import from_json, col, current_timestamp
from pyspark.sql.types import StructType, StringType, IntegerType, DoubleType

# 1. Define the Schema (Must match your Python Producer)
schema = StructType() \
    .add("sensor_id", StringType()) \
    .add("timestamp", StringType()) \
    .add("location", StringType()) \
    .add("event_type", StringType()) \
    .add("pest_count", IntegerType()) \
    .add("battery_level", DoubleType())

# 2. Configure Event Hubs Connection DYNAMICALLY
# This pulls the value Terraform injected into the Spark session
connectionString = spark.conf.get("spark.eventhub.connectionString")

# Clean the connection string (append EntityPath if missing)
# Spark Event Hubs connector usually needs the specific hub name at the end
if "EntityPath" not in connectionString:
    connectionString = f"{connectionString};EntityPath=pest-telemetry"

conf = {
  'eventhubs.connectionString' : sc._jvm.org.apache.spark.eventhubs.EventHubsUtils.encrypt(connectionString)
}

# 3. Read the Stream from Event Hubs
raw_stream_df = spark.readStream \
    .format("eventhubs") \
    .options(**conf) \
    .load()

# 4. Transform Binary Body to Structured Columns
# We also add an 'ingested_at' timestamp for audit purposes
processed_df = raw_stream_df.select(
    from_json(col("body").cast("string"), schema).alias("data")
).select("data.*") \
 .withColumn("ingested_at", current_timestamp())

# 5. Write to Bronze Delta Table with Checkpointing
# The checkpointLocation is critical for 'Exactly-Once' processing
query = processed_df.writeStream \
    .format("delta") \
    .outputMode("append") \
    .option("checkpointLocation", "/mnt/telemetry/checkpoints/bronze") \
    .toTable("main.default.bronze_telemetry")