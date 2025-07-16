-- =====================================================
-- Star Schema for Manufacturing Analytics
-- =====================================================

USE DATABASE MANUFACTURING_DEMO;
USE SCHEMA ANALYTICS;
USE WAREHOUSE STREAMING_WH;

-- =====================================================
-- DIMENSION TABLES
-- =====================================================

-- Equipment dimension
CREATE OR REPLACE TABLE DIM_EQUIPMENT (
    equipment_key NUMBER AUTOINCREMENT,
    equipment_id STRING NOT NULL,
    equipment_name STRING,
    equipment_type STRING,
    manufacturer STRING,
    model STRING,
    installation_date DATE,
    production_line_id STRING,
    location STRING,
    max_temperature FLOAT,
    max_pressure FLOAT,
    max_speed FLOAT,
    maintenance_schedule STRING,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT PK_DIM_EQUIPMENT PRIMARY KEY (equipment_key)
) COMMENT = 'Equipment master dimension';

-- Production Line dimension
CREATE OR REPLACE TABLE DIM_PRODUCTION_LINE (
    line_key NUMBER AUTOINCREMENT,
    line_id STRING NOT NULL,
    line_name STRING,
    facility_name STRING,
    shift_pattern STRING,
    target_capacity_per_hour NUMBER,
    product_type STRING,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT PK_DIM_PRODUCTION_LINE PRIMARY KEY (line_key)
) COMMENT = 'Production line dimension';

-- Time dimension
CREATE OR REPLACE TABLE DIM_TIME (
    time_key NUMBER,
    full_date DATE,
    year_number NUMBER,
    quarter_number NUMBER,
    month_number NUMBER,
    month_name STRING,
    week_number NUMBER,
    day_of_year NUMBER,
    day_of_month NUMBER,
    day_of_week NUMBER,
    day_name STRING,
    hour_number NUMBER,
    minute_number NUMBER,
    is_weekend BOOLEAN,
    is_holiday BOOLEAN,
    shift_name STRING,
    CONSTRAINT PK_DIM_TIME PRIMARY KEY (time_key)
) COMMENT = 'Time dimension with manufacturing shift information';

-- Product dimension
CREATE OR REPLACE TABLE DIM_PRODUCT (
    product_key NUMBER AUTOINCREMENT,
    product_id STRING NOT NULL,
    product_name STRING,
    product_category STRING,
    unit_of_measure STRING,
    standard_cost FLOAT,
    target_quality_score FLOAT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT PK_DIM_PRODUCT PRIMARY KEY (product_key)
) COMMENT = 'Product master dimension';

-- =====================================================
-- FACT TABLES
-- =====================================================

-- Sensor readings fact table
CREATE OR REPLACE TABLE FACT_SENSOR_READINGS (
    sensor_reading_key NUMBER AUTOINCREMENT,
    equipment_key NUMBER,
    time_key NUMBER,
    timestamp_utc TIMESTAMP_NTZ,
    sensor_type STRING,
    temperature FLOAT,
    pressure FLOAT,
    vibration FLOAT,
    speed_rpm FLOAT,
    power_consumption FLOAT,
    efficiency_percent FLOAT,
    status STRING,
    alert_level STRING,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT PK_FACT_SENSOR_READINGS PRIMARY KEY (sensor_reading_key),
    CONSTRAINT FK_SENSOR_EQUIPMENT FOREIGN KEY (equipment_key) REFERENCES DIM_EQUIPMENT(equipment_key),
    CONSTRAINT FK_SENSOR_TIME FOREIGN KEY (time_key) REFERENCES DIM_TIME(time_key)
) COMMENT = 'Sensor readings fact table';

-- Production events fact table
CREATE OR REPLACE TABLE FACT_PRODUCTION (
    production_key NUMBER AUTOINCREMENT,
    equipment_key NUMBER,
    line_key NUMBER,
    product_key NUMBER,
    time_key NUMBER,
    timestamp_utc TIMESTAMP_NTZ,
    event_type STRING,
    units_produced NUMBER,
    planned_units NUMBER,
    cycle_time_seconds FLOAT,
    downtime_minutes FLOAT,
    reject_count NUMBER,
    operator_id STRING,
    batch_id STRING,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT PK_FACT_PRODUCTION PRIMARY KEY (production_key),
    CONSTRAINT FK_PROD_EQUIPMENT FOREIGN KEY (equipment_key) REFERENCES DIM_EQUIPMENT(equipment_key),
    CONSTRAINT FK_PROD_LINE FOREIGN KEY (line_key) REFERENCES DIM_PRODUCTION_LINE(line_key),
    CONSTRAINT FK_PROD_PRODUCT FOREIGN KEY (product_key) REFERENCES DIM_PRODUCT(product_key),
    CONSTRAINT FK_PROD_TIME FOREIGN KEY (time_key) REFERENCES DIM_TIME(time_key)
) COMMENT = 'Production events and metrics fact table';

-- Quality control fact table
CREATE OR REPLACE TABLE FACT_QUALITY (
    quality_key NUMBER AUTOINCREMENT,
    equipment_key NUMBER,
    product_key NUMBER,
    time_key NUMBER,
    timestamp_utc TIMESTAMP_NTZ,
    test_type STRING,
    measurement_value FLOAT,
    specification_min FLOAT,
    specification_max FLOAT,
    is_within_spec BOOLEAN,
    defect_type STRING,
    inspector_id STRING,
    batch_id STRING,
    sample_size NUMBER,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT PK_FACT_QUALITY PRIMARY KEY (quality_key),
    CONSTRAINT FK_QUALITY_EQUIPMENT FOREIGN KEY (equipment_key) REFERENCES DIM_EQUIPMENT(equipment_key),
    CONSTRAINT FK_QUALITY_PRODUCT FOREIGN KEY (product_key) REFERENCES DIM_PRODUCT(product_key),
    CONSTRAINT FK_QUALITY_TIME FOREIGN KEY (time_key) REFERENCES DIM_TIME(time_key)
) COMMENT = 'Quality control measurements and test results';

-- Create clustering keys for performance
ALTER TABLE FACT_SENSOR_READINGS CLUSTER BY (timestamp_utc, equipment_key);
ALTER TABLE FACT_PRODUCTION CLUSTER BY (timestamp_utc, line_key);
ALTER TABLE FACT_QUALITY CLUSTER BY (timestamp_utc, product_key);

-- Grant permissions
GRANT SELECT ON ALL TABLES IN SCHEMA ANALYTICS TO PUBLIC;
GRANT INSERT, UPDATE ON ALL TABLES IN SCHEMA ANALYTICS TO PUBLIC; 