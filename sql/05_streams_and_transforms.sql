-- =====================================================
-- Streams and Transformation Logic for Low-Latency Processing
-- =====================================================

USE DATABASE MANUFACTURING_DEMO;
USE WAREHOUSE STREAMING_WH;

-- =====================================================
-- CREATE STREAMS FOR CHANGE DATA CAPTURE
-- =====================================================

-- Stream on sensor data
USE SCHEMA RAW_DATA;
CREATE OR REPLACE STREAM SENSOR_DATA_STREAM ON TABLE SENSOR_DATA_RAW
COMMENT = 'Stream to capture changes in sensor data';

-- Stream on production data
CREATE OR REPLACE STREAM PRODUCTION_DATA_STREAM ON TABLE PRODUCTION_DATA_RAW
COMMENT = 'Stream to capture changes in production data';

-- Stream on quality data
CREATE OR REPLACE STREAM QUALITY_DATA_STREAM ON TABLE QUALITY_DATA_RAW
COMMENT = 'Stream to capture changes in quality data';

-- =====================================================
-- HELPER FUNCTIONS FOR DATA TRANSFORMATION
-- =====================================================

USE SCHEMA UTILITIES;

-- Function to convert timestamp to time key
CREATE OR REPLACE FUNCTION GET_TIME_KEY(input_timestamp TIMESTAMP_NTZ)
RETURNS NUMBER
LANGUAGE SQL
AS
$$
    SELECT 
        YEAR(input_timestamp) * 100000000 +
        MONTH(input_timestamp) * 1000000 +
        DAY(input_timestamp) * 10000 +
        HOUR(input_timestamp) * 100 +
        MINUTE(input_timestamp)
$$;

-- Function to determine shift based on hour
CREATE OR REPLACE FUNCTION GET_SHIFT_NAME(input_hour NUMBER)
RETURNS STRING
LANGUAGE SQL
AS
$$
    CASE 
        WHEN input_hour >= 6 AND input_hour < 14 THEN 'DAY_SHIFT'
        WHEN input_hour >= 14 AND input_hour < 22 THEN 'AFTERNOON_SHIFT'
        ELSE 'NIGHT_SHIFT'
    END
$$;

-- Function to calculate equipment health score
CREATE OR REPLACE FUNCTION CALCULATE_HEALTH_SCORE(
    temperature FLOAT, 
    max_temp FLOAT,
    pressure FLOAT, 
    max_pressure FLOAT,
    vibration FLOAT,
    efficiency FLOAT
)
RETURNS FLOAT
LANGUAGE SQL
AS
$$
    GREATEST(0, LEAST(100,
        (100 - (temperature / max_temp * 30)) +
        (100 - (pressure / max_pressure * 25)) +
        (100 - (vibration * 20)) +
        (efficiency * 0.25)
    ))
$$;

-- =====================================================
-- TRANSFORMATION STORED PROCEDURES
-- =====================================================

