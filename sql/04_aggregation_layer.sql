-- =====================================================
-- Aggregation Layer for Manufacturing KPIs
-- =====================================================

USE DATABASE MANUFACTURING_DEMO;
USE SCHEMA AGGREGATION;
USE WAREHOUSE ANALYTICS_WH;

-- =====================================================
-- EQUIPMENT PERFORMANCE AGGREGATIONS
-- =====================================================

-- Real-time equipment performance metrics
CREATE OR REPLACE TABLE AGG_EQUIPMENT_PERFORMANCE (
    equipment_id STRING,
    equipment_name STRING,
    time_window_start TIMESTAMP_NTZ,
    time_window_end TIMESTAMP_NTZ,
    aggregation_level STRING, -- 'MINUTE', 'HOUR', 'SHIFT', 'DAY'
    
    -- Temperature metrics
    avg_temperature FLOAT,
    max_temperature FLOAT,
    min_temperature FLOAT,
    temp_variance FLOAT,
    temp_alerts_count NUMBER,
    
    -- Pressure metrics
    avg_pressure FLOAT,
    max_pressure FLOAT,
    min_pressure FLOAT,
    pressure_variance FLOAT,
    pressure_alerts_count NUMBER,
    
    -- Performance metrics
    avg_efficiency_percent FLOAT,
    uptime_minutes FLOAT,
    downtime_minutes FLOAT,
    availability_percent FLOAT,
    avg_power_consumption FLOAT,
    
    -- Predictive indicators
    vibration_trend STRING, -- 'INCREASING', 'STABLE', 'DECREASING'
    maintenance_risk_score FLOAT,
    predicted_failure_probability FLOAT,
    
    last_updated TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    
    CONSTRAINT PK_AGG_EQUIPMENT PRIMARY KEY (equipment_id, time_window_start, aggregation_level)
) COMMENT = 'Real-time equipment performance aggregations';

-- =====================================================
-- PRODUCTION METRICS AGGREGATIONS
-- =====================================================

-- Production line performance metrics
CREATE OR REPLACE TABLE AGG_PRODUCTION_METRICS (
    line_id STRING,
    line_name STRING,
    time_window_start TIMESTAMP_NTZ,
    time_window_end TIMESTAMP_NTZ,
    aggregation_level STRING,
    shift_name STRING,
    
    -- Production volumes
    total_units_produced NUMBER,
    total_planned_units NUMBER,
    production_efficiency_percent FLOAT,
    
    -- Timing metrics
    avg_cycle_time_seconds FLOAT,
    min_cycle_time_seconds FLOAT,
    max_cycle_time_seconds FLOAT,
    total_production_time_minutes FLOAT,
    
    -- Quality metrics
    total_reject_count NUMBER,
    reject_rate_percent FLOAT,
    first_pass_yield_percent FLOAT,
    
    -- Downtime analysis
    total_downtime_minutes FLOAT,
    planned_downtime_minutes FLOAT,
    unplanned_downtime_minutes FLOAT,
    downtime_events_count NUMBER,
    
    -- Throughput metrics
    units_per_hour FLOAT,
    throughput_vs_target_percent FLOAT,
    
    last_updated TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    
    CONSTRAINT PK_AGG_PRODUCTION PRIMARY KEY (line_id, time_window_start, aggregation_level)
) COMMENT = 'Production line performance aggregations';

-- =====================================================
-- QUALITY SUMMARY AGGREGATIONS
-- =====================================================

-- Quality control summary metrics
CREATE OR REPLACE TABLE AGG_QUALITY_SUMMARY (
    product_id STRING,
    product_name STRING,
    line_id STRING,
    time_window_start TIMESTAMP_NTZ,
    time_window_end TIMESTAMP_NTZ,
    aggregation_level STRING,
    
    -- Quality test metrics
    total_tests_conducted NUMBER,
    tests_passed NUMBER,
    tests_failed NUMBER,
    pass_rate_percent FLOAT,
    
    -- Defect analysis
    critical_defects_count NUMBER,
    major_defects_count NUMBER,
    minor_defects_count NUMBER,
    total_defects_count NUMBER,
    defect_rate_per_thousand FLOAT,
    
    -- Statistical metrics
    avg_measurement_value FLOAT,
    measurement_std_dev FLOAT,
    cp_index FLOAT, -- Process capability index
    cpk_index FLOAT, -- Process capability index adjusted for centering
    
    -- Top defect types
    top_defect_type_1 STRING,
    top_defect_type_1_count NUMBER,
    top_defect_type_2 STRING,
    top_defect_type_2_count NUMBER,
    top_defect_type_3 STRING,
    top_defect_type_3_count NUMBER,
    
    last_updated TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    
    CONSTRAINT PK_AGG_QUALITY PRIMARY KEY (product_id, line_id, time_window_start, aggregation_level)
) COMMENT = 'Quality control summary aggregations';

