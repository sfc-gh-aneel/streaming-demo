"""
Data generators for manufacturing sensor, production, and quality data
Generates realistic synthetic data with proper correlations and patterns
"""

import json
import random
import logging
import numpy as np
from datetime import datetime, timedelta
from typing import List, Dict, Any, Optional
from faker import Faker

logger = logging.getLogger(__name__)

class BaseDataGenerator:
    """Base class for data generators"""
    
    def __init__(self, random_seed: Optional[int] = None):
        """Initialize base generator"""
        if random_seed is not None:
            random.seed(random_seed)
            np.random.seed(random_seed)
        
        self.fake = Faker()
        if random_seed:
            Faker.seed(random_seed)
    
    def _add_noise(self, value: float, variance: float) -> float:
        """Add Gaussian noise to a value"""
        return value + np.random.normal(0, variance)
    
    def _simulate_spike(self, base_value: float, spike_prob: float, spike_magnitude: float) -> float:
        """Simulate occasional spikes in sensor data"""
        if random.random() < spike_prob:
            spike_direction = random.choice([-1, 1])
            return base_value + (spike_direction * spike_magnitude)
        return base_value
    
    def _get_current_shift(self) -> str:
        """Determine current shift based on time"""
        hour = datetime.now().hour
        if 6 <= hour < 14:
            return 'DAY_SHIFT'
        elif 14 <= hour < 22:
            return 'AFTERNOON_SHIFT'
        else:
            return 'NIGHT_SHIFT'
    
    def _generate_batch_id(self) -> str:
        """Generate a realistic batch ID"""
        return f"BATCH_{datetime.now().strftime('%Y%m%d')}_{random.randint(1000, 9999)}"

