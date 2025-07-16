package com.snowflake.demo.streaming;

import com.snowflake.demo.streaming.config.StreamingConfig;
import com.snowflake.demo.streaming.service.DataStreamingService;
import com.snowflake.demo.streaming.service.MetricsService;
import com.snowflake.demo.streaming.service.HealthService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * Main application for Manufacturing Streaming to Snowflake
 * Continuously monitors and streams manufacturing data via Snowpipe
 */
public class ManufacturingStreamingApp {
    
    private static final Logger logger = LoggerFactory.getLogger(ManufacturingStreamingApp.class);
    
    private final StreamingConfig config;
    private final DataStreamingService streamingService;
    private final MetricsService metricsService;
    private final HealthService healthService;
    private final ScheduledExecutorService scheduler;
    
    private volatile boolean running = false;
    
    public ManufacturingStreamingApp() {
        this.config = new StreamingConfig();
        this.streamingService = new DataStreamingService(config);
        this.metricsService = new MetricsService(config);
        this.healthService = new HealthService(config);
        this.scheduler = Executors.newScheduledThreadPool(4);
        
        // Setup shutdown hook
        Runtime.getRuntime().addShutdownHook(new Thread(this::shutdown));
    }
    
    public static void main(String[] args) {
        logger.info("====================================================");
        logger.info("Manufacturing Streaming Application Starting...");
        logger.info("====================================================");
        
        try {
            ManufacturingStreamingApp app = new ManufacturingStreamingApp();
            app.start();
        } catch (Exception e) {
            logger.error("Application startup failed", e);
            System.exit(1);
        }
    }
    
    public void start() {
        try {
            logger.info("Initializing Manufacturing Streaming Application...");
            
            // Initialize services
            streamingService.initialize();
            metricsService.initialize();
            healthService.initialize();
            
            // Start services
            running = true;
            
            // Start data streaming monitoring
            scheduler.scheduleWithFixedDelay(
                this::monitorAndStream,
                0,
                config.getStreamingInterval(),
                TimeUnit.SECONDS
            );
            
            // Start metrics collection
            scheduler.scheduleWithFixedDelay(
                metricsService::collectMetrics,
                30,
                config.getMetricsInterval(),
                TimeUnit.SECONDS
            );
            
            // Start health monitoring
            scheduler.scheduleWithFixedDelay(
                healthService::performHealthCheck,
                60,
                config.getHealthCheckInterval(),
                TimeUnit.SECONDS
            );
            
            // Start cleanup task
            scheduler.scheduleWithFixedDelay(
                this::performCleanup,
                300,
                config.getCleanupInterval(),
                TimeUnit.SECONDS
            );
            
            logger.info("Manufacturing Streaming Application started successfully");
            logger.info("Streaming interval: {} seconds", config.getStreamingInterval());
            logger.info("Metrics interval: {} seconds", config.getMetricsInterval());
            logger.info("Health check interval: {} seconds", config.getHealthCheckInterval());
            
            // Keep application running
            while (running) {
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException e) {
                    logger.info("Application interrupted");
                    break;
                }
            }
            
        } catch (Exception e) {
            logger.error("Error starting application", e);
            throw new RuntimeException("Application startup failed", e);
        }
    }
    
    private void monitorAndStream() {
        try {
            if (!running) {
                return;
            }
            
            logger.debug("Starting data streaming cycle...");
            
            // Stream sensor data
            int sensorRecords = streamingService.streamSensorData();
            logger.debug("Streamed {} sensor records", sensorRecords);
            
            // Stream production data
            int productionRecords = streamingService.streamProductionData();
            logger.debug("Streamed {} production records", productionRecords);
            
            // Stream quality data
            int qualityRecords = streamingService.streamQualityData();
            logger.debug("Streamed {} quality records", qualityRecords);
            
            // Update metrics
            metricsService.recordStreamingMetrics(sensorRecords, productionRecords, qualityRecords);
            
            logger.info("Streaming cycle completed: {} sensor, {} production, {} quality records",
                       sensorRecords, productionRecords, qualityRecords);
            
        } catch (Exception e) {
            logger.error("Error in streaming cycle", e);
            metricsService.recordError("streaming_cycle", e.getMessage());
        }
    }
    
    private void performCleanup() {
        try {
            if (!running) {
                return;
            }
            
            logger.debug("Performing cleanup tasks...");
            
            // Clean up temporary files
            streamingService.cleanupTempFiles();
            
            // Clean up old metrics
            metricsService.cleanupOldMetrics();
            
            // Clean up old logs
            performLogCleanup();
            
            logger.debug("Cleanup tasks completed");
            
        } catch (Exception e) {
            logger.error("Error during cleanup", e);
        }
    }
    
    private void performLogCleanup() {
        // Implement log cleanup logic if needed
        logger.debug("Log cleanup completed");
    }
    
    public void shutdown() {
        logger.info("Shutting down Manufacturing Streaming Application...");
        running = false;
        
        try {
            // Shutdown scheduler
            scheduler.shutdown();
            if (!scheduler.awaitTermination(30, TimeUnit.SECONDS)) {
                logger.warn("Scheduler did not terminate gracefully, forcing shutdown");
                scheduler.shutdownNow();
            }
            
            // Shutdown services
            streamingService.shutdown();
            metricsService.shutdown();
            healthService.shutdown();
            
            logger.info("Manufacturing Streaming Application shut down successfully");
            
        } catch (Exception e) {
            logger.error("Error during shutdown", e);
        }
    }
    
    public boolean isRunning() {
        return running;
    }
} 