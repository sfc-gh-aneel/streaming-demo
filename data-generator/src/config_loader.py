"""
Configuration loader for manufacturing data generator
Handles YAML loading with environment variable substitution
"""

import os
import re
import yaml
import logging
from typing import Dict, Any

logger = logging.getLogger(__name__)

class ConfigLoader:
    """Configuration loader with environment variable support"""
    
    @staticmethod
    def load_config(config_path: str) -> Dict[str, Any]:
        """
        Load configuration from YAML file with environment variable substitution
        
        Args:
            config_path: Path to the YAML configuration file
            
        Returns:
            Dictionary containing configuration data
            
        Raises:
            FileNotFoundError: If config file doesn't exist
            yaml.YAMLError: If YAML parsing fails
            ValueError: If required environment variables are missing
        """
        if not os.path.exists(config_path):
            raise FileNotFoundError(f"Configuration file not found: {config_path}")
        
        logger.info(f"Loading configuration from {config_path}")
        
        try:
            # Read the YAML file
            with open(config_path, 'r') as file:
                content = file.read()
            
            # Substitute environment variables
            content = ConfigLoader._substitute_env_vars(content)
            
            # Parse YAML
            config = yaml.safe_load(content)
            
            # Validate required configuration
            ConfigLoader._validate_config(config)
            
            logger.info("Configuration loaded successfully")
            return config
            
        except yaml.YAMLError as e:
            logger.error(f"YAML parsing error: {str(e)}")
            raise
        except Exception as e:
            logger.error(f"Configuration loading error: {str(e)}")
            raise
    
    @staticmethod
    def _substitute_env_vars(content: str) -> str:
        """
        Substitute environment variables in configuration content
        
        Supports patterns like ${VAR_NAME} and ${VAR_NAME:default_value}
        
        Args:
            content: Raw configuration content
            
        Returns:
            Content with environment variables substituted
        """
        # Pattern to match ${VAR_NAME} or ${VAR_NAME:default}
        pattern = r'\$\{([^}:]+)(?::([^}]*))?\}'
        
        def replace_var(match):
            var_name = match.group(1)
            default_value = match.group(2) if match.group(2) is not None else None
            
            # Get environment variable value
            value = os.environ.get(var_name)
            
            if value is not None:
                return value
            elif default_value is not None:
                return default_value
            else:
                raise ValueError(f"Required environment variable '{var_name}' is not set")
        
        return re.sub(pattern, replace_var, content)
    
    @staticmethod
    def _validate_config(config: Dict[str, Any]) -> None:
        """
        Validate that required configuration sections exist
        
        Args:
            config: Configuration dictionary to validate
            
        Raises:
            ValueError: If required configuration is missing
        """
        required_sections = [
            'snowflake',
            'generation',
            'manufacturing',
            'sensor_data',
            'production_events',
            'quality_control'
        ]
        
        for section in required_sections:
            if section not in config:
                raise ValueError(f"Required configuration section '{section}' is missing")
        
        # Validate Snowflake configuration
        snowflake_config = config['snowflake']
        required_snowflake_keys = ['account', 'user', 'password', 'warehouse', 'database', 'schema']
        
        for key in required_snowflake_keys:
            if key not in snowflake_config or not snowflake_config[key]:
                raise ValueError(f"Required Snowflake configuration key '{key}' is missing or empty")
        
        # Validate manufacturing configuration
        manufacturing_config = config['manufacturing']
        required_manufacturing_sections = ['equipment', 'production_lines', 'products']
        
        for section in required_manufacturing_sections:
            if section not in manufacturing_config:
                raise ValueError(f"Required manufacturing section '{section}' is missing")
            
            if not manufacturing_config[section]:
                raise ValueError(f"Manufacturing section '{section}' cannot be empty")
        
        logger.debug("Configuration validation passed")
    
    @staticmethod
    def get_snowflake_connection_params(config: Dict[str, Any]) -> Dict[str, str]:
        """
        Extract Snowflake connection parameters from configuration
        
        Args:
            config: Configuration dictionary
            
        Returns:
            Dictionary with Snowflake connection parameters
        """
        snowflake_config = config['snowflake']
        
        return {
            'account': snowflake_config['account'],
            'user': snowflake_config['user'],
            'password': snowflake_config['password'],
            'warehouse': snowflake_config['warehouse'],
            'database': snowflake_config['database'],
            'schema': snowflake_config['schema'],
            'role': snowflake_config.get('role', 'PUBLIC')
        }
    
    @staticmethod
    def get_generation_params(config: Dict[str, Any]) -> Dict[str, Any]:
        """
        Extract data generation parameters from configuration
        
        Args:
            config: Configuration dictionary
            
        Returns:
            Dictionary with generation parameters
        """
        generation_config = config['generation']
        
        return {
            'interval_seconds': generation_config.get('interval_seconds', 10),
            'batch_size': generation_config.get('batch_size', 50),
            'continuous': generation_config.get('continuous', True),
            'random_seed': generation_config.get('random_seed', None)
        } 