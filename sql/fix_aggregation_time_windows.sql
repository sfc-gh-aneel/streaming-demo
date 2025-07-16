-- =====================================================
-- Fix Aggregation Time Windows to Find Existing Data
-- =====================================================

USE DATABASE MANUFACTURING_DEMO;
USE SCHEMA UTILITIES;
USE WAREHOUSE COMPUTE_WH;

-- Update equipment performance procedure to look back 24 hours instead of 1 hour
CREATE OR REPLACE PROCEDURE CALCULATE_EQUIPMENT_PERFORMANCE()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    -- Minute-level aggregations - EXPANDED TIME WINDOW TO 24 HOURS
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
        
        -- Predictive indicators (simplified to avoid complexity)
        'STABLE' as vibration_trend,
        75.0 as maintenance_risk_score,
        0.1 as predicted_failure_probability
        
    FROM ANALYTICS.FACT_SENSOR_READINGS f
    JOIN ANALYTICS.DIM_EQUIPMENT e ON f.equipment_key = e.equipment_key
    WHERE f.timestamp_utc >= DATEADD('HOUR', -24, CURRENT_TIMESTAMP())  -- CHANGED FROM -1 TO -24
    AND NOT EXISTS (
        SELECT 1 FROM AGGREGATION.AGG_EQUIPMENT_PERFORMANCE aep 
        WHERE aep.equipment_id = e.equipment_id 
        AND aep.time_window_start = DATE_TRUNC('MINUTE', f.timestamp_utc)
        AND aep.aggregation_level = 'MINUTE'
    )
    GROUP BY e.equipment_id, e.equipment_name, e.max_temperature, e.max_pressure, DATE_TRUNC('MINUTE', f.timestamp_utc);
    
    RETURN 'Equipment performance aggregations completed. Rows processed: ' || SQLROWCOUNT;
END;
$$;

-- Update production metrics procedure to look back 24 hours instead of 2 hours
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
        CASE 
            WHEN HOUR(f.timestamp_utc) >= 6 AND HOUR(f.timestamp_utc) < 14 THEN 'DAY_SHIFT'
            WHEN HOUR(f.timestamp_utc) >= 14 AND HOUR(f.timestamp_utc) < 22 THEN 'AFTERNOON_SHIFT'
            ELSE 'NIGHT_SHIFT'
        END as shift_name,
        
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
    WHERE f.timestamp_utc >= DATEADD('HOUR', -24, CURRENT_TIMESTAMP())  -- CHANGED FROM -2 TO -24
    AND NOT EXISTS (
        SELECT 1 FROM AGGREGATION.AGG_PRODUCTION_METRICS apm 
        WHERE apm.line_id = l.line_id 
        AND apm.time_window_start = DATE_TRUNC('HOUR', f.timestamp_utc)
        AND apm.aggregation_level = 'HOUR'
    )
    GROUP BY l.line_id, l.line_name, l.target_capacity_per_hour, DATE_TRUNC('HOUR', f.timestamp_utc);
    
    RETURN 'Production metrics aggregations completed. Rows processed: ' || SQLROWCOUNT;
END;
$$;

-- Update quality summary procedure to look back 24 hours instead of 2 hours  
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
        1.33 as cp_index,  -- Simplified
        1.25 as cpk_index, -- Simplified
        
        -- Simplified top defect types
        'Surface scratches' as top_defect_type_1,
        5 as top_defect_type_1_count,
        'Dimensional variance' as top_defect_type_2,
        3 as top_defect_type_2_count,
        'Color variation' as top_defect_type_3,
        2 as top_defect_type_3_count
        
    FROM ANALYTICS.FACT_QUALITY q
    JOIN ANALYTICS.DIM_PRODUCT p ON q.product_key = p.product_key
    JOIN ANALYTICS.DIM_EQUIPMENT e ON q.equipment_key = e.equipment_key
    WHERE q.timestamp_utc >= DATEADD('HOUR', -24, CURRENT_TIMESTAMP())  -- CHANGED FROM -2 TO -24
    AND NOT EXISTS (
        SELECT 1 FROM AGGREGATION.AGG_QUALITY_SUMMARY aqs 
        WHERE aqs.product_id = p.product_id 
        AND aqs.line_id = e.production_line_id
        AND aqs.time_window_start = DATE_TRUNC('HOUR', q.timestamp_utc)
        AND aqs.aggregation_level = 'HOUR'
    )
    GROUP BY p.product_id, p.product_name, e.production_line_id, DATE_TRUNC('HOUR', q.timestamp_utc);
    
    RETURN 'Quality summary aggregations completed. Rows processed: ' || SQLROWCOUNT;
END;
$$; 