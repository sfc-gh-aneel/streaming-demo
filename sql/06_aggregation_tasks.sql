-- =====================================================
-- Aggregation Tasks for Manufacturing KPIs
-- =====================================================

USE DATABASE MANUFACTURING_DEMO;
USE SCHEMA UTILITIES;
USE WAREHOUSE ANALYTICS_WH;

-- =====================================================
-- AGGREGATION PROCEDURES
-- =====================================================

-- Calculate equipment performance aggregations
CREATE OR REPLACE PROCEDURE CALCULATE_EQUIPMENT_PERFORMANCE()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    -- Minute-level aggregations
    INSERT INTO AGGREGATION.AGG_EQUIPMENT_PERFORMANCE (
        equipment_id, equipment_name, time_window_start, time_window_end, aggregation_level,
        avg_temperature, max_temperature, min_temperature, temp_variance, temp_alerts_count,
        avg_pressure, max_pressure, min_pressure, pressure_variance, pressure_alerts_count,
        avg_efficiency_percent, uptime_minutes, downtime_minutes, availability_percent, avg_power_consumption,
        vibration_trend, maintenance_risk_score, predicted_failure_probability
    )
    SELECT 
        e.equipment_id,
        e.equipment_name,
        DATE_TRUNC('MINUTE', f.timestamp_utc) as time_window_start,
        DATEADD('MINUTE', 1, DATE_TRUNC('MINUTE', f.timestamp_utc)) as time_window_end,
        'MINUTE' as aggregation_level,
        
        -- Temperature metrics
        AVG(f.temperature) as avg_temperature,
        MAX(f.temperature) as max_temperature,
        MIN(f.temperature) as min_temperature,
        VARIANCE(f.temperature) as temp_variance,
        COUNT(CASE WHEN f.alert_level IN ('HIGH', 'CRITICAL') AND f.temperature > e.max_temperature * 0.8 THEN 1 END) as temp_alerts_count,
        
        -- Pressure metrics
        AVG(f.pressure) as avg_pressure,
        MAX(f.pressure) as max_pressure,
        MIN(f.pressure) as min_pressure,
        VARIANCE(f.pressure) as pressure_variance,
        COUNT(CASE WHEN f.alert_level IN ('HIGH', 'CRITICAL') AND f.pressure > e.max_pressure * 0.8 THEN 1 END) as pressure_alerts_count,
        
        -- Performance metrics
        AVG(f.efficiency_percent) as avg_efficiency_percent,
        SUM(CASE WHEN f.status = 'RUNNING' THEN 1 ELSE 0 END) as uptime_minutes,
        SUM(CASE WHEN f.status IN ('STOPPED', 'ERROR', 'MAINTENANCE') THEN 1 ELSE 0 END) as downtime_minutes,
        (SUM(CASE WHEN f.status = 'RUNNING' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) as availability_percent,
        AVG(f.power_consumption) as avg_power_consumption,
        
        -- Predictive indicators
        CASE 
            WHEN AVG(f.vibration) > LAG(AVG(f.vibration), 1) OVER (PARTITION BY e.equipment_id ORDER BY DATE_TRUNC('MINUTE', f.timestamp_utc)) THEN 'INCREASING'
            WHEN AVG(f.vibration) < LAG(AVG(f.vibration), 1) OVER (PARTITION BY e.equipment_id ORDER BY DATE_TRUNC('MINUTE', f.timestamp_utc)) THEN 'DECREASING'
            ELSE 'STABLE'
        END as vibration_trend,
        
        UTILITIES.CALCULATE_HEALTH_SCORE(
            AVG(f.temperature), e.max_temperature,
            AVG(f.pressure), e.max_pressure,
            AVG(f.vibration), AVG(f.efficiency_percent)
        ) as maintenance_risk_score,
        
        CASE 
            WHEN UTILITIES.CALCULATE_HEALTH_SCORE(AVG(f.temperature), e.max_temperature, AVG(f.pressure), e.max_pressure, AVG(f.vibration), AVG(f.efficiency_percent)) < 60 THEN 0.8
            WHEN UTILITIES.CALCULATE_HEALTH_SCORE(AVG(f.temperature), e.max_temperature, AVG(f.pressure), e.max_pressure, AVG(f.vibration), AVG(f.efficiency_percent)) < 80 THEN 0.3
            ELSE 0.1
        END as predicted_failure_probability
        
    FROM ANALYTICS.FACT_SENSOR_READINGS f
    JOIN ANALYTICS.DIM_EQUIPMENT e ON f.equipment_key = e.equipment_key
    WHERE f.timestamp_utc >= DATEADD('HOUR', -1, CURRENT_TIMESTAMP())
    AND NOT EXISTS (
        SELECT 1 FROM AGGREGATION.AGG_EQUIPMENT_PERFORMANCE aep 
        WHERE aep.equipment_id = e.equipment_id 
        AND aep.time_window_start = DATE_TRUNC('MINUTE', f.timestamp_utc)
        AND aep.aggregation_level = 'MINUTE'
    )
    GROUP BY e.equipment_id, e.equipment_name, e.max_temperature, e.max_pressure, DATE_TRUNC('MINUTE', f.timestamp_utc);
    
    RETURN 'Equipment performance aggregations completed. Rows processed: ' || $$ROWCOUNT;
END;
$$;

-- Calculate production metrics aggregations
CREATE OR REPLACE PROCEDURE CALCULATE_PRODUCTION_METRICS()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    INSERT INTO AGGREGATION.AGG_PRODUCTION_METRICS (
        line_id, line_name, time_window_start, time_window_end, aggregation_level, shift_name,
        total_units_produced, total_planned_units, production_efficiency_percent,
        avg_cycle_time_seconds, min_cycle_time_seconds, max_cycle_time_seconds, total_production_time_minutes,
        total_reject_count, reject_rate_percent, first_pass_yield_percent,
        total_downtime_minutes, planned_downtime_minutes, unplanned_downtime_minutes, downtime_events_count,
        units_per_hour, throughput_vs_target_percent
    )
    SELECT 
        l.line_id,
        l.line_name,
        DATE_TRUNC('HOUR', f.timestamp_utc) as time_window_start,
        DATEADD('HOUR', 1, DATE_TRUNC('HOUR', f.timestamp_utc)) as time_window_end,
        'HOUR' as aggregation_level,
        UTILITIES.GET_SHIFT_NAME(HOUR(f.timestamp_utc)) as shift_name,
        
        SUM(f.units_produced) as total_units_produced,
        SUM(f.planned_units) as total_planned_units,
        (SUM(f.units_produced) * 100.0 / NULLIF(SUM(f.planned_units), 0)) as production_efficiency_percent,
        
        AVG(f.cycle_time_seconds) as avg_cycle_time_seconds,
        MIN(f.cycle_time_seconds) as min_cycle_time_seconds,
        MAX(f.cycle_time_seconds) as max_cycle_time_seconds,
        COUNT(*) as total_production_time_minutes,
        
        SUM(f.reject_count) as total_reject_count,
        (SUM(f.reject_count) * 100.0 / NULLIF(SUM(f.units_produced), 0)) as reject_rate_percent,
        ((SUM(f.units_produced) - SUM(f.reject_count)) * 100.0 / NULLIF(SUM(f.units_produced), 0)) as first_pass_yield_percent,
        
        SUM(f.downtime_minutes) as total_downtime_minutes,
        SUM(CASE WHEN f.event_type = 'PLANNED_MAINTENANCE' THEN f.downtime_minutes ELSE 0 END) as planned_downtime_minutes,
        SUM(CASE WHEN f.event_type NOT IN ('PLANNED_MAINTENANCE', 'PRODUCTION') THEN f.downtime_minutes ELSE 0 END) as unplanned_downtime_minutes,
        COUNT(CASE WHEN f.downtime_minutes > 0 THEN 1 END) as downtime_events_count,
        
        SUM(f.units_produced) as units_per_hour,
        (SUM(f.units_produced) * 100.0 / NULLIF(l.target_capacity_per_hour, 0)) as throughput_vs_target_percent
        
    FROM ANALYTICS.FACT_PRODUCTION f
    JOIN ANALYTICS.DIM_PRODUCTION_LINE l ON f.line_key = l.line_key
    WHERE f.timestamp_utc >= DATEADD('HOUR', -2, CURRENT_TIMESTAMP())
    AND NOT EXISTS (
        SELECT 1 FROM AGGREGATION.AGG_PRODUCTION_METRICS apm 
        WHERE apm.line_id = l.line_id 
        AND apm.time_window_start = DATE_TRUNC('HOUR', f.timestamp_utc)
        AND apm.aggregation_level = 'HOUR'
    )
    GROUP BY l.line_id, l.line_name, l.target_capacity_per_hour, DATE_TRUNC('HOUR', f.timestamp_utc), UTILITIES.GET_SHIFT_NAME(HOUR(f.timestamp_utc));
    
    RETURN 'Production metrics aggregations completed. Rows processed: ' || $$ROWCOUNT;
END;
$$;

-- Calculate quality summary aggregations
CREATE OR REPLACE PROCEDURE CALCULATE_QUALITY_SUMMARY()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    INSERT INTO AGGREGATION.AGG_QUALITY_SUMMARY (
        product_id, product_name, line_id, time_window_start, time_window_end, aggregation_level,
        total_tests_conducted, tests_passed, tests_failed, pass_rate_percent,
        critical_defects_count, major_defects_count, minor_defects_count, total_defects_count, defect_rate_per_thousand,
        avg_measurement_value, measurement_std_dev, cp_index, cpk_index,
        top_defect_type_1, top_defect_type_1_count, top_defect_type_2, top_defect_type_2_count, top_defect_type_3, top_defect_type_3_count
    )
    WITH defect_ranking AS (
        SELECT 
            p.product_id,
            e.production_line_id as line_id,
            DATE_TRUNC('HOUR', q.timestamp_utc) as time_window,
            q.defect_type,
            COUNT(*) as defect_count,
            ROW_NUMBER() OVER (PARTITION BY p.product_id, e.production_line_id, DATE_TRUNC('HOUR', q.timestamp_utc) ORDER BY COUNT(*) DESC) as rn
        FROM ANALYTICS.FACT_QUALITY q
        JOIN ANALYTICS.DIM_PRODUCT p ON q.product_key = p.product_key
        JOIN ANALYTICS.DIM_EQUIPMENT e ON q.equipment_key = e.equipment_key
        WHERE q.defect_type IS NOT NULL
        AND q.timestamp_utc >= DATEADD('HOUR', -2, CURRENT_TIMESTAMP())
        GROUP BY p.product_id, e.production_line_id, DATE_TRUNC('HOUR', q.timestamp_utc), q.defect_type
    )
    SELECT 
        p.product_id,
        p.product_name,
        e.production_line_id as line_id,
        DATE_TRUNC('HOUR', q.timestamp_utc) as time_window_start,
        DATEADD('HOUR', 1, DATE_TRUNC('HOUR', q.timestamp_utc)) as time_window_end,
        'HOUR' as aggregation_level,
        
        COUNT(*) as total_tests_conducted,
        COUNT(CASE WHEN q.is_within_spec = TRUE THEN 1 END) as tests_passed,
        COUNT(CASE WHEN q.is_within_spec = FALSE THEN 1 END) as tests_failed,
        (COUNT(CASE WHEN q.is_within_spec = TRUE THEN 1 END) * 100.0 / COUNT(*)) as pass_rate_percent,
        
        COUNT(CASE WHEN q.defect_type LIKE '%CRITICAL%' THEN 1 END) as critical_defects_count,
        COUNT(CASE WHEN q.defect_type LIKE '%MAJOR%' THEN 1 END) as major_defects_count,
        COUNT(CASE WHEN q.defect_type LIKE '%MINOR%' THEN 1 END) as minor_defects_count,
        COUNT(CASE WHEN q.defect_type IS NOT NULL THEN 1 END) as total_defects_count,
        (COUNT(CASE WHEN q.defect_type IS NOT NULL THEN 1 END) * 1000.0 / COUNT(*)) as defect_rate_per_thousand,
        
        AVG(q.measurement_value) as avg_measurement_value,
        STDDEV(q.measurement_value) as measurement_std_dev,
        -- Process capability calculations
        ((AVG(q.specification_max) - AVG(q.specification_min)) / (6 * STDDEV(q.measurement_value))) as cp_index,
        LEAST(
            (AVG(q.measurement_value) - AVG(q.specification_min)) / (3 * STDDEV(q.measurement_value)),
            (AVG(q.specification_max) - AVG(q.measurement_value)) / (3 * STDDEV(q.measurement_value))
        ) as cpk_index,
        
        -- Top defect types
        MAX(CASE WHEN dr1.rn = 1 THEN dr1.defect_type END) as top_defect_type_1,
        MAX(CASE WHEN dr1.rn = 1 THEN dr1.defect_count END) as top_defect_type_1_count,
        MAX(CASE WHEN dr2.rn = 2 THEN dr2.defect_type END) as top_defect_type_2,
        MAX(CASE WHEN dr2.rn = 2 THEN dr2.defect_count END) as top_defect_type_2_count,
        MAX(CASE WHEN dr3.rn = 3 THEN dr3.defect_type END) as top_defect_type_3,
        MAX(CASE WHEN dr3.rn = 3 THEN dr3.defect_count END) as top_defect_type_3_count
        
    FROM ANALYTICS.FACT_QUALITY q
    JOIN ANALYTICS.DIM_PRODUCT p ON q.product_key = p.product_key
    JOIN ANALYTICS.DIM_EQUIPMENT e ON q.equipment_key = e.equipment_key
    LEFT JOIN defect_ranking dr1 ON dr1.product_id = p.product_id AND dr1.line_id = e.production_line_id AND dr1.time_window = DATE_TRUNC('HOUR', q.timestamp_utc) AND dr1.rn = 1
    LEFT JOIN defect_ranking dr2 ON dr2.product_id = p.product_id AND dr2.line_id = e.production_line_id AND dr2.time_window = DATE_TRUNC('HOUR', q.timestamp_utc) AND dr2.rn = 2
    LEFT JOIN defect_ranking dr3 ON dr3.product_id = p.product_id AND dr3.line_id = e.production_line_id AND dr3.time_window = DATE_TRUNC('HOUR', q.timestamp_utc) AND dr3.rn = 3
    WHERE q.timestamp_utc >= DATEADD('HOUR', -2, CURRENT_TIMESTAMP())
    AND NOT EXISTS (
        SELECT 1 FROM AGGREGATION.AGG_QUALITY_SUMMARY aqs 
        WHERE aqs.product_id = p.product_id 
        AND aqs.line_id = e.production_line_id
        AND aqs.time_window_start = DATE_TRUNC('HOUR', q.timestamp_utc)
        AND aqs.aggregation_level = 'HOUR'
    )
    GROUP BY p.product_id, p.product_name, e.production_line_id, DATE_TRUNC('HOUR', q.timestamp_utc);
    
    RETURN 'Quality summary aggregations completed. Rows processed: ' || $$ROWCOUNT;
END;
$$;

-- Update real-time dashboard metrics
CREATE OR REPLACE PROCEDURE UPDATE_REALTIME_DASHBOARD()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    -- Insert current snapshot
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
            WHERE timestamp_utc >= DATEADD('MINUTE', -5, CURRENT_TIMESTAMP())
        ) latest_sensor ON e.equipment_key = latest_sensor.equipment_key AND latest_sensor.rn = 1
    ),
    production_metrics AS (
        SELECT 
            SUM(f.units_produced) / NULLIF(DATEDIFF('HOUR', DATE_TRUNC('HOUR', MIN(f.timestamp_utc)), CURRENT_TIMESTAMP()), 0) as current_production_rate_per_hour,
            SUM(CASE WHEN DATE(f.timestamp_utc) = CURRENT_DATE() THEN f.units_produced ELSE 0 END) as today_units_produced,
            SUM(CASE WHEN DATE(f.timestamp_utc) = CURRENT_DATE() THEN f.planned_units ELSE 0 END) as today_production_target
        FROM ANALYTICS.FACT_PRODUCTION f
        WHERE f.timestamp_utc >= CURRENT_DATE()
    ),
    quality_metrics AS (
        SELECT 
            COUNT(CASE WHEN DATE(q.timestamp_utc) = CURRENT_DATE() THEN 1 END) as today_tests_conducted,
            AVG(CASE WHEN DATE(q.timestamp_utc) = CURRENT_DATE() AND q.is_within_spec THEN 100.0 ELSE 0 END) as today_pass_rate_percent,
            COUNT(CASE WHEN DATE(q.timestamp_utc) = CURRENT_DATE() AND q.defect_type IS NOT NULL THEN 1 END) * 1000.0 / 
                NULLIF(COUNT(CASE WHEN DATE(q.timestamp_utc) = CURRENT_DATE() THEN 1 END), 0) as today_defect_rate
        FROM ANALYTICS.FACT_QUALITY q
        WHERE q.timestamp_utc >= CURRENT_DATE()
    )
    SELECT 
        CURRENT_TIMESTAMP() as snapshot_timestamp,
        cm.total_active_equipment,
        cm.equipment_online_count,
        cm.equipment_offline_count,
        cm.equipment_alert_count,
        pm.current_production_rate_per_hour,
        pm.today_units_produced,
        pm.today_production_target,
        (pm.today_units_produced * 100.0 / NULLIF(pm.today_production_target, 0)) as today_efficiency_percent,
        qm.today_tests_conducted,
        qm.today_pass_rate_percent,
        qm.today_defect_rate,
        cm.equipment_alert_count as critical_alerts_count,
        FLOOR(cm.equipment_alert_count * 0.6) as high_priority_alerts_count,
        FLOOR(cm.equipment_alert_count * 0.3) as medium_priority_alerts_count
    FROM current_metrics cm, production_metrics pm, quality_metrics qm;
    
    -- Clean up old dashboard records (keep last 24 hours)
    DELETE FROM AGGREGATION.AGG_REALTIME_DASHBOARD 
    WHERE snapshot_timestamp < DATEADD('DAY', -1, CURRENT_TIMESTAMP());
    
    RETURN 'Real-time dashboard updated. Rows processed: ' || $$ROWCOUNT;
