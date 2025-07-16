-- =====================================================
-- Check Fact Table Data for Debugging
-- =====================================================

USE DATABASE MANUFACTURING_DEMO;
USE WAREHOUSE COMPUTE_WH;

-- Check row counts in all fact tables
SELECT 'FACT_SENSOR_READINGS' as table_name, COUNT(*) as row_count 
FROM ANALYTICS.FACT_SENSOR_READINGS
UNION ALL
SELECT 'FACT_PRODUCTION', COUNT(*) 
FROM ANALYTICS.FACT_PRODUCTION
UNION ALL  
SELECT 'FACT_QUALITY', COUNT(*) 
FROM ANALYTICS.FACT_QUALITY;

-- Check time ranges in fact tables
SELECT 'FACT_SENSOR_READINGS' as table_name, 
       MIN(timestamp_utc) as earliest_data, 
       MAX(timestamp_utc) as latest_data,
       DATEDIFF('hour', MIN(timestamp_utc), CURRENT_TIMESTAMP()) as hours_ago_earliest,
       DATEDIFF('hour', MAX(timestamp_utc), CURRENT_TIMESTAMP()) as hours_ago_latest
FROM ANALYTICS.FACT_SENSOR_READINGS
WHERE timestamp_utc IS NOT NULL
UNION ALL
SELECT 'FACT_PRODUCTION', 
       MIN(timestamp_utc), 
       MAX(timestamp_utc),
       DATEDIFF('hour', MIN(timestamp_utc), CURRENT_TIMESTAMP()),
       DATEDIFF('hour', MAX(timestamp_utc), CURRENT_TIMESTAMP())
FROM ANALYTICS.FACT_PRODUCTION  
WHERE timestamp_utc IS NOT NULL
UNION ALL
SELECT 'FACT_QUALITY', 
       MIN(timestamp_utc), 
       MAX(timestamp_utc),
       DATEDIFF('hour', MIN(timestamp_utc), CURRENT_TIMESTAMP()),
       DATEDIFF('hour', MAX(timestamp_utc), CURRENT_TIMESTAMP())
FROM ANALYTICS.FACT_QUALITY
WHERE timestamp_utc IS NOT NULL;

-- Sample some recent data from each fact table
SELECT 'SENSOR SAMPLE:' as info;
SELECT equipment_key, timestamp_utc, temperature, pressure, efficiency_percent, status
FROM ANALYTICS.FACT_SENSOR_READINGS 
ORDER BY timestamp_utc DESC 
LIMIT 5;

SELECT 'PRODUCTION SAMPLE:' as info;
SELECT equipment_key, line_key, timestamp_utc, units_produced, planned_units, cycle_time_seconds
FROM ANALYTICS.FACT_PRODUCTION 
ORDER BY timestamp_utc DESC 
LIMIT 5;

SELECT 'QUALITY SAMPLE:' as info;
SELECT equipment_key, product_key, timestamp_utc, measurement_value, is_within_spec, defect_type
FROM ANALYTICS.FACT_QUALITY 
ORDER BY timestamp_utc DESC 
LIMIT 5;

-- Check if equipment keys match between dimensions and facts
SELECT 'EQUIPMENT KEY MISMATCH CHECK:' as info;
SELECT 
    d.equipment_id,
    d.equipment_key as dim_key,
    COUNT(f.equipment_key) as fact_records
FROM ANALYTICS.DIM_EQUIPMENT d
LEFT JOIN ANALYTICS.FACT_SENSOR_READINGS f ON d.equipment_key = f.equipment_key
GROUP BY d.equipment_id, d.equipment_key
ORDER BY d.equipment_id; 