class SensorDataGenerator(BaseDataGenerator):
    """Generates realistic sensor data for manufacturing equipment"""
    
    def __init__(self, equipment_config: List[Dict], sensor_config: Dict, random_seed: Optional[int] = None):
        """
        Initialize sensor data generator
        
        Args:
            equipment_config: List of equipment configurations
            sensor_config: Sensor simulation parameters
            random_seed: Random seed for reproducible data
        """
        super().__init__(random_seed)
        self.equipment_config = equipment_config
        self.sensor_config = sensor_config
        
        # Track equipment state over time
        self.equipment_state = {}
        self._initialize_equipment_state()
        
        logger.info(f"Initialized sensor data generator for {len(equipment_config)} pieces of equipment")
    
    def _initialize_equipment_state(self):
        """Initialize state tracking for each piece of equipment"""
        for equipment in self.equipment_config:
            equipment_id = equipment['equipment_id']
            self.equipment_state[equipment_id] = {
                'temperature_trend': 0,
                'pressure_trend': 0,
                'vibration_trend': 0,
                'efficiency_degradation': 0,
                'last_maintenance': datetime.now() - timedelta(days=random.randint(1, 30)),
                'status': 'RUNNING'
            }
    
    def generate_batch(self, batch_size: int) -> List[Dict[str, Any]]:
        """
        Generate a batch of sensor data records
        
        Args:
            batch_size: Number of records to generate
            
        Returns:
            List of sensor data records
        """
        records = []
        
        for _ in range(batch_size):
            # Select random equipment
            equipment = random.choice(self.equipment_config)
            equipment_id = equipment['equipment_id']
            
            # Generate sensor reading
            sensor_data = self._generate_sensor_reading(equipment)
            
            records.append(sensor_data)
        
        logger.debug(f"Generated {len(records)} sensor data records")
        return records
    
    def _generate_sensor_reading(self, equipment: Dict) -> Dict[str, Any]:
        """Generate a single sensor reading for equipment"""
        equipment_id = equipment['equipment_id']
        equipment_type = equipment['equipment_type']
        state = self.equipment_state[equipment_id]
        
        # Base sensor values depend on equipment type
        base_temp = self._get_base_temperature(equipment_type)
        base_pressure = self._get_base_pressure(equipment_type)
        base_speed = self._get_base_speed(equipment_type)
        
        # Apply equipment-specific limits
        max_temp = equipment['max_temperature']
        max_pressure = equipment['max_pressure']
        max_speed = equipment['max_speed']
        
        # Generate sensor values with trends and noise
        temperature = self._simulate_temperature(base_temp, max_temp, state)
        pressure = self._simulate_pressure(base_pressure, max_pressure, state)
        vibration = self._simulate_vibration(state)
        speed_rpm = self._simulate_speed(base_speed, max_speed, state)
        efficiency = self._simulate_efficiency(state)
        power_consumption = self._simulate_power_consumption(temperature, speed_rpm, efficiency)
        
        # Determine equipment status
        status = self._determine_status(temperature, pressure, vibration, max_temp, max_pressure)
        
        # Update equipment state
        self._update_equipment_state(equipment_id, temperature, pressure, vibration, efficiency)
        
        return {
            'timestamp': datetime.now().isoformat(),
            'equipment_id': equipment_id,
            'sensor_type': f"{equipment_type}_SENSOR",
            'temperature': round(temperature, 2),
            'pressure': round(pressure, 2),
            'vibration': round(vibration, 3),
            'speed_rpm': round(speed_rpm, 1),
            'power_consumption': round(power_consumption, 2),
            'efficiency_percent': round(efficiency, 1),
            'status': status
        }
    
    def _get_base_temperature(self, equipment_type: str) -> float:
        """Get base temperature for equipment type"""
        base_temps = {
            'PRESS': 45,
            'ROBOT': 35,
            'CONVEYOR': 25,
            'WELDER': 55,
            'DRILL': 40,
            'SCANNER': 22
        }
        return base_temps.get(equipment_type, 30)
    
    def _get_base_pressure(self, equipment_type: str) -> float:
        """Get base pressure for equipment type"""
        base_pressures = {
            'PRESS': 80,
            'ROBOT': 45,
            'CONVEYOR': 15,
            'WELDER': 25,
            'DRILL': 60,
            'SCANNER': 5
        }
        return base_pressures.get(equipment_type, 20)
    
    def _get_base_speed(self, equipment_type: str) -> float:
        """Get base speed for equipment type"""
        base_speeds = {
            'PRESS': 800,
            'ROBOT': 1500,
            'CONVEYOR': 300,
            'WELDER': 600,
            'DRILL': 2000,
            'SCANNER': 50
        }
        return base_speeds.get(equipment_type, 500)
    
    def _simulate_temperature(self, base_temp: float, max_temp: float, state: Dict) -> float:
        """Simulate temperature with trends and spikes"""
        config = self.sensor_config['temperature']
        
        # Apply trend from equipment state
        temp = base_temp + state['temperature_trend']
        
        # Add noise
        temp = self._add_noise(temp, config['variance'])
        
        # Simulate spikes
        temp = self._simulate_spike(temp, config['spike_probability'], config['spike_magnitude'])
        
        # Ensure within reasonable bounds
        return max(15, min(max_temp * 1.2, temp))
    
    def _simulate_pressure(self, base_pressure: float, max_pressure: float, state: Dict) -> float:
        """Simulate pressure with trends and spikes"""
        config = self.sensor_config['pressure']
        
        # Apply trend from equipment state
        pressure = base_pressure + state['pressure_trend']
        
        # Add noise
        pressure = self._add_noise(pressure, config['variance'])
        
        # Simulate spikes
        pressure = self._simulate_spike(pressure, config['spike_probability'], config['spike_magnitude'])
        
        # Ensure within reasonable bounds
        return max(0, min(max_pressure * 1.1, pressure))
    
    def _simulate_vibration(self, state: Dict) -> float:
        """Simulate vibration levels"""
        config = self.sensor_config['vibration']
        base_range = config['base_range']
        
        # Base vibration
        vibration = random.uniform(base_range[0], base_range[1])
        
        # Apply trend
        vibration += state['vibration_trend']
        
        # Add noise
        vibration = self._add_noise(vibration, config['variance'])
        
        # Simulate spikes
        vibration = self._simulate_spike(vibration, config['spike_probability'], config['spike_magnitude'])
        
        return max(0, vibration)
    
    def _simulate_speed(self, base_speed: float, max_speed: float, state: Dict) -> float:
        """Simulate equipment speed"""
        config = self.sensor_config['speed_rpm']
        
        # Base speed with some variation
        speed = base_speed * random.uniform(0.8, 1.2)
        
        # Add noise
        speed = self._add_noise(speed, config['variance'])
        
        # Simulate spikes
        speed = self._simulate_spike(speed, config['spike_probability'], config['spike_magnitude'])
        
        # Ensure within bounds
        return max(0, min(max_speed, speed))
    
    def _simulate_efficiency(self, state: Dict) -> float:
        """Simulate equipment efficiency"""
        config = self.sensor_config['efficiency']
        base_range = config['base_range']
        
        # Base efficiency
        efficiency = random.uniform(base_range[0], base_range[1])
        
        # Apply degradation over time
        efficiency -= state['efficiency_degradation']
        
        # Add noise
        efficiency = self._add_noise(efficiency, config['variance'])
        
        # Ensure within bounds
        return max(30, min(100, efficiency))
    
    def _simulate_power_consumption(self, temperature: float, speed: float, efficiency: float) -> float:
        """Simulate power consumption based on other metrics"""
        config = self.sensor_config['power_consumption']
        base_range = config['base_range']
        
        # Base power consumption
        base_power = random.uniform(base_range[0], base_range[1])
        
        # Correlate with temperature and speed
        temp_factor = 1 + (temperature - 30) / 100
        speed_factor = 1 + (speed - 500) / 2000
        efficiency_factor = 2 - (efficiency / 100)  # Lower efficiency = higher power
        
        power = base_power * temp_factor * speed_factor * efficiency_factor
        
        # Add noise
        power = self._add_noise(power, config['variance'])
        
        return max(1, power)
    
    def _determine_status(self, temperature: float, pressure: float, vibration: float, 
                         max_temp: float, max_pressure: float) -> str:
        """Determine equipment status based on sensor readings"""
        # Check for critical conditions
        if temperature > max_temp * 0.95 or pressure > max_pressure * 0.95:
            return random.choice(['ERROR', 'MAINTENANCE'])
        
        # Check for warning conditions
        if temperature > max_temp * 0.85 or pressure > max_pressure * 0.85 or vibration > 0.7:
            if random.random() < 0.1:  # 10% chance of stopping for maintenance
                return 'MAINTENANCE'
        
        # Random downtime
        if random.random() < 0.005:  # 0.5% chance of random stop
            return random.choice(['STOPPED', 'MAINTENANCE'])
        
        return 'RUNNING'
    
    def _update_equipment_state(self, equipment_id: str, temperature: float, 
                               pressure: float, vibration: float, efficiency: float):
        """Update equipment state for trend simulation"""
        state = self.equipment_state[equipment_id]
        
        # Update trends (slow changes over time)
        state['temperature_trend'] += random.uniform(-0.1, 0.1)
        state['pressure_trend'] += random.uniform(-0.1, 0.1)
        state['vibration_trend'] += random.uniform(-0.01, 0.01)
        state['efficiency_degradation'] += random.uniform(0, 0.001)
        
        # Reset trends occasionally (maintenance events)
        if random.random() < 0.001:  # 0.1% chance
            state['temperature_trend'] = 0
            state['pressure_trend'] = 0
            state['vibration_trend'] = 0
            state['efficiency_degradation'] = 0
            state['last_maintenance'] = datetime.now()

