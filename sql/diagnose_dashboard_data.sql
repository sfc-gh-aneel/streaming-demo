-- =====================================================
-- Diagnose Dashboard Data Issues
-- =====================================================

USE DATABASE MANUFACTURING_DEMO;
USE WAREHOUSE COMPUTE_WH;

-- Check what dates exist in fact tables
SELECT 'FACT TABLE DATE RANGES:' as info;

SELECT 'FACT_SENSOR_READINGS' as table_name, 
       MIN(DATE(timestamp_utc)) as earliest_date, 
       MAX(DATE(timestamp_utc)) as latest_date,
       COUNT(*) as total_rows,
       COUNT(CASE WHEN DATE(timestamp_utc) = CURRENT_DATE() THEN 1 END) as today_rows,
       COUNT(CASE WHEN timestamp_utc >= DATEADD('MINUTE', -5, CURRENT_TIMESTAMP()) THEN 1 END) as last_5_min_rows
FROM ANALYTICS.FACT_SENSOR_READINGS
UNION ALL
SELECT 'FACT_PRODUCTION', 
       MIN(DATE(timestamp_utc)), 
       MAX(DATE(timestamp_utc)),
       COUNT(*),
       COUNT(CASE WHEN DATE(timestamp_utc) = CURRENT_DATE() THEN 1 END),
       COUNT(CASE WHEN timestamp_utc >= DATEADD('MINUTE', -5, CURRENT_TIMESTAMP()) THEN 1 END)
FROM ANALYTICS.FACT_PRODUCTION
UNION ALL
SELECT 'FACT_QUALITY', 
       MIN(DATE(timestamp_utc)), 
       MAX(DATE(timestamp_utc)),
       COUNT(*),
       COUNT(CASE WHEN DATE(timestamp_utc) = CURRENT_DATE() THEN 1 END),
       COUNT(CASE WHEN timestamp_utc >= DATEADD('MINUTE', -5, CURRENT_TIMESTAMP()) THEN 1 END)
FROM ANALYTICS.FACT_QUALITY;

-- Show what CURRENT_DATE and recent timestamps look like
SELECT 'CURRENT TIMESTAMPS:' as info;
SELECT 
    CURRENT_DATE() as current_date,
    CURRENT_TIMESTAMP() as current_timestamp,
    DATEADD('MINUTE', -5, CURRENT_TIMESTAMP()) as five_minutes_ago,
    DATE(DATEADD('HOUR', -24, CURRENT_TIMESTAMP())) as yesterday_date;

-- Check sample data timestamps
SELECT 'SAMPLE SENSOR DATA TIMESTAMPS:' as info;
SELECT equipment_key, timestamp_utc, DATE(timestamp_utc) as date_part, status
FROM ANALYTICS.FACT_SENSOR_READINGS 
ORDER BY timestamp_utc DESC 
LIMIT 10;

-- Check equipment foreign key relationships  
SELECT 'EQUIPMENT KEY CHECK:' as info;
SELECT 
    d.equipment_id,
    d.equipment_key,
    COUNT(f.equipment_key) as sensor_records
FROM ANALYTICS.DIM_EQUIPMENT d
LEFT JOIN ANALYTICS.FACT_SENSOR_READINGS f ON d.equipment_key = f.equipment_key
GROUP BY d.equipment_id, d.equipment_key
ORDER BY d.equipment_id; 