-- Transform sensor data to fact table
CREATE OR REPLACE PROCEDURE TRANSFORM_SENSOR_DATA()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    -- Transform sensor data from stream to analytics schema
    INSERT INTO ANALYTICS.FACT_SENSOR_READINGS (
        equipment_key,
        time_key,
        timestamp_utc,
        sensor_type,
        temperature,
        pressure,
        vibration,
        speed_rpm,
        power_consumption,
        efficiency_percent,
        status,
        alert_level
    )
    SELECT 
        e.equipment_key,
        UTILITIES.GET_TIME_KEY(s.raw_data:timestamp::TIMESTAMP_NTZ) as time_key,
        s.raw_data:timestamp::TIMESTAMP_NTZ as timestamp_utc,
        s.raw_data:sensor_type::STRING as sensor_type,
        s.raw_data:temperature::FLOAT as temperature,
        s.raw_data:pressure::FLOAT as pressure,
        s.raw_data:vibration::FLOAT as vibration,
        s.raw_data:speed_rpm::FLOAT as speed_rpm,
        s.raw_data:power_consumption::FLOAT as power_consumption,
        s.raw_data:efficiency_percent::FLOAT as efficiency_percent,
        s.raw_data:status::STRING as status,
        CASE 
            WHEN s.raw_data:temperature::FLOAT > e.max_temperature * 0.9 THEN 'HIGH'
            WHEN s.raw_data:pressure::FLOAT > e.max_pressure * 0.9 THEN 'HIGH'
            WHEN s.raw_data:vibration::FLOAT > 0.8 THEN 'MEDIUM'
            WHEN s.raw_data:efficiency_percent::FLOAT < 70 THEN 'MEDIUM'
            ELSE 'NORMAL'
        END as alert_level
    FROM RAW_DATA.SENSOR_DATA_STREAM s
    LEFT JOIN ANALYTICS.DIM_EQUIPMENT e ON s.raw_data:equipment_id::STRING = e.equipment_id
    WHERE s.METADATA$ACTION = 'INSERT'
    AND s.raw_data:equipment_id IS NOT NULL;
    
    RETURN 'Sensor data transformation completed. Rows processed: ' || SQLROWCOUNT;
END;
$$;

-- Transform production data to fact table
CREATE OR REPLACE PROCEDURE TRANSFORM_PRODUCTION_DATA()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    INSERT INTO ANALYTICS.FACT_PRODUCTION (
        equipment_key,
        line_key,
        product_key,
        time_key,
        timestamp_utc,
        event_type,
        units_produced,
        planned_units,
        cycle_time_seconds,
        downtime_minutes,
        reject_count,
        operator_id,
        batch_id
    )
    SELECT 
        e.equipment_key,
        l.line_key,
        p.product_key,
        UTILITIES.GET_TIME_KEY(prod.raw_data:timestamp::TIMESTAMP_NTZ) as time_key,
        prod.raw_data:timestamp::TIMESTAMP_NTZ as timestamp_utc,
        prod.raw_data:event_type::STRING as event_type,
        prod.raw_data:units_produced::NUMBER as units_produced,
        prod.raw_data:planned_units::NUMBER as planned_units,
        prod.raw_data:cycle_time_seconds::FLOAT as cycle_time_seconds,
        prod.raw_data:downtime_minutes::FLOAT as downtime_minutes,
        prod.raw_data:reject_count::NUMBER as reject_count,
        prod.raw_data:operator_id::STRING as operator_id,
        prod.raw_data:batch_id::STRING as batch_id
    FROM RAW_DATA.PRODUCTION_DATA_STREAM prod
    LEFT JOIN ANALYTICS.DIM_EQUIPMENT e ON prod.raw_data:equipment_id::STRING = e.equipment_id
    LEFT JOIN ANALYTICS.DIM_PRODUCTION_LINE l ON prod.raw_data:line_id::STRING = l.line_id
    LEFT JOIN ANALYTICS.DIM_PRODUCT p ON prod.raw_data:product_id::STRING = p.product_id
    WHERE prod.METADATA$ACTION = 'INSERT'
    AND prod.raw_data:equipment_id IS NOT NULL;
    
    RETURN 'Production data transformation completed. Rows processed: ' || SQLROWCOUNT;
END;
$$;