class ProductionDataGenerator(BaseDataGenerator):
    """Generates production event and metrics data"""
    
    def __init__(self, equipment_config: List[Dict], line_config: List[Dict], 
                 product_config: List[Dict], operator_config: List[Dict], 
                 production_config: Dict, random_seed: Optional[int] = None):
        """Initialize production data generator"""
        super().__init__(random_seed)
        self.equipment_config = equipment_config
        self.line_config = line_config
        self.product_config = product_config
        self.operator_config = operator_config
        self.production_config = production_config
        
        logger.info(f"Initialized production data generator")
    
    def generate_batch(self, batch_size: int) -> List[Dict[str, Any]]:
        """Generate a batch of production data records"""
        records = []
        
        for _ in range(batch_size):
            # Select random equipment and line
            equipment = random.choice(self.equipment_config)
            line = self._get_line_for_equipment(equipment)
            product = random.choice(self.product_config)
            operator = self._get_current_operator()
            
            # Generate production event
            production_data = self._generate_production_event(equipment, line, product, operator)
            records.append(production_data)
        
        logger.debug(f"Generated {len(records)} production data records")
        return records
    
    def _get_line_for_equipment(self, equipment: Dict) -> Dict:
        """Get production line for equipment"""
        line_id = equipment['production_line_id']
        for line in self.line_config:
            if line['line_id'] == line_id:
                return line
        return self.line_config[0]  # Fallback
    
    def _get_current_operator(self) -> Dict:
        """Get current shift operator"""
        current_shift = self._get_current_shift()
        shift_operators = [op for op in self.operator_config if op['shift'] == current_shift]
        return random.choice(shift_operators) if shift_operators else self.operator_config[0]
    
    def _generate_production_event(self, equipment: Dict, line: Dict, 
                                  product: Dict, operator: Dict) -> Dict[str, Any]:
        """Generate a single production event"""
        config = self.production_config
        
        # Determine event type
        event_type = self._determine_event_type()
        
        # Generate cycle time
        cycle_time = self._generate_cycle_time(equipment['equipment_type'], config)
        
        # Generate production volumes
        if event_type == 'PRODUCTION':
            units_produced, planned_units = self._generate_production_volume(config)
            reject_count = self._generate_reject_count(units_produced, config)
            downtime_minutes = 0
        else:
            units_produced = 0
            planned_units = random.randint(1, 10)
            reject_count = 0
            downtime_minutes = self._generate_downtime(config)
        
        return {
            'timestamp': datetime.now().isoformat(),
            'equipment_id': equipment['equipment_id'],
            'line_id': line['line_id'],
            'product_id': product['product_id'],
            'event_type': event_type,
            'units_produced': units_produced,
            'planned_units': planned_units,
            'cycle_time_seconds': round(cycle_time, 1),
            'downtime_minutes': round(downtime_minutes, 1),
            'reject_count': reject_count,
            'operator_id': operator['operator_id'],
            'batch_id': self._generate_batch_id()
        }
    
    def _determine_event_type(self) -> str:
        """Determine the type of production event"""
        # Weight towards production events
        events = ['PRODUCTION'] * 85 + ['CHANGEOVER'] * 5 + ['MAINTENANCE'] * 3 + \
                ['PLANNED_MAINTENANCE'] * 2 + ['QUALITY_CHECK'] * 3 + ['SETUP'] * 2
        return random.choice(events)
    
    def _generate_cycle_time(self, equipment_type: str, config: Dict) -> float:
        """Generate cycle time for equipment"""
        base_time = config['cycle_time']['base_seconds']
        variance = config['cycle_time']['variance']
        equipment_factors = config['cycle_time']['equipment_factors']
        
        factor = equipment_factors.get(equipment_type, 1.0)
        cycle_time = base_time * factor
        
        # Add variance
        cycle_time = self._add_noise(cycle_time, variance)
        
        return max(5, cycle_time)  # Minimum 5 seconds
    
    def _generate_production_volume(self, config: Dict) -> tuple:
        """Generate production volume"""
        volume_range = config['production_volume']['units_per_cycle']
        units = random.randint(volume_range[0], volume_range[1])
        planned = units + random.randint(0, 2)  # Usually produce what's planned
        
        return units, planned
    
    def _generate_reject_count(self, units_produced: int, config: Dict) -> int:
        """Generate reject count based on production volume"""
        reject_prob = config['production_volume']['reject_probability']
        rejects = 0
        
        for _ in range(units_produced):
            if random.random() < reject_prob:
                rejects += 1
        
        return rejects
    
    def _generate_downtime(self, config: Dict) -> float:
        """Generate downtime duration"""
        avg_duration = config['downtime']['average_duration_minutes']
        max_duration = config['downtime']['max_duration_minutes']
        
        # Exponential distribution for downtime
        duration = np.random.exponential(avg_duration)
        return min(duration, max_duration)

