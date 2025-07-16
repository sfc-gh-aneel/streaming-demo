#!/usr/bin/env python3
"""
Manufacturing Data Generator for Snowflake Streaming Demo
Generates realistic manufacturing sensor, production, and quality data
"""

import os
import sys
import time
import logging
import signal
import threading
from datetime import datetime, timedelta
from concurrent.futures import ThreadPoolExecutor, as_completed

# Add src directory to path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from config_loader import ConfigLoader
from data_generators import SensorDataGenerator, ProductionDataGenerator, QualityDataGenerator
from snowflake_uploader import SnowflakeUploader

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.FileHandler('/app/data/generator.log')
    ]
)

logger = logging.getLogger(__name__)

class ManufacturingDataGeneratorApp:
    """Main application for manufacturing data generation"""
    
    def __init__(self, config_path='/app/config/config.yaml'):
        """Initialize the data generator application"""
        self.config_path = config_path
        self.config = None
        self.generators = {}
        self.uploader = None
        self.running = False
        self.threads = []
        
        # Setup signal handlers for graceful shutdown
        signal.signal(signal.SIGINT, self._signal_handler)
        signal.signal(signal.SIGTERM, self._signal_handler)
        
    def _signal_handler(self, signum, frame):
        """Handle shutdown signals gracefully"""
        logger.info(f"Received signal {signum}, shutting down gracefully...")
        self.stop()
        
    def initialize(self):
        """Initialize all components"""
        try:
            logger.info("Initializing Manufacturing Data Generator...")
            
            # Load configuration
            logger.info("Loading configuration...")
            self.config = ConfigLoader.load_config(self.config_path)
            
            # Initialize Snowflake uploader
            logger.info("Initializing Snowflake uploader...")
            self.uploader = SnowflakeUploader(self.config['snowflake'])
            
            # Test Snowflake connection
            if not self.uploader.test_connection():
                raise Exception("Failed to connect to Snowflake")
            
            # Initialize data generators
            logger.info("Initializing data generators...")
            self._initialize_generators()
            
            logger.info("Initialization completed successfully")
            return True
            
        except Exception as e:
            logger.error(f"Initialization failed: {str(e)}")
            return False
    
    def _initialize_generators(self):
        """Initialize all data generators"""
        # Sensor data generator
        self.generators['sensor'] = SensorDataGenerator(
            self.config['manufacturing']['equipment'],
            self.config['sensor_data']
        )
        
        # Production data generator
        self.generators['production'] = ProductionDataGenerator(
            self.config['manufacturing']['equipment'],
            self.config['manufacturing']['production_lines'],
            self.config['manufacturing']['products'],
            self.config['operators'],
            self.config['production_events']
        )
        
        # Quality data generator
        self.generators['quality'] = QualityDataGenerator(
            self.config['manufacturing']['equipment'],
            self.config['manufacturing']['products'],
            self.config['inspectors'],
            self.config['quality_control']
        )
    
    def start(self):
        """Start the data generation process"""
        if not self.initialize():
            logger.error("Failed to initialize, exiting...")
            return False
            
        logger.info("Starting Manufacturing Data Generator...")
        self.running = True
        
        # Start generation threads
        self._start_generation_threads()
        
        # Keep main thread alive
        try:
            while self.running:
                time.sleep(1)
        except KeyboardInterrupt:
            logger.info("Received keyboard interrupt")
        
        self.stop()
        return True
    
    def _start_generation_threads(self):
        """Start data generation threads"""
        interval = self.config['generation']['interval_seconds']
        batch_size = self.config['generation']['batch_size']
        
        # Sensor data generation thread
        sensor_thread = threading.Thread(
            target=self._generate_sensor_data_loop,
            args=(interval, batch_size),
            name="SensorDataThread"
        )
        sensor_thread.daemon = True
        sensor_thread.start()
        self.threads.append(sensor_thread)
        
        # Production data generation thread
        production_thread = threading.Thread(
            target=self._generate_production_data_loop,
            args=(interval * 2, batch_size // 2),  # Less frequent than sensor data
            name="ProductionDataThread"
        )
        production_thread.daemon = True
        production_thread.start()
        self.threads.append(production_thread)
        
        # Quality data generation thread
        quality_thread = threading.Thread(
            target=self._generate_quality_data_loop,
            args=(interval * 3, batch_size // 3),  # Least frequent
            name="QualityDataThread"
        )
        quality_thread.daemon = True
        quality_thread.start()
        self.threads.append(quality_thread)
        
        logger.info(f"Started {len(self.threads)} data generation threads")
    
    def _generate_sensor_data_loop(self, interval, batch_size):
        """Generate sensor data continuously"""
        logger.info(f"Starting sensor data generation (interval: {interval}s, batch: {batch_size})")
        
        while self.running:
            try:
                start_time = time.time()
                
                # Generate sensor data batch
                data_batch = self.generators['sensor'].generate_batch(batch_size)
                
                # Upload to Snowflake
                success = self.uploader.upload_sensor_data(data_batch)
                
                if success:
                    logger.info(f"Uploaded {len(data_batch)} sensor records")
                else:
                    logger.error("Failed to upload sensor data")
                
                # Wait for next interval
                elapsed = time.time() - start_time
                sleep_time = max(0, interval - elapsed)
                if sleep_time > 0:
                    time.sleep(sleep_time)
                    
            except Exception as e:
                logger.error(f"Error in sensor data generation: {str(e)}")
                time.sleep(interval)
    
    def _generate_production_data_loop(self, interval, batch_size):
        """Generate production data continuously"""
        logger.info(f"Starting production data generation (interval: {interval}s, batch: {batch_size})")
        
        while self.running:
            try:
                start_time = time.time()
                
                # Generate production data batch
                data_batch = self.generators['production'].generate_batch(batch_size)
                
                # Upload to Snowflake
                success = self.uploader.upload_production_data(data_batch)
                
                if success:
                    logger.info(f"Uploaded {len(data_batch)} production records")
                else:
                    logger.error("Failed to upload production data")
                
                # Wait for next interval
                elapsed = time.time() - start_time
                sleep_time = max(0, interval - elapsed)
                if sleep_time > 0:
                    time.sleep(sleep_time)
                    
            except Exception as e:
                logger.error(f"Error in production data generation: {str(e)}")
                time.sleep(interval)
    
    def _generate_quality_data_loop(self, interval, batch_size):
        """Generate quality data continuously"""
        logger.info(f"Starting quality data generation (interval: {interval}s, batch: {batch_size})")
        
        while self.running:
            try:
                start_time = time.time()
                
                # Generate quality data batch
                data_batch = self.generators['quality'].generate_batch(batch_size)
                
                # Upload to Snowflake
                success = self.uploader.upload_quality_data(data_batch)
                
                if success:
                    logger.info(f"Uploaded {len(data_batch)} quality records")
                else:
                    logger.error("Failed to upload quality data")
                
                # Wait for next interval
                elapsed = time.time() - start_time
                sleep_time = max(0, interval - elapsed)
                if sleep_time > 0:
                    time.sleep(sleep_time)
                    
            except Exception as e:
                logger.error(f"Error in quality data generation: {str(e)}")
                time.sleep(interval)
    
    def stop(self):
        """Stop the data generation process"""
        logger.info("Stopping Manufacturing Data Generator...")
        self.running = False
        
        # Wait for threads to complete
        for thread in self.threads:
            if thread.is_alive():
                logger.info(f"Waiting for {thread.name} to complete...")
                thread.join(timeout=5)
        
        # Close uploader connection
        if self.uploader:
            self.uploader.close()
        
        logger.info("Manufacturing Data Generator stopped")
    
    def generate_initial_data(self):
        """Generate initial reference data (dimensions)"""
        logger.info("Generating initial reference data...")
        
        try:
            # Upload equipment data
            equipment_data = self.config['manufacturing']['equipment']
            success = self.uploader.upload_equipment_data(equipment_data)
            if success:
                logger.info(f"Uploaded {len(equipment_data)} equipment records")
            
            # Upload production line data
            line_data = self.config['manufacturing']['production_lines']
            success = self.uploader.upload_production_line_data(line_data)
            if success:
                logger.info(f"Uploaded {len(line_data)} production line records")
            
            # Upload product data
            product_data = self.config['manufacturing']['products']
            success = self.uploader.upload_product_data(product_data)
            if success:
                logger.info(f"Uploaded {len(product_data)} product records")
            
            logger.info("Initial reference data generation completed")
            return True
            
        except Exception as e:
            logger.error(f"Failed to generate initial data: {str(e)}")
            return False

def main():
    """Main entry point"""
    logger.info("=" * 60)
    logger.info("Manufacturing Data Generator Starting...")
    logger.info("=" * 60)
    
    # Create and start the application
    app = ManufacturingDataGeneratorApp()
    
    # Check if we should generate initial data
    if os.environ.get('GENERATE_INITIAL_DATA', 'false').lower() == 'true':
        logger.info("Generating initial reference data...")
        if not app.initialize():
            sys.exit(1)
        app.generate_initial_data()
        sys.exit(0)
    
    # Start continuous data generation
    success = app.start()
    
    if success:
        logger.info("Manufacturing Data Generator completed successfully")
        sys.exit(0)
    else:
        logger.error("Manufacturing Data Generator failed")
        sys.exit(1)

if __name__ == "__main__":
    main() 