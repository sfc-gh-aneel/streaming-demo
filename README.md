# Manufacturing Real-Time Streaming Demo for Snowflake

A comprehensive end-to-end demonstration of real-time data streaming in Snowflake using Snowpark Container Services, showcasing a manufacturing industry use case with synthetic sensor data, production metrics, and quality control data.

## 🏗️ Architecture Overview


```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Data          │    │   Java           │    │   Raw Data      │
│   Generator     │───▶│   Streaming      │───▶│   Tables        │
│   (Python)      │    │   (Snowpipe)     │    │   (JSON)        │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                                        │
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Aggregation   │◀───│   Star Schema    │◀───│   Streams &     │
│   Layer (KPIs)  │    │   (Analytics)    │    │   Transforms    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### Architecture Components

1. **Data Generation Layer**
   - Snowpark Container Service running Python application
   - Generates realistic manufacturing sensor, production, and quality data
   - Configurable equipment, production lines, and products

2. **Ingestion Layer**
   - Java streaming application using Snowflake SDK
   - Continuous data upload via Snowpipe
   - Compressed JSON files with automatic ingestion

3. **Raw Data Layer**
   - JSON-based tables for sensor, production, and quality data
   - Optimized for high-volume ingestion
   - Clustering for query performance

4. **Stream Processing**
   - Snowflake Streams for change data capture
   - Low-latency transformation tasks (1-minute intervals)
   - Automatic processing with conditional execution

5. **Star Schema (Analytics)**
   - Dimension tables: Equipment, Production Lines, Products, Time
   - Fact tables: Sensor Readings, Production Events, Quality Tests
   - Optimized for analytical queries

6. **Aggregation Layer**
   - Pre-calculated KPIs and metrics
   - Real-time dashboard data
   - Equipment performance indicators
   - Predictive maintenance alerts

## 🚀 Quick Start

### Prerequisites

- Docker
- Java 11+
- Maven 3.6+
- Python 3.8+
- Snowflake account with appropriate privileges

### Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd streaming-demo
   ```

2. **Run the setup script**
   ```bash
   ./scripts/setup_demo.sh -a <SNOWFLAKE_ACCOUNT> -u <SNOWFLAKE_USER> -p <SNOWFLAKE_PASSWORD>
   ```

3. **Access the streaming data**
   - Navigate to your Snowflake console
   - Database: `MANUFACTURING_DEMO`
   - Schemas: `RAW_DATA`, `ANALYTICS`, `AGGREGATION`

### Alternative Setup (Step by Step)

If you prefer manual setup or need to customize the installation:

```bash
# 1. Set environment variables
export SNOWFLAKE_ACCOUNT=your_account
export SNOWFLAKE_USER=your_user
export SNOWFLAKE_PASSWORD=your_password

# 2. Setup database and schemas
python3 scripts/execute_sql.py --account $SNOWFLAKE_ACCOUNT --user $SNOWFLAKE_USER --password $SNOWFLAKE_PASSWORD --file sql/01_database_setup.sql
python3 scripts/execute_sql.py --account $SNOWFLAKE_ACCOUNT --user $SNOWFLAKE_USER --password $SNOWFLAKE_PASSWORD --file sql/02_raw_tables.sql
python3 scripts/execute_sql.py --account $SNOWFLAKE_ACCOUNT --user $SNOWFLAKE_USER --password $SNOWFLAKE_PASSWORD --file sql/03_star_schema.sql
python3 scripts/execute_sql.py --account $SNOWFLAKE_ACCOUNT --user $SNOWFLAKE_USER --password $SNOWFLAKE_PASSWORD --file sql/04_aggregation_layer.sql
python3 scripts/execute_sql.py --account $SNOWFLAKE_ACCOUNT --user $SNOWFLAKE_USER --password $SNOWFLAKE_PASSWORD --file sql/05_streams_and_transforms.sql
python3 scripts/execute_sql.py --account $SNOWFLAKE_ACCOUNT --user $SNOWFLAKE_USER --password $SNOWFLAKE_PASSWORD --file sql/06_aggregation_tasks.sql

# 3. Build containers
cd data-generator && docker build -t manufacturing-data-generator:latest .
cd ../java-streaming && mvn clean package && docker build -t manufacturing-streaming:latest .

# 4. Initialize reference data
docker run --rm -e SNOWFLAKE_ACCOUNT=$SNOWFLAKE_ACCOUNT -e SNOWFLAKE_USER=$SNOWFLAKE_USER -e SNOWFLAKE_PASSWORD=$SNOWFLAKE_PASSWORD -e GENERATE_INITIAL_DATA=true manufacturing-data-generator:latest
```

