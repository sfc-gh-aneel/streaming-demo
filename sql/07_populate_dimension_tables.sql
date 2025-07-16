-- =====================================================
-- Populate Dimension Tables with Manufacturing Demo Data
-- =====================================================

USE DATABASE MANUFACTURING_DEMO;
USE SCHEMA ANALYTICS;
USE WAREHOUSE ANALYTICS_WH;

-- =====================================================
-- POPULATE EQUIPMENT DIMENSION
-- =====================================================

-- Clear existing data
DELETE FROM DIM_EQUIPMENT;

-- Insert equipment data
INSERT INTO DIM_EQUIPMENT (
    equipment_id, equipment_name, equipment_type, manufacturer, model, 
    installation_date, production_line_id, location, max_temperature, 
    max_pressure, max_speed, maintenance_schedule, is_active
) VALUES 
-- Line A Equipment
('EQ-001', 'Hydraulic Press A1', 'PRESS', 'Schuler Group', 'HP-5000', '2020-01-15', 'LINE-A', 'Building 1 - Bay A1', 200.0, 150.0, 1200.0, 'Weekly', TRUE),
('EQ-002', 'CNC Lathe A2', 'LATHE', 'Haas Automation', 'ST-30Y', '2019-06-10', 'LINE-A', 'Building 1 - Bay A2', 80.0, 50.0, 3000.0, 'Bi-weekly', TRUE),
('EQ-003', 'Assembly Robot A3', 'ROBOT', 'KUKA', 'KR 210 R2700', '2021-03-22', 'LINE-A', 'Building 1 - Bay A3', 70.0, 80.0, 2000.0, 'Monthly', TRUE),
('EQ-004', 'Quality Scanner A4', 'SCANNER', 'Cognex', 'In-Sight 9000', '2020-11-05', 'LINE-A', 'Building 1 - Bay A4', 60.0, 0.0, 0.0, 'Quarterly', TRUE),

-- Line B Equipment  
('EQ-005', 'Injection Molding B1', 'MOLDING', 'Engel Austria', 'e-motion 440/120', '2019-09-12', 'LINE-B', 'Building 1 - Bay B1', 280.0, 200.0, 500.0, 'Weekly', TRUE),
('EQ-006', 'Conveyor System B2', 'CONVEYOR', 'Dorner Manufacturing', 'AquaPruf 7400', '2020-04-18', 'LINE-B', 'Building 1 - Bay B2', 45.0, 0.0, 1500.0, 'Monthly', TRUE),
('EQ-007', 'Heat Treatment B3', 'FURNACE', 'Ipsen International', 'TITAN H 70/70/40', '2018-12-03', 'LINE-B', 'Building 1 - Bay B3', 800.0, 30.0, 0.0, 'Bi-weekly', TRUE),
('EQ-008', 'Packaging Robot B4', 'ROBOT', 'ABB', 'IRB 2600-20/1.65', '2021-07-14', 'LINE-B', 'Building 1 - Bay B4', 70.0, 80.0, 1800.0, 'Monthly', TRUE),

-- Line C Equipment
('EQ-009', 'Welding Station C1', 'WELDER', 'Lincoln Electric', 'Power Wave AC/DC 1000', '2020-02-28', 'LINE-C', 'Building 2 - Bay C1', 120.0, 40.0, 0.0, 'Weekly', TRUE),
('EQ-010', 'Grinding Machine C2', 'GRINDER', 'Studer', 'S33 CNC', '2019-10-16', 'LINE-C', 'Building 2 - Bay C2', 85.0, 60.0, 4000.0, 'Bi-weekly', TRUE),
('EQ-011', 'Paint Booth C3', 'PAINT', 'Durr Systems', 'EcoRP E043', '2021-01-09', 'LINE-C', 'Building 2 - Bay C3', 65.0, 25.0, 200.0, 'Monthly', TRUE),
('EQ-012', 'Final Inspection C4', 'INSPECTION', 'Hexagon Manufacturing', 'GLOBAL S 9/15/8', '2020-08-25', 'LINE-C', 'Building 2 - Bay C4', 25.0, 0.0, 0.0, 'Quarterly', TRUE);

-- =====================================================
-- POPULATE PRODUCTION LINE DIMENSION
-- =====================================================

-- Clear existing data
DELETE FROM DIM_PRODUCTION_LINE;

