-- =====================================================
-- Manufacturing Real-Time Streaming Demo - Database Setup
-- =====================================================

-- Create database and schemas
CREATE DATABASE IF NOT EXISTS MANUFACTURING_DEMO;
USE DATABASE MANUFACTURING_DEMO;

-- Create schemas for different data layers
CREATE SCHEMA IF NOT EXISTS RAW_DATA COMMENT = 'Raw streaming data from manufacturing systems';
CREATE SCHEMA IF NOT EXISTS STAGING COMMENT = 'Staging area for data transformation';
CREATE SCHEMA IF NOT EXISTS ANALYTICS COMMENT = 'Star schema for analytical processing';
CREATE SCHEMA IF NOT EXISTS AGGREGATION COMMENT = 'Pre-aggregated metrics for consumption';
CREATE SCHEMA IF NOT EXISTS UTILITIES COMMENT = 'Utility objects like stored procedures and functions';

-- Create warehouses for different workloads
CREATE WAREHOUSE IF NOT EXISTS STREAMING_WH 
WITH 
    WAREHOUSE_SIZE = 'SMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    MIN_CLUSTER_COUNT = 1
    MAX_CLUSTER_COUNT = 3
    SCALING_POLICY = 'STANDARD'
COMMENT = 'Warehouse for real-time streaming and transformation';

CREATE WAREHOUSE IF NOT EXISTS ANALYTICS_WH 
WITH 
    WAREHOUSE_SIZE = 'MEDIUM'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE
    MIN_CLUSTER_COUNT = 1
    MAX_CLUSTER_COUNT = 2
    SCALING_POLICY = 'STANDARD'
COMMENT = 'Warehouse for analytical queries and aggregations';

-- Create file format for JSON data
USE SCHEMA RAW_DATA;

CREATE OR REPLACE FILE FORMAT JSON_FORMAT
TYPE = 'JSON'
COMPRESSION = 'GZIP'
STRIP_OUTER_ARRAY = TRUE
COMMENT = 'JSON format for manufacturing sensor data';

-- Create internal stage for data ingestion
CREATE OR REPLACE STAGE MANUFACTURING_STAGE
FILE_FORMAT = JSON_FORMAT
COMMENT = 'Internal stage for manufacturing data files';

-- Grant usage on database and schemas
GRANT USAGE ON DATABASE MANUFACTURING_DEMO TO PUBLIC;
GRANT USAGE ON SCHEMA RAW_DATA TO PUBLIC;
GRANT USAGE ON SCHEMA STAGING TO PUBLIC;
GRANT USAGE ON SCHEMA ANALYTICS TO PUBLIC;
GRANT USAGE ON SCHEMA AGGREGATION TO PUBLIC;
GRANT USAGE ON SCHEMA UTILITIES TO PUBLIC;

-- Grant warehouse usage
GRANT USAGE ON WAREHOUSE STREAMING_WH TO PUBLIC;
GRANT USAGE ON WAREHOUSE ANALYTICS_WH TO PUBLIC;

SHOW DATABASES LIKE 'MANUFACTURING_DEMO';
SHOW SCHEMAS IN DATABASE MANUFACTURING_DEMO; 