class QualityDataGenerator(BaseDataGenerator):
    """Generates quality control and testing data"""
    
    def __init__(self, equipment_config: List[Dict], product_config: List[Dict], 
                 inspector_config: List[Dict], quality_config: Dict, random_seed: Optional[int] = None):
        """Initialize quality data generator"""
        super().__init__(random_seed)
        self.equipment_config = equipment_config
        self.product_config = product_config
        self.inspector_config = inspector_config
        self.quality_config = quality_config
        
        logger.info(f"Initialized quality data generator")
    
    def generate_batch(self, batch_size: int) -> List[Dict[str, Any]]:
        """Generate a batch of quality data records"""
        records = []
        
        for _ in range(batch_size):
            # Select random product and equipment
            product = random.choice(self.product_config)
            equipment = random.choice(self.equipment_config)
            inspector = random.choice(self.inspector_config)
            test = random.choice(self.quality_config['tests'])
            
            # Generate quality test result
            quality_data = self._generate_quality_test(product, equipment, inspector, test)
            records.append(quality_data)
        
        logger.debug(f"Generated {len(records)} quality data records")
        return records
    
    def _generate_quality_test(self, product: Dict, equipment: Dict, 
                              inspector: Dict, test: Dict) -> Dict[str, Any]:
        """Generate a single quality test result"""
        
        # Generate measurement value
        spec_range = test['specification_range']
        precision = test['measurement_precision']
        failure_prob = test['failure_probability']
        
        # Determine if test passes or fails
        test_passes = random.random() > failure_prob
        
        if test_passes:
            # Generate value within specification
            measurement = random.uniform(spec_range[0], spec_range[1])
            defect_type = None
        else:
            # Generate value outside specification
            if random.random() < 0.5:
                measurement = spec_range[0] - random.uniform(0.1, 2.0)
            else:
                measurement = spec_range[1] + random.uniform(0.1, 2.0)
            defect_type = random.choice(self.quality_config['defect_types'])
        
        # Round to precision
        measurement = round(measurement, len(str(precision).split('.')[-1]))
        
        return {
            'timestamp': datetime.now().isoformat(),
            'equipment_id': equipment['equipment_id'],
            'product_id': product['product_id'],
            'test_type': test['test_type'],
            'measurement_value': measurement,
            'specification_min': spec_range[0],
            'specification_max': spec_range[1],
            'is_within_spec': test_passes,
            'defect_type': defect_type,
            'inspector_id': inspector['inspector_id'],
            'batch_id': self._generate_batch_id(),
            'sample_size': random.randint(1, 5)
        } 