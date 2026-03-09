WITH( telemetry AS 
    SELECT * FROM {{ ref('stg_pest_telemetry') }}
),
locations AS (
    SELECT * FROM {{ ref('sensor_locations') }}
)

SELECT 
    l.site_name,
    l.region,
    DATE_TRUNC('hour', t.event_at) as hour_bucket,
    SUM(t.pest_detected) as total_pests,
    AVG(t.battery_level) as avg_battery
FROM telemetry t
JOIN locations l ON t.sensor_id = l.sensor_id
GROUP BY 1, 2, 3