## 📊 Data Schema

### Raw Data Tables

- **`SENSOR_DATA_RAW`**: Equipment sensor readings (temperature, pressure, vibration, speed)
- **`PRODUCTION_DATA_RAW`**: Production events and metrics (units produced, cycle times, downtime)
- **`QUALITY_DATA_RAW`**: Quality control test results and measurements

### Star Schema (Analytics)

#### Dimension Tables
- **`DIM_EQUIPMENT`**: Equipment master data
- **`DIM_PRODUCTION_LINE`**: Production line configuration
- **`DIM_PRODUCT`**: Product catalog
- **`DIM_TIME`**: Time dimension with manufacturing shifts

#### Fact Tables
- **`FACT_SENSOR_READINGS`**: Processed sensor data with alerts
- **`FACT_PRODUCTION`**: Production events and metrics
- **`FACT_QUALITY`**: Quality test results and defect tracking

### Aggregation Layer

- **`AGG_EQUIPMENT_PERFORMANCE`**: Real-time equipment KPIs
- **`AGG_PRODUCTION_METRICS`**: Production line performance
- **`AGG_QUALITY_SUMMARY`**: Quality control summaries
- **`AGG_PREDICTIVE_MAINTENANCE`**: Maintenance alerts and predictions
- **`AGG_REALTIME_DASHBOARD`**: Live dashboard metrics

## 🔧 Configuration

### Data Generator Configuration

Edit `data-generator/config/config.yaml` to customize:

- **Equipment**: Types, specifications, and limits
- **Production Lines**: Capacity, shift patterns, products
- **Data Generation**: Intervals, batch sizes, simulation parameters
- **Quality Control**: Test types, specifications, defect rates

### Java Streaming Configuration

Environment variables for the Java streaming application:

```bash
SNOWFLAKE_ACCOUNT=your_account
SNOWFLAKE_USER=your_user
SNOWFLAKE_PASSWORD=your_password
STREAMING_INTERVAL_SECONDS=30
STREAMING_BATCH_SIZE=1000
METRICS_ENABLED=true
```

## 📈 Monitoring and Metrics

### Real-Time Dashboard Queries

```sql
-- Current equipment status
SELECT * FROM MANUFACTURING_DEMO.AGGREGATION.AGG_REALTIME_DASHBOARD 
ORDER BY snapshot_timestamp DESC LIMIT 1;

-- Equipment performance last hour
SELECT * FROM MANUFACTURING_DEMO.AGGREGATION.AGG_EQUIPMENT_PERFORMANCE 
WHERE time_window_start >= CURRENT_TIMESTAMP() - INTERVAL '1 HOUR'
ORDER BY time_window_start DESC;

-- Production efficiency by line
SELECT 
    line_name,
    AVG(production_efficiency_percent) as avg_efficiency,
    SUM(total_units_produced) as total_units
FROM MANUFACTURING_DEMO.AGGREGATION.AGG_PRODUCTION_METRICS 
WHERE time_window_start >= CURRENT_DATE()
GROUP BY line_name;

-- Quality trends
SELECT 
    product_name,
    AVG(pass_rate_percent) as avg_pass_rate,
    AVG(defect_rate_per_thousand) as avg_defect_rate
FROM MANUFACTURING_DEMO.AGGREGATION.AGG_QUALITY_SUMMARY 
WHERE time_window_start >= CURRENT_DATE()
GROUP BY product_name;
```

### Predictive Maintenance Alerts

```sql
-- Equipment requiring immediate attention
SELECT 
    equipment_name,
    overall_health_score,
    recommended_action,
    maintenance_priority,
    predicted_failure_days
FROM MANUFACTURING_DEMO.AGGREGATION.AGG_PREDICTIVE_MAINTENANCE 
WHERE maintenance_priority IN ('HIGH', 'CRITICAL')
ORDER BY overall_health_score ASC;
```

## 📁 Project Structure