-- Insert production line data
INSERT INTO DIM_PRODUCTION_LINE (
    line_id, line_name, facility_name, shift_pattern, target_capacity_per_hour, product_type, is_active
) VALUES 
('LINE-A', 'Automotive Parts Line A', 'Main Manufacturing Facility', '3-Shift', 150, 'Automotive Components', TRUE),
('LINE-B', 'Consumer Electronics Line B', 'Main Manufacturing Facility', '2-Shift', 300, 'Electronics', TRUE),
('LINE-C', 'Heavy Machinery Line C', 'Secondary Facility', '2-Shift', 75, 'Industrial Equipment', TRUE),
('LINE-D', 'Medical Devices Line D', 'Clean Room Facility', '3-Shift', 200, 'Medical Devices', TRUE);

-- =====================================================
-- POPULATE PRODUCT DIMENSION  
-- =====================================================

-- Clear existing data
DELETE FROM DIM_PRODUCT;

-- Insert product data
INSERT INTO DIM_PRODUCT (
    product_id, product_name, product_category, unit_of_measure, standard_cost, target_quality_score, is_active
) VALUES 
-- Automotive Products
('PROD-001', 'Brake Disc Assembly', 'Automotive', 'Each', 45.50, 98.5, TRUE),
('PROD-002', 'Engine Mount Bracket', 'Automotive', 'Each', 28.75, 99.2, TRUE),
('PROD-003', 'Transmission Housing', 'Automotive', 'Each', 156.80, 97.8, TRUE),
('PROD-004', 'Suspension Arm', 'Automotive', 'Each', 89.25, 98.9, TRUE),

-- Electronics Products
('PROD-005', 'Smartphone Camera Module', 'Electronics', 'Each', 12.40, 99.5, TRUE),
('PROD-006', 'PCB Main Board', 'Electronics', 'Each', 18.90, 98.7, TRUE),
('PROD-007', 'Battery Pack Assembly', 'Electronics', 'Each', 34.60, 99.1, TRUE),
('PROD-008', 'Display Screen Unit', 'Electronics', 'Each', 67.30, 97.9, TRUE),

-- Industrial Products
('PROD-009', 'Hydraulic Cylinder', 'Industrial', 'Each', 234.75, 98.2, TRUE),
('PROD-010', 'Gear Box Assembly', 'Industrial', 'Each', 445.90, 99.0, TRUE),
('PROD-011', 'Motor Control Unit', 'Industrial', 'Each', 189.50, 98.6, TRUE),
('PROD-012', 'Safety Valve', 'Industrial', 'Each', 78.65, 99.3, TRUE),

-- Medical Products
('PROD-013', 'Surgical Instrument Handle', 'Medical', 'Each', 95.20, 99.8, TRUE),
('PROD-014', 'Implant Component', 'Medical', 'Each', 1250.00, 99.9, TRUE),
('PROD-015', 'Diagnostic Sensor', 'Medical', 'Each', 345.75, 99.6, TRUE),
('PROD-016', 'Medical Device Housing', 'Medical', 'Each', 156.40, 99.4, TRUE);

-- =====================================================
-- POPULATE TIME DIMENSION
-- =====================================================

-- Clear existing data  
DELETE FROM DIM_TIME;

-- Insert time dimension data for the current month plus some history
INSERT INTO DIM_TIME (
    time_key, full_date, year_number, quarter_number, month_number, month_name,
    week_number, day_of_year, day_of_month, day_of_week, day_name,
    hour_number, minute_number, is_weekend, is_holiday, shift_name
)
WITH date_sequence AS (
    SELECT 
        DATEADD('day', ROW_NUMBER() OVER (ORDER BY 1) - 1, '2024-01-01') as date_value
    FROM TABLE(GENERATOR(ROWCOUNT => 365)) -- Generate 365 days
),
time_combinations AS (
    SELECT 
        d.date_value,
        h.hour_value,
        m.minute_value
    FROM date_sequence d
    CROSS JOIN (SELECT 0 as hour_value UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20 UNION SELECT 21 UNION SELECT 22 UNION SELECT 23) h
    CROSS JOIN (SELECT 0 as minute_value UNION SELECT 15 UNION SELECT 30 UNION SELECT 45) m
    WHERE d.date_value <= CURRENT_DATE() + 30 -- Current date plus 30 days future
)
SELECT 
    YEAR(date_value) * 100000000 + MONTH(date_value) * 1000000 + DAY(date_value) * 10000 + hour_value * 100 + minute_value as time_key,
    date_value as full_date,
    YEAR(date_value) as year_number,
    QUARTER(date_value) as quarter_number,
    MONTH(date_value) as month_number,
    MONTHNAME(date_value) as month_name,
    WEEKOFYEAR(date_value) as week_number,
    DAYOFYEAR(date_value) as day_of_year,
    DAY(date_value) as day_of_month,
    DAYOFWEEK(date_value) as day_of_week,
    DAYNAME(date_value) as day_name,
    hour_value as hour_number,
    minute_value as minute_number,
    CASE WHEN DAYOFWEEK(date_value) IN (1, 7) THEN TRUE ELSE FALSE END as is_weekend,
    CASE 
        WHEN (MONTH(date_value) = 1 AND DAY(date_value) = 1) THEN TRUE  -- New Year
        WHEN (MONTH(date_value) = 7 AND DAY(date_value) = 4) THEN TRUE  -- Independence Day
        WHEN (MONTH(date_value) = 12 AND DAY(date_value) = 25) THEN TRUE -- Christmas
        ELSE FALSE 
    END as is_holiday,
    CASE 
        WHEN hour_value >= 6 AND hour_value < 14 THEN 'DAY_SHIFT'
        WHEN hour_value >= 14 AND hour_value < 22 THEN 'AFTERNOON_SHIFT'
        ELSE 'NIGHT_SHIFT'
    END as shift_name
