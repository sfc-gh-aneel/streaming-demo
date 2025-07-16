-- =====================================================
-- Fix Dashboard Procedure Time Windows
-- =====================================================

USE DATABASE MANUFACTURING_DEMO;
USE SCHEMA UTILITIES;
USE WAREHOUSE COMPUTE_WH;

-- Update dashboard procedure with reasonable time windows
CREATE OR REPLACE PROCEDURE UPDATE_REALTIME_DASHBOARD()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    -- Insert current snapshot with EXPANDED TIME WINDOWS
    INSERT INTO AGGREGATION.AGG_REALTIME_DASHBOARD (
        snapshot_timestamp,
        total_active_equipment, equipment_online_count, equipment_offline_count, equipment_alert_count,
        current_production_rate_per_hour, today_units_produced, today_production_target, today_efficiency_percent,
        today_tests_conducted, today_pass_rate_percent, today_defect_rate,
        critical_alerts_count, high_priority_alerts_count, medium_priority_alerts_count
    )
    WITH current_metrics AS (
        SELECT 
            COUNT(DISTINCT e.equipment_id) as total_active_equipment,
            COUNT(DISTINCT CASE WHEN latest_sensor.status = 'RUNNING' THEN e.equipment_id END) as equipment_online_count,
            COUNT(DISTINCT CASE WHEN latest_sensor.status IN ('STOPPED', 'ERROR') THEN e.equipment_id END) as equipment_offline_count,
            COUNT(DISTINCT CASE WHEN latest_sensor.alert_level IN ('HIGH', 'CRITICAL') THEN e.equipment_id END) as equipment_alert_count
        FROM ANALYTICS.DIM_EQUIPMENT e
        LEFT JOIN (
            SELECT equipment_key, status, alert_level,
                   ROW_NUMBER() OVER (PARTITION BY equipment_key ORDER BY timestamp_utc DESC) as rn
            FROM ANALYTICS.FACT_SENSOR_READINGS 
            WHERE timestamp_utc >= DATEADD('HOUR', -24, CURRENT_TIMESTAMP())  -- CHANGED FROM -5 MINUTES TO -24 HOURS
        ) latest_sensor ON e.equipment_key = latest_sensor.equipment_key AND latest_sensor.rn = 1
    ),
    production_metrics AS (
        SELECT 
            SUM(f.units_produced) / NULLIF(DATEDIFF('HOUR', DATE_TRUNC('HOUR', MIN(f.timestamp_utc)), CURRENT_TIMESTAMP()), 0) as current_production_rate_per_hour,
            SUM(CASE WHEN f.timestamp_utc >= DATEADD('HOUR', -24, CURRENT_TIMESTAMP()) THEN f.units_produced ELSE 0 END) as today_units_produced,
            SUM(CASE WHEN f.timestamp_utc >= DATEADD('HOUR', -24, CURRENT_TIMESTAMP()) THEN f.planned_units ELSE 0 END) as today_production_target
        FROM ANALYTICS.FACT_PRODUCTION f
        WHERE f.timestamp_utc >= DATEADD('HOUR', -24, CURRENT_TIMESTAMP())  -- CHANGED FROM CURRENT_DATE() TO -24 HOURS
    ),
    quality_metrics AS (
        SELECT 
            COUNT(CASE WHEN q.timestamp_utc >= DATEADD('HOUR', -24, CURRENT_TIMESTAMP()) THEN 1 END) as today_tests_conducted,
            AVG(CASE WHEN q.timestamp_utc >= DATEADD('HOUR', -24, CURRENT_TIMESTAMP()) AND q.is_within_spec THEN 100.0 ELSE 0 END) as today_pass_rate_percent,
            COUNT(CASE WHEN q.timestamp_utc >= DATEADD('HOUR', -24, CURRENT_TIMESTAMP()) AND q.defect_type IS NOT NULL THEN 1 END) * 1000.0 / 
                NULLIF(COUNT(CASE WHEN q.timestamp_utc >= DATEADD('HOUR', -24, CURRENT_TIMESTAMP()) THEN 1 END), 0) as today_defect_rate
        FROM ANALYTICS.FACT_QUALITY q
        WHERE q.timestamp_utc >= DATEADD('HOUR', -24, CURRENT_TIMESTAMP())  -- CHANGED FROM CURRENT_DATE() TO -24 HOURS
    )
    SELECT 
        CURRENT_TIMESTAMP() as snapshot_timestamp,
        cm.total_active_equipment,
        cm.equipment_online_count,
        cm.equipment_offline_count,
        cm.equipment_alert_count,
        COALESCE(pm.current_production_rate_per_hour, 0) as current_production_rate_per_hour,
        COALESCE(pm.today_units_produced, 0) as today_units_produced,
        COALESCE(pm.today_production_target, 0) as today_production_target,
        COALESCE((pm.today_units_produced * 100.0 / NULLIF(pm.today_production_target, 0)), 0) as today_efficiency_percent,
        COALESCE(qm.today_tests_conducted, 0) as today_tests_conducted,
        COALESCE(qm.today_pass_rate_percent, 0) as today_pass_rate_percent,
        COALESCE(qm.today_defect_rate, 0) as today_defect_rate,
        COALESCE(cm.equipment_alert_count, 0) as critical_alerts_count,
        COALESCE(FLOOR(cm.equipment_alert_count * 0.6), 0) as high_priority_alerts_count,
        COALESCE(FLOOR(cm.equipment_alert_count * 0.3), 0) as medium_priority_alerts_count
    FROM current_metrics cm, production_metrics pm, quality_metrics qm;
    
    -- Clean up old dashboard records (keep last 24 hours)
    DELETE FROM AGGREGATION.AGG_REALTIME_DASHBOARD 
    WHERE snapshot_timestamp < DATEADD('DAY', -1, CURRENT_TIMESTAMP());
    
    RETURN 'Real-time dashboard updated. Rows processed: ' || SQLROWCOUNT;
END;
$$;

-- Now test the fixed procedure
CALL UPDATE_REALTIME_DASHBOARD();

-- Verify results
SELECT 'DASHBOARD RESULTS:' as info;
SELECT * FROM AGGREGATION.AGG_REALTIME_DASHBOARD ORDER BY snapshot_timestamp DESC LIMIT 1; 