END;
$$;

-- =====================================================
-- CREATE AGGREGATION TASKS
-- =====================================================

-- Task to calculate equipment performance every 5 minutes
CREATE OR REPLACE TASK CALCULATE_EQUIPMENT_PERFORMANCE_TASK
    WAREHOUSE = ANALYTICS_WH
    SCHEDULE = '5 MINUTE'
AS
    CALL UTILITIES.CALCULATE_EQUIPMENT_PERFORMANCE();

-- Task to calculate production metrics every 15 minutes
CREATE OR REPLACE TASK CALCULATE_PRODUCTION_METRICS_TASK
    WAREHOUSE = ANALYTICS_WH
    SCHEDULE = '15 MINUTE'
AS
    CALL UTILITIES.CALCULATE_PRODUCTION_METRICS();

-- Task to calculate quality summary every 15 minutes
CREATE OR REPLACE TASK CALCULATE_QUALITY_SUMMARY_TASK
    WAREHOUSE = ANALYTICS_WH
    SCHEDULE = '15 MINUTE'
AS
    CALL UTILITIES.CALCULATE_QUALITY_SUMMARY();

-- Task to update real-time dashboard every minute
CREATE OR REPLACE TASK UPDATE_REALTIME_DASHBOARD_TASK
    WAREHOUSE = ANALYTICS_WH
    SCHEDULE = '1 MINUTE'
AS
    CALL UTILITIES.UPDATE_REALTIME_DASHBOARD();

-- Resume all aggregation tasks
ALTER TASK CALCULATE_EQUIPMENT_PERFORMANCE_TASK RESUME;
ALTER TASK CALCULATE_PRODUCTION_METRICS_TASK RESUME;
ALTER TASK CALCULATE_QUALITY_SUMMARY_TASK RESUME;
ALTER TASK UPDATE_REALTIME_DASHBOARD_TASK RESUME;

-- Show all tasks
SHOW TASKS; 