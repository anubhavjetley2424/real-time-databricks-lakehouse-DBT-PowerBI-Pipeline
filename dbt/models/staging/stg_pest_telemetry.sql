{{ config(
    materialized='incremental', 
    unique_key='event_id' 
) }}

WITH raw_data AS (
    SELECT 
        -- We create a unique ID by hashing the sensor and the exact time
        md5(concat(sensor_id, timestamp)) as event_id,
        sensor_id,
        CAST(timestamp AS TIMESTAMP) as event_at,
        location,
        event_type,
        pest_count,
        battery_level
    FROM {{ source('pest_db', 'bronze_telemetry') }}
)

SELECT * FROM raw_data

{% if is_incremental() %}
  -- This is the "Filter" that keeps the job fast
  WHERE event_at > (SELECT MAX(event_at) FROM {{ this }})
{% endif %}