package com.snowflake.demo.streaming.config;

import com.typesafe.config.Config;
import com.typesafe.config.ConfigFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Properties;

/**
 * Configuration class for Manufacturing Streaming Application
 * Loads configuration from environment variables and config files
 */
public class StreamingConfig {
    
    private static final Logger logger = LoggerFactory.getLogger(StreamingConfig.class);
    
    private final Config config;
    private final Properties snowflakeProps;
    
    public StreamingConfig() {
        this.config = ConfigFactory.load();
        this.snowflakeProps = loadSnowflakeProperties();
        
        logger.info("Configuration loaded successfully");
    }
    
    private Properties loadSnowflakeProperties() {
        Properties props = new Properties();
        
        // Snowflake connection properties
        props.setProperty("account", getRequiredEnvVar("SNOWFLAKE_ACCOUNT"));
        props.setProperty("user", getRequiredEnvVar("SNOWFLAKE_USER"));
        props.setProperty("password", getRequiredEnvVar("SNOWFLAKE_PASSWORD"));
        props.setProperty("warehouse", getEnvVar("SNOWFLAKE_WAREHOUSE", "STREAMING_WH"));
        props.setProperty("database", getEnvVar("SNOWFLAKE_DATABASE", "MANUFACTURING_DEMO"));
        props.setProperty("schema", getEnvVar("SNOWFLAKE_SCHEMA", "RAW_DATA"));
        props.setProperty("role", getEnvVar("SNOWFLAKE_ROLE", "PUBLIC"));
        
        // Connection pooling
        props.setProperty("connectionPoolSize", "10");
        props.setProperty("connectionTimeout", "30000");
        props.setProperty("socketTimeout", "30000");
        
        return props;
    }
    
