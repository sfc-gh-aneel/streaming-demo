-- =====================================================
-- Raw Data Tables for Manufacturing Streaming Demo
-- =====================================================

USE DATABASE MANUFACTURING_DEMO;
USE SCHEMA RAW_DATA;
USE WAREHOUSE STREAMING_WH;

-- Raw sensor data table
CREATE OR REPLACE TABLE SENSOR_DATA_RAW (
    raw_data VARIANT,
    file_name STRING,
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) COMMENT = 'Raw sensor data from manufacturing equipment';

-- Raw production data table  
CREATE OR REPLACE TABLE PRODUCTION_DATA_RAW (
    raw_data VARIANT,
    file_name STRING,
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) COMMENT = 'Raw production metrics and events';

-- Raw quality control data table
CREATE OR REPLACE TABLE QUALITY_DATA_RAW (
    raw_data VARIANT,
    file_name STRING,
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) COMMENT = 'Raw quality control measurements and test results';

-- Create clustering keys for better performance
ALTER TABLE SENSOR_DATA_RAW CLUSTER BY (load_timestamp);
ALTER TABLE PRODUCTION_DATA_RAW CLUSTER BY (load_timestamp);
ALTER TABLE QUALITY_DATA_RAW CLUSTER BY (load_timestamp);

-- Create Snowpipes for auto-ingestion
CREATE OR REPLACE PIPE SENSOR_PIPE 
AUTO_INGEST = TRUE
AS 
COPY INTO SENSOR_DATA_RAW (raw_data, file_name)
FROM (
    SELECT 
        $1,
        METADATA$FILENAME
    FROM @MANUFACTURING_STAGE/sensor_data/
)
FILE_FORMAT = JSON_FORMAT
COMMENT = 'Auto-ingestion pipe for sensor data';

CREATE OR REPLACE PIPE PRODUCTION_PIPE 
AUTO_INGEST = TRUE
AS 
COPY INTO PRODUCTION_DATA_RAW (raw_data, file_name)
FROM (
    SELECT 
        $1,
        METADATA$FILENAME
    FROM @MANUFACTURING_STAGE/production_data/
)
FILE_FORMAT = JSON_FORMAT
COMMENT = 'Auto-ingestion pipe for production data';

CREATE OR REPLACE PIPE QUALITY_PIPE 
AUTO_INGEST = TRUE
AS 
COPY INTO QUALITY_DATA_RAW (raw_data, file_name)
FROM (
    SELECT 
        $1,
        METADATA$FILENAME
    FROM @MANUFACTURING_STAGE/quality_data/
)
FILE_FORMAT = JSON_FORMAT
COMMENT = 'Auto-ingestion pipe for quality data';

-- Show pipe status
SHOW PIPES;

-- Grant permissions
GRANT SELECT, INSERT ON TABLE SENSOR_DATA_RAW TO PUBLIC;
GRANT SELECT, INSERT ON TABLE PRODUCTION_DATA_RAW TO PUBLIC;
GRANT SELECT, INSERT ON TABLE QUALITY_DATA_RAW TO PUBLIC; 