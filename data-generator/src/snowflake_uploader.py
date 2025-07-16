"""
Snowflake uploader for manufacturing data
Handles data upload to Snowflake using Snowpipe and direct SQL
"""

import json
import gzip
import tempfile
import logging
import os
from datetime import datetime
from typing import List, Dict, Any, Optional
from io import BytesIO

import snowflake.connector
from snowflake.ingest import SimpleIngestManager
from snowflake.ingest.utils.uris import DEFAULT_SCHEME

logger = logging.getLogger(__name__)

class SnowflakeUploader:
    """Handles data upload to Snowflake"""
    
    def __init__(self, snowflake_config: Dict[str, str]):
        """
        Initialize Snowflake uploader
        
        Args:
            snowflake_config: Snowflake connection configuration
        """
        self.config = snowflake_config
        self.connection = None
        self.ingest_managers = {}
        
        logger.info("Initializing Snowflake uploader...")
    
    def test_connection(self) -> bool:
        """
        Test connection to Snowflake
        
        Returns:
            True if connection successful, False otherwise
        """
        try:
            logger.info("Testing Snowflake connection...")
            
            conn = snowflake.connector.connect(
                account=self.config['account'],
                user=self.config['user'],
                password=self.config['password'],
                warehouse=self.config['warehouse'],
                database=self.config['database'],
                schema=self.config['schema']
            )
            
            # Test with a simple query
            cursor = conn.cursor()
            cursor.execute("SELECT CURRENT_VERSION()")
            result = cursor.fetchone()
            
            cursor.close()
            conn.close()
            
            logger.info(f"Snowflake connection successful. Version: {result[0] if result else 'Unknown'}")
            return True
            
        except Exception as e:
            logger.error(f"Snowflake connection failed: {str(e)}")
            return False
    
    def _get_connection(self):
        """Get or create Snowflake connection"""
        if self.connection is None or self.connection.is_closed():
            self.connection = snowflake.connector.connect(
                account=self.config['account'],
                user=self.config['user'],
                password=self.config['password'],
                warehouse=self.config['warehouse'],
                database=self.config['database'],
                schema=self.config['schema']
            )
        return self.connection
    
    def _get_ingest_manager(self, pipe_name: str) -> SimpleIngestManager:
        """
        Get or create Snowpipe ingest manager
        
        Args:
            pipe_name: Name of the Snowpipe
            
        Returns:
            SimpleIngestManager instance
        """
        if pipe_name not in self.ingest_managers:
            account = self.config['account']
            if not account.endswith('.snowflakecomputing.com'):
                account = f"{account}.snowflakecomputing.com"
            
            self.ingest_managers[pipe_name] = SimpleIngestManager(
                account=account,
                host=f"{account}",
                user=self.config['user'],
                pipe=f"{self.config['database']}.{self.config['schema']}.{pipe_name}",
                private_key=None  # Will use password authentication
            )
        
        return self.ingest_managers[pipe_name]
    
    def _create_compressed_json_file(self, data: List[Dict[str, Any]], prefix: str) -> str:
        """
        Create a compressed JSON file from data
        
        Args:
            data: List of data records
            prefix: File prefix for identification
            
        Returns:
            Path to the created file
        """
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S_%f')
        filename = f"{prefix}_{timestamp}.json.gz"
        filepath = os.path.join('/app/data', filename)
        
        # Ensure directory exists
        os.makedirs(os.path.dirname(filepath), exist_ok=True)
        
        # Write compressed JSON data
        with gzip.open(filepath, 'wt', encoding='utf-8') as f:
            for record in data:
                json.dump(record, f)
                f.write('\n')
        
        logger.debug(f"Created compressed file: {filepath} with {len(data)} records")
        return filepath
    
    def _upload_file_to_stage(self, filepath: str, stage_path: str) -> bool:
        """
        Upload file to Snowflake internal stage
        
        Args:
            filepath: Local file path
            stage_path: Target path in stage
            
        Returns:
            True if successful, False otherwise
        """
        try:
            conn = self._get_connection()
            cursor = conn.cursor()
            
            # Upload file to stage
            stage_name = self.config['stage']
            put_query = f"PUT file://{filepath} @{stage_name}/{stage_path}/ AUTO_COMPRESS=FALSE"
            
            logger.debug(f"Uploading file to stage: {put_query}")
            cursor.execute(put_query)
            
            # Get upload results
            results = cursor.fetchall()
            cursor.close()
            
            # Check if upload was successful
            if results and len(results) > 0:
                status = results[0][6] if len(results[0]) > 6 else 'UNKNOWN'
                if status == 'UPLOADED':
                    logger.debug(f"File uploaded successfully to stage: {stage_path}")
                    return True
                else:
                    logger.error(f"File upload failed with status: {status}")
                    return False
            
            return False
            
        except Exception as e:
            logger.error(f"Error uploading file to stage: {str(e)}")
            return False
        
        finally:
            # Clean up local file
            try:
                os.remove(filepath)
            except Exception as e:
                logger.warning(f"Failed to clean up local file {filepath}: {str(e)}")
    
    def upload_sensor_data(self, data: List[Dict[str, Any]]) -> bool:
        """
        Upload sensor data to Snowflake via Snowpipe
        
        Args:
            data: List of sensor data records
            
        Returns:
            True if successful, False otherwise
        """
        try:
            if not data:
                logger.warning("No sensor data to upload")
                return True
            
            # Create compressed JSON file
            filepath = self._create_compressed_json_file(data, 'sensor_data')
            
            # Upload to stage
            success = self._upload_file_to_stage(filepath, 'sensor_data')
            
            if success:
                logger.info(f"Successfully uploaded {len(data)} sensor data records")
            else:
                logger.error("Failed to upload sensor data")
            
            return success
            
        except Exception as e:
            logger.error(f"Error uploading sensor data: {str(e)}")
            return False
    
    def upload_production_data(self, data: List[Dict[str, Any]]) -> bool:
        """
        Upload production data to Snowflake via Snowpipe
        
        Args:
            data: List of production data records
            
        Returns:
            True if successful, False otherwise
        """
        try:
            if not data:
                logger.warning("No production data to upload")
                return True
            
            # Create compressed JSON file
            filepath = self._create_compressed_json_file(data, 'production_data')
            
            # Upload to stage
            success = self._upload_file_to_stage(filepath, 'production_data')
            
            if success:
                logger.info(f"Successfully uploaded {len(data)} production data records")
            else:
                logger.error("Failed to upload production data")
            
            return success
            
        except Exception as e:
            logger.error(f"Error uploading production data: {str(e)}")
            return False
    
    def upload_quality_data(self, data: List[Dict[str, Any]]) -> bool:
        """
        Upload quality data to Snowflake via Snowpipe
        
        Args:
            data: List of quality data records
            
        Returns:
            True if successful, False otherwise
        """
        try:
            if not data:
                logger.warning("No quality data to upload")
                return True
            
            # Create compressed JSON file
            filepath = self._create_compressed_json_file(data, 'quality_data')
            
            # Upload to stage
            success = self._upload_file_to_stage(filepath, 'quality_data')
            
            if success:
                logger.info(f"Successfully uploaded {len(data)} quality data records")
            else:
                logger.error("Failed to upload quality data")
            
            return success
            
        except Exception as e:
            logger.error(f"Error uploading quality data: {str(e)}")
            return False
    
    def upload_equipment_data(self, equipment_data: List[Dict[str, Any]]) -> bool:
        """
        Upload equipment dimension data directly to Snowflake
        
        Args:
            equipment_data: List of equipment records
            
        Returns:
            True if successful, False otherwise
        """
        try:
            conn = self._get_connection()
            cursor = conn.cursor()
            
            # Insert equipment data
            insert_query = """
            INSERT INTO ANALYTICS.DIM_EQUIPMENT 
            (equipment_id, equipment_name, equipment_type, manufacturer, model, 
             installation_date, production_line_id, location, max_temperature, 
             max_pressure, max_speed, maintenance_schedule, is_active)
            VALUES (%(equipment_id)s, %(equipment_name)s, %(equipment_type)s, 
                    %(manufacturer)s, %(model)s, CURRENT_DATE(), %(production_line_id)s, 
                    %(location)s, %(max_temperature)s, %(max_pressure)s, %(max_speed)s, 
                    'MONTHLY', TRUE)
            """
            
            cursor.executemany(insert_query, equipment_data)
            conn.commit()
            cursor.close()
            
            logger.info(f"Successfully uploaded {len(equipment_data)} equipment records")
            return True
            
        except Exception as e:
            logger.error(f"Error uploading equipment data: {str(e)}")
            return False
    
    def upload_production_line_data(self, line_data: List[Dict[str, Any]]) -> bool:
        """
        Upload production line dimension data
        
        Args:
            line_data: List of production line records
            
        Returns:
            True if successful, False otherwise
        """
        try:
            conn = self._get_connection()
            cursor = conn.cursor()
            
            # Insert production line data
            insert_query = """
            INSERT INTO ANALYTICS.DIM_PRODUCTION_LINE 
            (line_id, line_name, facility_name, shift_pattern, target_capacity_per_hour, 
             product_type, is_active)
            VALUES (%(line_id)s, %(line_name)s, %(facility_name)s, %(shift_pattern)s, 
                    %(target_capacity_per_hour)s, %(product_type)s, TRUE)
            """
            
            cursor.executemany(insert_query, line_data)
            conn.commit()
            cursor.close()
            
            logger.info(f"Successfully uploaded {len(line_data)} production line records")
            return True
            
        except Exception as e:
            logger.error(f"Error uploading production line data: {str(e)}")
            return False
    
    def upload_product_data(self, product_data: List[Dict[str, Any]]) -> bool:
        """
        Upload product dimension data
        
        Args:
            product_data: List of product records
            
        Returns:
            True if successful, False otherwise
        """
        try:
            conn = self._get_connection()
            cursor = conn.cursor()
            
            # Insert product data
            insert_query = """
            INSERT INTO ANALYTICS.DIM_PRODUCT 
            (product_id, product_name, product_category, unit_of_measure, 
             standard_cost, target_quality_score, is_active)
            VALUES (%(product_id)s, %(product_name)s, %(product_category)s, 
                    %(unit_of_measure)s, %(standard_cost)s, %(target_quality_score)s, TRUE)
            """
            
            cursor.executemany(insert_query, product_data)
            conn.commit()
            cursor.close()
            
            logger.info(f"Successfully uploaded {len(product_data)} product records")
            return True
            
        except Exception as e:
            logger.error(f"Error uploading product data: {str(e)}")
            return False
    
    def upload_time_dimension_data(self, start_date: datetime, end_date: datetime) -> bool:
        """
        Upload time dimension data for the specified date range
        
        Args:
            start_date: Start date for time dimension
            end_date: End date for time dimension
            
        Returns:
            True if successful, False otherwise
        """
        try:
            conn = self._get_connection()
            cursor = conn.cursor()
            
            # Generate time dimension data
            insert_query = """
            INSERT INTO ANALYTICS.DIM_TIME 
            (time_key, full_date, year_number, quarter_number, month_number, month_name,
             week_number, day_of_year, day_of_month, day_of_week, day_name,
             hour_number, minute_number, is_weekend, is_holiday, shift_name)
            SELECT 
                YEAR(date_time) * 100000000 + MONTH(date_time) * 1000000 + 
                DAY(date_time) * 10000 + HOUR(date_time) * 100 + MINUTE(date_time) as time_key,
                DATE(date_time) as full_date,
                YEAR(date_time) as year_number,
                QUARTER(date_time) as quarter_number,
                MONTH(date_time) as month_number,
                MONTHNAME(date_time) as month_name,
                WEEK(date_time) as week_number,
                DAYOFYEAR(date_time) as day_of_year,
                DAY(date_time) as day_of_month,
                DAYOFWEEK(date_time) as day_of_week,
                DAYNAME(date_time) as day_name,
                HOUR(date_time) as hour_number,
                MINUTE(date_time) as minute_number,
                CASE WHEN DAYOFWEEK(date_time) IN (1, 7) THEN TRUE ELSE FALSE END as is_weekend,
                FALSE as is_holiday,
                CASE 
                    WHEN HOUR(date_time) >= 6 AND HOUR(date_time) < 14 THEN 'DAY_SHIFT'
                    WHEN HOUR(date_time) >= 14 AND HOUR(date_time) < 22 THEN 'AFTERNOON_SHIFT'
                    ELSE 'NIGHT_SHIFT'
                END as shift_name
            FROM (
                SELECT DATEADD('MINUTE', SEQ4(), %(start_date)s) as date_time
                FROM TABLE(GENERATOR(ROWCOUNT => %(row_count)s))
            ) t
            WHERE date_time <= %(end_date)s
            """
            
            # Calculate row count (minutes between start and end date)
            row_count = int((end_date - start_date).total_seconds() / 60) + 1
            
            cursor.execute(insert_query, {
                'start_date': start_date.strftime('%Y-%m-%d %H:%M:%S'),
                'end_date': end_date.strftime('%Y-%m-%d %H:%M:%S'),
                'row_count': row_count
            })
            
            conn.commit()
            cursor.close()
            
            logger.info(f"Successfully uploaded time dimension data from {start_date} to {end_date}")
            return True
            
        except Exception as e:
            logger.error(f"Error uploading time dimension data: {str(e)}")
            return False
    
    def close(self):
        """Close Snowflake connection"""
        if self.connection and not self.connection.is_closed():
            self.connection.close()
            logger.info("Snowflake connection closed")
        
        # Clear ingest managers
        self.ingest_managers.clear() 