-- =====================================================
-- PREDICTIVE MAINTENANCE AGGREGATIONS
-- =====================================================

-- Predictive maintenance alerts and indicators
CREATE OR REPLACE TABLE AGG_PREDICTIVE_MAINTENANCE (
    equipment_id STRING,
    equipment_name STRING,
    equipment_type STRING,
    snapshot_timestamp TIMESTAMP_NTZ,
    
    -- Health indicators
    overall_health_score FLOAT, -- 0-100 scale
    health_trend STRING, -- 'IMPROVING', 'STABLE', 'DECLINING'
    
    -- Component health scores
    motor_health_score FLOAT,
    bearing_health_score FLOAT,
    belt_health_score FLOAT,
    sensor_health_score FLOAT,
    
    -- Failure predictions
    predicted_failure_days NUMBER,
    failure_probability_30_days FLOAT,
    failure_probability_60_days FLOAT,
    failure_probability_90_days FLOAT,
    
    -- Maintenance recommendations
    recommended_action STRING,
    maintenance_priority STRING, -- 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL'
    estimated_maintenance_cost FLOAT,
    estimated_downtime_hours FLOAT,
    
    -- Historical context
    days_since_last_maintenance NUMBER,
    next_scheduled_maintenance_date DATE,
    maintenance_overdue_days NUMBER,
    
    -- Alert flags
    temperature_alert BOOLEAN,
    vibration_alert BOOLEAN,
    pressure_alert BOOLEAN,
    efficiency_alert BOOLEAN,
    
    last_updated TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    
    CONSTRAINT PK_AGG_MAINTENANCE PRIMARY KEY (equipment_id, snapshot_timestamp)
) COMMENT = 'Predictive maintenance indicators and alerts';

-- =====================================================
-- REAL-TIME DASHBOARD METRICS
-- =====================================================

-- Current status dashboard
CREATE OR REPLACE TABLE AGG_REALTIME_DASHBOARD (
    snapshot_timestamp TIMESTAMP_NTZ,
    
    -- Overall facility metrics
    total_active_equipment NUMBER,
    equipment_online_count NUMBER,
    equipment_offline_count NUMBER,
    equipment_alert_count NUMBER,
    
    -- Production summary
    current_production_rate_per_hour FLOAT,
    today_units_produced NUMBER,
    today_production_target NUMBER,
    today_efficiency_percent FLOAT,
    
    -- Quality summary
    today_tests_conducted NUMBER,
    today_pass_rate_percent FLOAT,
    today_defect_rate FLOAT,
    
    -- Alerts and notifications
    critical_alerts_count NUMBER,
    high_priority_alerts_count NUMBER,
    medium_priority_alerts_count NUMBER,
    
    last_updated TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    
    CONSTRAINT PK_AGG_DASHBOARD PRIMARY KEY (snapshot_timestamp)
) COMMENT = 'Real-time dashboard summary metrics';

-- Create clustering keys for performance
ALTER TABLE AGG_EQUIPMENT_PERFORMANCE CLUSTER BY (time_window_start, equipment_id);
ALTER TABLE AGG_PRODUCTION_METRICS CLUSTER BY (time_window_start, line_id);
ALTER TABLE AGG_QUALITY_SUMMARY CLUSTER BY (time_window_start, product_id);
ALTER TABLE AGG_PREDICTIVE_MAINTENANCE CLUSTER BY (snapshot_timestamp, equipment_id);
ALTER TABLE AGG_REALTIME_DASHBOARD CLUSTER BY (snapshot_timestamp);

-- Grant permissions
GRANT SELECT ON ALL TABLES IN SCHEMA AGGREGATION TO PUBLIC;
GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA AGGREGATION TO PUBLIC; 