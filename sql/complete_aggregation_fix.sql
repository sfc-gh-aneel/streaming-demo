-- =====================================================
-- Complete Fix: Update Time Windows and Run Aggregations
-- =====================================================

USE DATABASE MANUFACTURING_DEMO;
USE WAREHOUSE COMPUTE_WH;

-- Step 1: Clear any existing aggregation data
DELETE FROM AGGREGATION.AGG_EQUIPMENT_PERFORMANCE;
DELETE FROM AGGREGATION.AGG_PRODUCTION_METRICS;
DELETE FROM AGGREGATION.AGG_QUALITY_SUMMARY;
DELETE FROM AGGREGATION.AGG_REALTIME_DASHBOARD;

-- Step 2: Run the fixed aggregation procedures (with 24-hour windows)
CALL UTILITIES.CALCULATE_EQUIPMENT_PERFORMANCE();
CALL UTILITIES.CALCULATE_PRODUCTION_METRICS();
CALL UTILITIES.CALCULATE_QUALITY_SUMMARY();
CALL UTILITIES.UPDATE_REALTIME_DASHBOARD();

-- Step 3: Verify data was created
SELECT 'FINAL RESULTS:' as status;

SELECT 'AGG_EQUIPMENT_PERFORMANCE' as table_name, COUNT(*) as row_count 
FROM AGGREGATION.AGG_EQUIPMENT_PERFORMANCE
UNION ALL
SELECT 'AGG_PRODUCTION_METRICS', COUNT(*) 
FROM AGGREGATION.AGG_PRODUCTION_METRICS
UNION ALL  
SELECT 'AGG_QUALITY_SUMMARY', COUNT(*) 
FROM AGGREGATION.AGG_QUALITY_SUMMARY
UNION ALL
SELECT 'AGG_PREDICTIVE_MAINTENANCE', COUNT(*) 
FROM AGGREGATION.AGG_PREDICTIVE_MAINTENANCE
UNION ALL
SELECT 'AGG_REALTIME_DASHBOARD', COUNT(*) 
FROM AGGREGATION.AGG_REALTIME_DASHBOARD;

-- Step 4: Show sample equipment performance data
SELECT 'SAMPLE EQUIPMENT DATA:' as info;
SELECT equipment_id, equipment_name, time_window_start, 
       avg_temperature, avg_pressure, avg_efficiency_percent, availability_percent
FROM AGGREGATION.AGG_EQUIPMENT_PERFORMANCE 
ORDER BY time_window_start DESC 
LIMIT 5;

-- Step 5: Show sample production data
SELECT 'SAMPLE PRODUCTION DATA:' as info;
SELECT line_id, line_name, time_window_start, 
       total_units_produced, production_efficiency_percent, units_per_hour
FROM AGGREGATION.AGG_PRODUCTION_METRICS 
ORDER BY time_window_start DESC 
LIMIT 5;

-- Step 6: Show sample quality data
SELECT 'SAMPLE QUALITY DATA:' as info;
SELECT product_id, product_name, time_window_start, 
       total_tests_conducted, pass_rate_percent, defect_rate_per_thousand
FROM AGGREGATION.AGG_QUALITY_SUMMARY 
ORDER BY time_window_start DESC 
LIMIT 5; 