FROM time_combinations;

-- =====================================================
-- CREATE SAMPLE FACT DATA (RECENT DATA FOR TESTING)
-- =====================================================

-- Add some recent sensor readings for immediate testing
INSERT INTO FACT_SENSOR_READINGS (
    equipment_key, time_key, timestamp_utc, sensor_type, temperature, pressure, 
    vibration, speed_rpm, power_consumption, efficiency_percent, status, alert_level
)
SELECT 
    e.equipment_key,
    t.time_key,
    DATEADD('minute', t.minute_number, DATEADD('hour', t.hour_number, t.full_date)) as timestamp_utc,
    'TEMPERATURE' as sensor_type,
    -- Realistic temperature based on equipment type
    CASE 
        WHEN e.equipment_type = 'FURNACE' THEN UNIFORM(650, 750, RANDOM())
        WHEN e.equipment_type = 'PRESS' THEN UNIFORM(45, 65, RANDOM())
        WHEN e.equipment_type = 'MOLDING' THEN UNIFORM(180, 220, RANDOM())
        ELSE UNIFORM(20, 45, RANDOM())
    END as temperature,
    -- Realistic pressure
    CASE 
        WHEN e.equipment_type = 'PRESS' THEN UNIFORM(100, 140, RANDOM())
        WHEN e.equipment_type = 'MOLDING' THEN UNIFORM(150, 190, RANDOM())
        ELSE UNIFORM(10, 40, RANDOM())
    END as pressure,
    UNIFORM(0.1, 0.8, RANDOM()) as vibration,
    CASE 
        WHEN e.max_speed > 0 THEN e.max_speed * (0.7 + UNIFORM(0, 0.25, RANDOM()))
        ELSE 0
    END as speed_rpm,
    UNIFORM(5.5, 45.8, RANDOM()) as power_consumption,
    UNIFORM(85.0, 99.5, RANDOM()) as efficiency_percent,
    'RUNNING' as status,
    'NORMAL' as alert_level
FROM DIM_EQUIPMENT e
CROSS JOIN DIM_TIME t
WHERE t.full_date >= CURRENT_DATE() - 1  -- Last 24 hours
AND t.full_date <= CURRENT_DATE()
AND MOD(t.time_key, 4) = 0  -- Every hour (reduce volume)
LIMIT 1000;

-- Add some production data
INSERT INTO FACT_PRODUCTION (
    equipment_key, line_key, product_key, time_key, timestamp_utc, event_type,
    units_produced, planned_units, cycle_time_seconds, downtime_minutes, 
    reject_count, operator_id, batch_id
)
SELECT 
    e.equipment_key,
    l.line_key,
    p.product_key,
    t.time_key,
    DATEADD('minute', t.minute_number, DATEADD('hour', t.hour_number, t.full_date)) as timestamp_utc,
    'PRODUCTION' as event_type,
    ROUND(l.target_capacity_per_hour * (0.8 + UNIFORM(0, 0.3, RANDOM())) / 4) as units_produced, -- Per 15 min
    ROUND(l.target_capacity_per_hour / 4) as planned_units, -- Per 15 min
    UNIFORM(45.0, 180.0, RANDOM()) as cycle_time_seconds,
    CASE WHEN UNIFORM(0, 1, RANDOM()) < 0.05 THEN UNIFORM(1, 15, RANDOM()) ELSE 0 END as downtime_minutes,
    CASE WHEN UNIFORM(0, 1, RANDOM()) < 0.02 THEN ROUND(UNIFORM(1, 5, RANDOM())) ELSE 0 END as reject_count,
    'OP-' || LPAD(UNIFORM(1, 20, RANDOM()), 3, '0') as operator_id,
    'BATCH-' || DATE_PART('year', t.full_date) || LPAD(DATE_PART('dayofyear', t.full_date), 3, '0') || '-' || LPAD(UNIFORM(1, 99, RANDOM()), 2, '0') as batch_id
