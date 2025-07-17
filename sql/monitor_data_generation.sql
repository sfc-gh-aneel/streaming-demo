-- =====================================================
-- Monitor Real-Time Data Generation
-- =====================================================

USE DATABASE MANUFACTURING_DEMO;
USE WAREHOUSE COMPUTE_WH;

-- Check current row counts and growth
SELECT 'CURRENT DATA VOLUMES:' as info;

SELECT 
    'FACT_SENSOR_READINGS' as table_name,
    COUNT(*) as total_rows,
    COUNT(CASE WHEN timestamp_utc >= DATEADD('MINUTE', -1, CURRENT_TIMESTAMP()) THEN 1 END) as last_1_min,
    COUNT(CASE WHEN timestamp_utc >= DATEADD('MINUTE', -5, CURRENT_TIMESTAMP()) THEN 1 END) as last_5_min,
    COUNT(CASE WHEN timestamp_utc >= DATEADD('MINUTE', -10, CURRENT_TIMESTAMP()) THEN 1 END) as last_10_min
FROM ANALYTICS.FACT_SENSOR_READINGS
UNION ALL
SELECT 
    'FACT_PRODUCTION',
    COUNT(*),
    COUNT(CASE WHEN timestamp_utc >= DATEADD('MINUTE', -1, CURRENT_TIMESTAMP()) THEN 1 END),
    COUNT(CASE WHEN timestamp_utc >= DATEADD('MINUTE', -5, CURRENT_TIMESTAMP()) THEN 1 END),
    COUNT(CASE WHEN timestamp_utc >= DATEADD('MINUTE', -10, CURRENT_TIMESTAMP()) THEN 1 END)
FROM ANALYTICS.FACT_PRODUCTION
UNION ALL
SELECT 
    'FACT_QUALITY',
    COUNT(*),
    COUNT(CASE WHEN timestamp_utc >= DATEADD('MINUTE', -1, CURRENT_TIMESTAMP()) THEN 1 END),
    COUNT(CASE WHEN timestamp_utc >= DATEADD('MINUTE', -5, CURRENT_TIMESTAMP()) THEN 1 END),
    COUNT(CASE WHEN timestamp_utc >= DATEADD('MINUTE', -10, CURRENT_TIMESTAMP()) THEN 1 END)
FROM ANALYTICS.FACT_QUALITY;

-- Check most recent data timestamps
SELECT 'LATEST DATA TIMESTAMPS:' as info;
SELECT 
    'SENSOR' as data_type,
    MAX(timestamp_utc) as latest_timestamp,
    DATEDIFF('second', MAX(timestamp_utc), CURRENT_TIMESTAMP()) as seconds_ago
FROM ANALYTICS.FACT_SENSOR_READINGS
UNION ALL
SELECT 
    'PRODUCTION',
    MAX(timestamp_utc),
    DATEDIFF('second', MAX(timestamp_utc), CURRENT_TIMESTAMP())
FROM ANALYTICS.FACT_PRODUCTION
UNION ALL
SELECT 
    'QUALITY',
    MAX(timestamp_utc), 
    DATEDIFF('second', MAX(timestamp_utc), CURRENT_TIMESTAMP())
FROM ANALYTICS.FACT_QUALITY;

-- Check raw data ingestion  
SELECT 'RAW DATA INGESTION:' as info;
SELECT 
    'SENSOR_DATA_RAW' as table_name,
    COUNT(*) as total_rows,
    COUNT(CASE WHEN load_timestamp >= DATEADD('MINUTE', -1, CURRENT_TIMESTAMP()) THEN 1 END) as last_1_min,
    MAX(load_timestamp) as latest_load
FROM RAW_DATA.SENSOR_DATA_RAW
UNION ALL
SELECT 
    'PRODUCTION_DATA_RAW',
    COUNT(*),
    COUNT(CASE WHEN load_timestamp >= DATEADD('MINUTE', -1, CURRENT_TIMESTAMP()) THEN 1 END),
    MAX(load_timestamp)
FROM RAW_DATA.PRODUCTION_DATA_RAW
UNION ALL
SELECT 
    'QUALITY_DATA_RAW',
    COUNT(*),
    COUNT(CASE WHEN load_timestamp >= DATEADD('MINUTE', -1, CURRENT_TIMESTAMP()) THEN 1 END),
    MAX(load_timestamp)
FROM RAW_DATA.QUALITY_DATA_RAW; 