-- Transform quality data to fact table
CREATE OR REPLACE PROCEDURE TRANSFORM_QUALITY_DATA()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    INSERT INTO ANALYTICS.FACT_QUALITY (
        equipment_key,
        product_key,
        time_key,
        timestamp_utc,
        test_type,
        measurement_value,
        specification_min,
        specification_max,
        is_within_spec,
        defect_type,
        inspector_id,
        batch_id,
        sample_size
    )
    SELECT 
        e.equipment_key,
        p.product_key,
        UTILITIES.GET_TIME_KEY(q.raw_data:timestamp::TIMESTAMP_NTZ) as time_key,
        q.raw_data:timestamp::TIMESTAMP_NTZ as timestamp_utc,
        q.raw_data:test_type::STRING as test_type,
        q.raw_data:measurement_value::FLOAT as measurement_value,
        q.raw_data:specification_min::FLOAT as specification_min,
        q.raw_data:specification_max::FLOAT as specification_max,
        (q.raw_data:measurement_value::FLOAT BETWEEN 
         q.raw_data:specification_min::FLOAT AND 
         q.raw_data:specification_max::FLOAT) as is_within_spec,
        q.raw_data:defect_type::STRING as defect_type,
        q.raw_data:inspector_id::STRING as inspector_id,
        q.raw_data:batch_id::STRING as batch_id,
        q.raw_data:sample_size::NUMBER as sample_size
    FROM RAW_DATA.QUALITY_DATA_STREAM q
    LEFT JOIN ANALYTICS.DIM_EQUIPMENT e ON q.raw_data:equipment_id::STRING = e.equipment_id
    LEFT JOIN ANALYTICS.DIM_PRODUCT p ON q.raw_data:product_id::STRING = p.product_id
    WHERE q.METADATA$ACTION = 'INSERT'
    AND q.raw_data:product_id IS NOT NULL;
    
    RETURN 'Quality data transformation completed. Rows processed: ' || SQLROWCOUNT;
END;
$$;

-- Master transformation procedure
CREATE OR REPLACE PROCEDURE TRANSFORM_ALL_DATA()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    sensor_result STRING;
    production_result STRING;
    quality_result STRING;
BEGIN
    -- Transform all data types
    CALL TRANSFORM_SENSOR_DATA() INTO sensor_result;
    CALL TRANSFORM_PRODUCTION_DATA() INTO production_result;
    CALL TRANSFORM_QUALITY_DATA() INTO quality_result;
    
    RETURN 'All transformations completed. ' || 
           sensor_result || '; ' || 
           production_result || '; ' || 
           quality_result;
END;
$$;

-- =====================================================
-- CREATE TASKS FOR LOW-LATENCY PROCESSING
-- =====================================================

-- Task to process sensor data every minute
CREATE OR REPLACE TASK PROCESS_SENSOR_DATA_TASK
    WAREHOUSE = STREAMING_WH
    SCHEDULE = '1 MINUTE'
    WHEN SYSTEM$STREAM_HAS_DATA('RAW_DATA.SENSOR_DATA_STREAM')
AS
    CALL UTILITIES.TRANSFORM_SENSOR_DATA();

-- Task to process production data every minute
CREATE OR REPLACE TASK PROCESS_PRODUCTION_DATA_TASK
    WAREHOUSE = STREAMING_WH
    SCHEDULE = '1 MINUTE'
    WHEN SYSTEM$STREAM_HAS_DATA('RAW_DATA.PRODUCTION_DATA_STREAM')
AS
    CALL UTILITIES.TRANSFORM_PRODUCTION_DATA();

-- Task to process quality data every minute
CREATE OR REPLACE TASK PROCESS_QUALITY_DATA_TASK
    WAREHOUSE = STREAMING_WH
    SCHEDULE = '1 MINUTE'
    WHEN SYSTEM$STREAM_HAS_DATA('RAW_DATA.QUALITY_DATA_STREAM')
AS
    CALL UTILITIES.TRANSFORM_QUALITY_DATA();

-- Resume all tasks
ALTER TASK PROCESS_SENSOR_DATA_TASK RESUME;
ALTER TASK PROCESS_PRODUCTION_DATA_TASK RESUME;
ALTER TASK PROCESS_QUALITY_DATA_TASK RESUME;

-- Show task status
SHOW TASKS;

-- Grant permissions
GRANT USAGE ON ALL PROCEDURES IN SCHEMA UTILITIES TO PUBLIC;
GRANT USAGE ON ALL FUNCTIONS IN SCHEMA UTILITIES TO PUBLIC; 