    private String getRequiredEnvVar(String name) {
        String value = System.getenv(name);
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalStateException("Required environment variable not set: " + name);
        }
        return value;
    }
    
    private String getEnvVar(String name, String defaultValue) {
        String value = System.getenv(name);
        return (value != null && !value.trim().isEmpty()) ? value : defaultValue;
    }
    
    // Snowflake configuration
    public Properties getSnowflakeProperties() {
        return snowflakeProps;
    }
    
    public String getSnowflakeAccount() {
        return snowflakeProps.getProperty("account");
    }
    
    public String getSnowflakeUser() {
        return snowflakeProps.getProperty("user");
    }
    
    public String getSnowflakePassword() {
        return snowflakeProps.getProperty("password");
    }
    
    public String getSnowflakeWarehouse() {
        return snowflakeProps.getProperty("warehouse");
    }
    
    public String getSnowflakeDatabase() {
        return snowflakeProps.getProperty("database");
    }
    
    public String getSnowflakeSchema() {
        return snowflakeProps.getProperty("schema");
    }
    
    public String getSnowflakeRole() {
        return snowflakeProps.getProperty("role");
    }
    
    // Streaming configuration
    public int getStreamingInterval() {
        return Integer.parseInt(getEnvVar("STREAMING_INTERVAL_SECONDS", "30"));
    }
    
    public int getBatchSize() {
        return Integer.parseInt(getEnvVar("STREAMING_BATCH_SIZE", "1000"));
    }
    
    public int getMaxRetries() {
        return Integer.parseInt(getEnvVar("STREAMING_MAX_RETRIES", "3"));
    }
    
    public int getRetryDelaySeconds() {
        return Integer.parseInt(getEnvVar("STREAMING_RETRY_DELAY_SECONDS", "10"));
    }
    
    public boolean isCompressionEnabled() {
        return Boolean.parseBoolean(getEnvVar("STREAMING_COMPRESSION_ENABLED", "true"));
    }
    
    // File and stage configuration
    public String getTempDirectory() {
        return getEnvVar("TEMP_DIRECTORY", "/tmp/streaming");
    }
    
    public String getStagePrefix() {
        return getEnvVar("STAGE_PREFIX", "manufacturing_streaming");
    }
    
    public int getFileRetentionHours() {
        return Integer.parseInt(getEnvVar("FILE_RETENTION_HOURS", "24"));
    }
    
    // Pipe names
    public String getSensorPipeName() {
        return getEnvVar("SENSOR_PIPE_NAME", "SENSOR_PIPE");
    }
    
    public String getProductionPipeName() {
        return getEnvVar("PRODUCTION_PIPE_NAME", "PRODUCTION_PIPE");
    }
    
    public String getQualityPipeName() {
        return getEnvVar("QUALITY_PIPE_NAME", "QUALITY_PIPE");
    }
    
    // Metrics configuration
    public int getMetricsInterval() {
        return Integer.parseInt(getEnvVar("METRICS_INTERVAL_SECONDS", "60"));
    }
    
    public int getMetricsPort() {
        return Integer.parseInt(getEnvVar("METRICS_PORT", "8080"));
    }
    
    public boolean isMetricsEnabled() {
        return Boolean.parseBoolean(getEnvVar("METRICS_ENABLED", "true"));
    }
    
    // Health check configuration
    public int getHealthCheckInterval() {
        return Integer.parseInt(getEnvVar("HEALTH_CHECK_INTERVAL_SECONDS", "120"));
    }
    
    public int getHealthCheckTimeout() {
        return Integer.parseInt(getEnvVar("HEALTH_CHECK_TIMEOUT_SECONDS", "30"));
    }
    
    // Cleanup configuration
    public int getCleanupInterval() {
        return Integer.parseInt(getEnvVar("CLEANUP_INTERVAL_SECONDS", "300"));
    }
    
    // Logging configuration
    public String getLogLevel() {
        return getEnvVar("LOG_LEVEL", "INFO");
    }
    
    public String getLogDirectory() {
        return getEnvVar("LOG_DIRECTORY", "/var/log/streaming");
    }
    
    // Data source configuration
    public String getDataSourceUrl() {
        return getEnvVar("DATA_SOURCE_URL", "http://manufacturing-data-generator:8080");
    }
    
    public int getDataSourceTimeout() {
        return Integer.parseInt(getEnvVar("DATA_SOURCE_TIMEOUT_SECONDS", "30"));
    }
    
    public String getDataSourceApiKey() {
        return getEnvVar("DATA_SOURCE_API_KEY", "");
    }
    
    // Performance tuning
    public int getThreadPoolSize() {
        return Integer.parseInt(getEnvVar("THREAD_POOL_SIZE", "4"));
    }
    
    public int getQueueCapacity() {
        return Integer.parseInt(getEnvVar("QUEUE_CAPACITY", "10000"));
    }
    
    public int getConnectionPoolSize() {
        return Integer.parseInt(getEnvVar("CONNECTION_POOL_SIZE", "10"));
    }
    
    public long getMaxMemoryMB() {
        return Long.parseLong(getEnvVar("MAX_MEMORY_MB", "1024"));
    }
    
    // Security configuration
    public boolean isSslEnabled() {
        return Boolean.parseBoolean(getEnvVar("SSL_ENABLED", "true"));
    }
    
    public String getKeyStorePassword() {
        return getEnvVar("KEYSTORE_PASSWORD", "");
    }
    
    public String getTrustStorePassword() {
        return getEnvVar("TRUSTSTORE_PASSWORD", "");
    }
    
    // Debug and monitoring
    public boolean isDebugEnabled() {
        return Boolean.parseBoolean(getEnvVar("DEBUG_ENABLED", "false"));
    }
    
    public boolean isDetailedMetricsEnabled() {
        return Boolean.parseBoolean(getEnvVar("DETAILED_METRICS_ENABLED", "false"));
    }
    
    public void printConfiguration() {
        logger.info("=== Streaming Configuration ===");
        logger.info("Snowflake Account: {}", getSnowflakeAccount());
        logger.info("Snowflake User: {}", getSnowflakeUser());
        logger.info("Snowflake Warehouse: {}", getSnowflakeWarehouse());
        logger.info("Snowflake Database: {}", getSnowflakeDatabase());
        logger.info("Snowflake Schema: {}", getSnowflakeSchema());
        logger.info("Streaming Interval: {} seconds", getStreamingInterval());
        logger.info("Batch Size: {}", getBatchSize());
        logger.info("Compression Enabled: {}", isCompressionEnabled());
        logger.info("Metrics Enabled: {}", isMetricsEnabled());
        logger.info("Debug Enabled: {}", isDebugEnabled());
        logger.info("==============================");
    }
} 