FROM DIM_EQUIPMENT e
JOIN DIM_PRODUCTION_LINE l ON e.production_line_id = l.line_id
CROSS JOIN DIM_PRODUCT p
CROSS JOIN DIM_TIME t
WHERE t.full_date >= CURRENT_DATE() - 1
AND t.full_date <= CURRENT_DATE()
AND MOD(t.time_key, 4) = 0  -- Every hour
AND UNIFORM(0, 1, RANDOM()) < 0.3  -- 30% probability to reduce volume
LIMIT 500;

-- Add some quality data
INSERT INTO FACT_QUALITY (
    equipment_key, product_key, time_key, timestamp_utc, test_type,
    measurement_value, specification_min, specification_max, is_within_spec,
    defect_type, inspector_id, batch_id, sample_size
)
SELECT 
    e.equipment_key,
    p.product_key,
    t.time_key,
    DATEADD('minute', t.minute_number, DATEADD('hour', t.hour_number, t.full_date)) as timestamp_utc,
    'DIMENSIONAL_CHECK' as test_type,
    UNIFORM(9.8, 10.2, RANDOM()) as measurement_value,
    9.9 as specification_min,
    10.1 as specification_max,
    CASE WHEN UNIFORM(9.8, 10.2, RANDOM()) BETWEEN 9.9 AND 10.1 THEN TRUE ELSE FALSE END as is_within_spec,
    CASE 
        WHEN UNIFORM(0, 1, RANDOM()) < 0.03 THEN 
            CASE ROUND(UNIFORM(1, 5, RANDOM()))
                WHEN 1 THEN 'SURFACE_DEFECT'
                WHEN 2 THEN 'DIMENSIONAL_ERROR'
                WHEN 3 THEN 'MATERIAL_DEFECT'
                WHEN 4 THEN 'ASSEMBLY_ERROR'
                ELSE 'OTHER_DEFECT'
            END
        ELSE NULL
    END as defect_type,
    'QC-' || LPAD(UNIFORM(1, 10, RANDOM()), 2, '0') as inspector_id,
    'BATCH-' || DATE_PART('year', t.full_date) || LPAD(DATE_PART('dayofyear', t.full_date), 3, '0') || '-' || LPAD(UNIFORM(1, 99, RANDOM()), 2, '0') as batch_id,
    ROUND(UNIFORM(5, 25, RANDOM())) as sample_size
FROM DIM_EQUIPMENT e
CROSS JOIN DIM_PRODUCT p
CROSS JOIN DIM_TIME t
WHERE t.full_date >= CURRENT_DATE() - 1
AND t.full_date <= CURRENT_DATE()
AND MOD(t.time_key, 8) = 0  -- Every 2 hours
AND UNIFORM(0, 1, RANDOM()) < 0.4  -- 40% probability
LIMIT 300;

-- =====================================================
-- CREATE SAMPLE PREDICTIVE MAINTENANCE DATA
-- =====================================================