```
streaming-demo/
├── README.md                          # This file
├── sql/                               # Database setup scripts
│   ├── 01_database_setup.sql          # Database and schema creation
│   ├── 02_raw_tables.sql              # Raw data tables and Snowpipes
│   ├── 03_star_schema.sql             # Dimensional model
│   ├── 04_aggregation_layer.sql       # KPI and metrics tables
│   ├── 05_streams_and_transforms.sql  # Real-time transformation logic
│   └── 06_aggregation_tasks.sql       # Aggregation task definitions
├── data-generator/                    # Python data generator
│   ├── Dockerfile                     # Container configuration
│   ├── requirements.txt               # Python dependencies
│   ├── config/config.yaml             # Data generation configuration
│   ├── src/main.py                    # Main application
│   ├── src/config_loader.py           # Configuration management
│   ├── src/data_generators.py         # Data generation logic
│   └── src/snowflake_uploader.py      # Snowflake integration
├── java-streaming/                    # Java streaming application
│   ├── pom.xml                        # Maven configuration
│   └── src/main/java/                 # Java source code
│       └── com/snowflake/demo/streaming/
│           ├── ManufacturingStreamingApp.java
│           ├── config/StreamingConfig.java
│           └── service/               # Service classes
└── scripts/                          # Automation scripts
    ├── setup_demo.sh                 # Main setup script
    └── execute_sql.py                # SQL execution helper
```

## 🛠️ Customization

### Adding New Equipment Types

1. Edit `data-generator/config/config.yaml`
2. Add equipment configuration under `manufacturing.equipment`
3. Update sensor data parameters if needed
4. Restart the data generator

### Custom KPIs and Metrics

1. Modify aggregation procedures in `sql/06_aggregation_tasks.sql`
2. Add new aggregation tables in `sql/04_aggregation_layer.sql`
3. Update transformation logic as needed

### Scaling Configuration

- **Data Volume**: Adjust `generation.batch_size` and `generation.interval_seconds`
- **Processing**: Modify task schedules in transformation and aggregation scripts
- **Storage**: Configure table clustering and retention policies

## 🔍 Troubleshooting

### Common Issues

1. **Connection Errors**
   ```bash
   # Verify Snowflake credentials
   snowsql -a $SNOWFLAKE_ACCOUNT -u $SNOWFLAKE_USER
   ```

2. **Container Build Failures**
   ```bash
   # Check Docker and build dependencies
   docker --version
   java -version
   mvn --version
   ```

3. **Data Not Appearing**
   ```sql
   -- Check pipe status
   SHOW PIPES IN SCHEMA MANUFACTURING_DEMO.RAW_DATA;
   
   -- Check stream status
   SHOW STREAMS IN SCHEMA MANUFACTURING_DEMO.RAW_DATA;
   
   -- Check task status
   SHOW TASKS IN SCHEMA MANUFACTURING_DEMO.UTILITIES;
   ```

### Log Analysis

```bash
# View container logs
docker logs <container_id>

# Check Snowflake task history
SELECT * FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
WHERE database_name = 'MANUFACTURING_DEMO'
ORDER BY scheduled_time DESC;
```

## 🎯 Demo Scenarios

### Real-Time Monitoring
- Monitor equipment performance in real-time
- Track production efficiency across multiple lines
- Identify quality issues as they occur

### Predictive Maintenance
- Analyze sensor trends to predict equipment failures
- Schedule maintenance based on performance degradation
- Optimize maintenance schedules and costs

### Quality Control
- Track defect rates and quality trends
- Identify process improvements
- Correlate quality issues with equipment performance

### Production Optimization
- Analyze throughput and efficiency patterns
- Identify bottlenecks in production lines
- Optimize shift schedules and resource allocation

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙋 Support

For questions and support:
- Review the troubleshooting section above
- Check Snowflake documentation for specific features
- Open an issue in this repository for bugs or feature requests

---

## 📚 Additional Resources

- [Snowflake Documentation](https://docs.snowflake.com/)
- [Snowpark Container Services](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/overview)
- [Snowpipe Documentation](https://docs.snowflake.com/en/user-guide/data-load-snowpipe)
- [Manufacturing Analytics Best Practices](https://www.snowflake.com/workloads/manufacturing/)

Happy streaming! 🚀