INSERT INTO AGGREGATION.AGG_PREDICTIVE_MAINTENANCE (
    equipment_id, equipment_name, equipment_type, snapshot_timestamp,
    overall_health_score, health_trend, motor_health_score, bearing_health_score,
    belt_health_score, sensor_health_score, predicted_failure_days,
    failure_probability_30_days, failure_probability_60_days, failure_probability_90_days,
    recommended_action, maintenance_priority, estimated_maintenance_cost, estimated_downtime_hours,
    days_since_last_maintenance, next_scheduled_maintenance_date, maintenance_overdue_days,
    temperature_alert, vibration_alert, pressure_alert, efficiency_alert
)
SELECT 
    e.equipment_id,
    e.equipment_name,
    e.equipment_type,
    CURRENT_TIMESTAMP() as snapshot_timestamp,
    UNIFORM(60.0, 98.0, RANDOM()) as overall_health_score,
    CASE ROUND(UNIFORM(1, 3, RANDOM()))
        WHEN 1 THEN 'IMPROVING'
        WHEN 2 THEN 'STABLE'
        ELSE 'DECLINING'
    END as health_trend,
    UNIFORM(70.0, 99.0, RANDOM()) as motor_health_score,
    UNIFORM(65.0, 95.0, RANDOM()) as bearing_health_score,
    UNIFORM(75.0, 98.0, RANDOM()) as belt_health_score,
    UNIFORM(80.0, 99.0, RANDOM()) as sensor_health_score,
    ROUND(UNIFORM(30, 365, RANDOM())) as predicted_failure_days,
    UNIFORM(0.01, 0.15, RANDOM()) as failure_probability_30_days,
    UNIFORM(0.05, 0.25, RANDOM()) as failure_probability_60_days,
    UNIFORM(0.10, 0.35, RANDOM()) as failure_probability_90_days,
    CASE ROUND(UNIFORM(1, 4, RANDOM()))
        WHEN 1 THEN 'Schedule routine maintenance'
        WHEN 2 THEN 'Monitor vibration levels'
        WHEN 3 THEN 'Replace worn components'
        ELSE 'Inspect and calibrate'
    END as recommended_action,
    CASE 
        WHEN UNIFORM(60.0, 98.0, RANDOM()) < 70 THEN 'CRITICAL'
        WHEN UNIFORM(60.0, 98.0, RANDOM()) < 80 THEN 'HIGH'
        WHEN UNIFORM(60.0, 98.0, RANDOM()) < 90 THEN 'MEDIUM'
        ELSE 'LOW'
    END as maintenance_priority,
    UNIFORM(500.0, 5000.0, RANDOM()) as estimated_maintenance_cost,
    UNIFORM(2.0, 24.0, RANDOM()) as estimated_downtime_hours,
    ROUND(UNIFORM(1, 180, RANDOM())) as days_since_last_maintenance,
    DATEADD('day', ROUND(UNIFORM(7, 60, RANDOM())), CURRENT_DATE()) as next_scheduled_maintenance_date,
    CASE WHEN UNIFORM(0, 1, RANDOM()) < 0.1 THEN ROUND(UNIFORM(1, 30, RANDOM())) ELSE 0 END as maintenance_overdue_days,
    CASE WHEN UNIFORM(0, 1, RANDOM()) < 0.1 THEN TRUE ELSE FALSE END as temperature_alert,
    CASE WHEN UNIFORM(0, 1, RANDOM()) < 0.05 THEN TRUE ELSE FALSE END as vibration_alert,
    CASE WHEN UNIFORM(0, 1, RANDOM()) < 0.08 THEN TRUE ELSE FALSE END as pressure_alert,
    CASE WHEN UNIFORM(0, 1, RANDOM()) < 0.12 THEN TRUE ELSE FALSE END as efficiency_alert
FROM DIM_EQUIPMENT e;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Show populated data counts
SELECT 'DIM_EQUIPMENT' as table_name, COUNT(*) as row_count FROM DIM_EQUIPMENT
UNION ALL
SELECT 'DIM_PRODUCTION_LINE', COUNT(*) FROM DIM_PRODUCTION_LINE  
UNION ALL
SELECT 'DIM_PRODUCT', COUNT(*) FROM DIM_PRODUCT
UNION ALL
SELECT 'DIM_TIME', COUNT(*) FROM DIM_TIME
UNION ALL
SELECT 'FACT_SENSOR_READINGS', COUNT(*) FROM FACT_SENSOR_READINGS
UNION ALL
SELECT 'FACT_PRODUCTION', COUNT(*) FROM FACT_PRODUCTION
UNION ALL
SELECT 'FACT_QUALITY', COUNT(*) FROM FACT_QUALITY
UNION ALL
SELECT 'AGG_PREDICTIVE_MAINTENANCE', COUNT(*) FROM AGGREGATION.AGG_PREDICTIVE_MAINTENANCE;

-- Sample data preview
SELECT 'Equipment Sample:' as info;
SELECT equipment_id, equipment_name, equipment_type, production_line_id FROM DIM_EQUIPMENT LIMIT 5;

SELECT 'Production Line Sample:' as info;
SELECT line_id, line_name, target_capacity_per_hour, product_type FROM DIM_PRODUCTION_LINE;

SELECT 'Product Sample:' as info;
SELECT product_id, product_name, product_category, standard_cost FROM DIM_PRODUCT LIMIT 5;

COMMIT; 