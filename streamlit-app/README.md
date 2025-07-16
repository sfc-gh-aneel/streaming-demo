# Manufacturing Analytics Streamlit App

This Streamlit app provides interactive visualization and analysis of real-time manufacturing data from the Manufacturing Streaming Demo. The app includes dashboards for equipment performance, production analytics, quality control, and predictive maintenance.

## Features

### 🏠 Real-time Dashboard
- Overall facility metrics and KPIs
- Equipment status overview
- Production progress tracking
- Active alerts summary

### ⚙️ Equipment Performance
- Individual equipment health monitoring
- Performance trends and metrics
- Temperature, pressure, and efficiency tracking
- Historical data analysis

### 📊 Production Analytics
- Production line performance metrics
- Efficiency and throughput analysis
- Downtime and quality tracking
- Multi-line comparison views

### 🔍 Quality Control
- Quality metrics and pass rates
- Defect analysis and trending
- Product quality comparison
- Statistical process control

### 🔧 Predictive Maintenance
- Equipment health scores
- Failure probability predictions
- Maintenance recommendations
- Cost and downtime analysis

## Deployment to Snowflake

### Prerequisites

1. **Snowflake Account** with appropriate privileges
2. **Manufacturing Demo Database** deployed (see main README)
3. **Data Generation** running to populate aggregation tables
4. **Streamlit in Snowflake** enabled for your account

### Step 1: Prepare the App Files

Ensure you have the following files ready:
- `streamlit_app.py` - Main application code
- `requirements.txt` - Python dependencies

### Step 2: Deploy to Snowflake

#### Option A: Using Snowflake CLI (Recommended)

1. **Install Snowflake CLI**:
   ```bash
   pip install snowflake-cli-labs
   ```

2. **Configure Connection**:
   ```bash
   snow connection add --connection-name manufacturing_demo
   # Follow prompts to enter your credentials
   ```

3. **Deploy the App**:
   ```bash
   # Navigate to the streamlit-app directory
   cd streamlit-app
   
   # Deploy the Streamlit app
   snow streamlit deploy \
     --connection manufacturing_demo \
     --name manufacturing_analytics_dashboard \
     --file streamlit_app.py \
     --database MANUFACTURING_DEMO \
     --schema PUBLIC
   ```

#### Option B: Using Snowsight Web Interface

1. **Open Snowsight** and navigate to your Snowflake account
2. **Go to Streamlit** section in the left sidebar
3. **Click "Create Streamlit App"**
4. **Configure the App**:
   - **Name**: `Manufacturing Analytics Dashboard`
   - **Database**: `MANUFACTURING_DEMO`
   - **Schema**: `PUBLIC`
   - **Warehouse**: `ANALYTICS_WH` (or your preferred warehouse)

5. **Upload App Code**:
   - Copy the contents of `streamlit_app.py` into the editor
   - Upload or paste the `requirements.txt` content

6. **Click "Create"** to deploy the app

#### Option C: Using SQL Commands

```sql
-- Connect to your Snowflake account
USE DATABASE MANUFACTURING_DEMO;
USE SCHEMA PUBLIC;
USE WAREHOUSE ANALYTICS_WH;

-- Create the Streamlit app
CREATE STREAMLIT MANUFACTURING_ANALYTICS_DASHBOARD
  ROOT_LOCATION = '@~/streamlit'
  MAIN_FILE = 'streamlit_app.py'
  QUERY_WAREHOUSE = ANALYTICS_WH
COMMENT = 'Manufacturing Analytics Dashboard for Real-time Data Visualization';

-- You'll need to upload the files to the stage location
-- This can be done through Snowsight or using PUT commands
```

### Step 3: Configure Permissions

```sql
-- Grant necessary permissions for the app to access data
GRANT USAGE ON DATABASE MANUFACTURING_DEMO TO STREAMLIT MANUFACTURING_ANALYTICS_DASHBOARD;
GRANT USAGE ON ALL SCHEMAS IN DATABASE MANUFACTURING_DEMO TO STREAMLIT MANUFACTURING_ANALYTICS_DASHBOARD;
GRANT SELECT ON ALL TABLES IN DATABASE MANUFACTURING_DEMO TO STREAMLIT MANUFACTURING_ANALYTICS_DASHBOARD;
GRANT SELECT ON ALL VIEWS IN DATABASE MANUFACTURING_DEMO TO STREAMLIT MANUFACTURING_ANALYTICS_DASHBOARD;

-- Grant warehouse usage
GRANT USAGE ON WAREHOUSE ANALYTICS_WH TO STREAMLIT MANUFACTURING_ANALYTICS_DASHBOARD;
```

### Step 4: Access the App

1. **Navigate to Streamlit Apps** in Snowsight
2. **Click on** "Manufacturing Analytics Dashboard"
3. **The app should load** with the real-time dashboard

## Data Requirements

For the app to function properly, ensure the following:

### 1. Database Structure
- `MANUFACTURING_DEMO` database exists
- All schemas are properly created (`RAW_DATA`, `ANALYTICS`, `AGGREGATION`)
- Tables contain data from the data generation process

### 2. Aggregation Data
The app relies on aggregated data tables. Ensure these are populated:
- `AGG_REALTIME_DASHBOARD`
- `AGG_EQUIPMENT_PERFORMANCE` 
- `AGG_PRODUCTION_METRICS`
- `AGG_QUALITY_SUMMARY`
- `AGG_PREDICTIVE_MAINTENANCE`

### 3. Scheduled Tasks
Verify aggregation tasks are running:
```sql
-- Check task status
SHOW TASKS IN SCHEMA MANUFACTURING_DEMO.UTILITIES;

-- Ensure tasks are started
DESCRIBE TASK MANUFACTURING_DEMO.UTILITIES.DASHBOARD_REFRESH_TASK;
```

## Troubleshooting

### Common Issues

#### "No data available" messages
- **Cause**: Aggregation tables are empty or tasks aren't running
- **Solution**: 
  ```sql
  -- Check if data exists
  SELECT COUNT(*) FROM MANUFACTURING_DEMO.AGGREGATION.AGG_REALTIME_DASHBOARD;
  
  -- Manually run aggregation tasks if needed
  EXECUTE TASK MANUFACTURING_DEMO.UTILITIES.DASHBOARD_REFRESH_TASK;
  ```

#### Connection errors
- **Cause**: Database/schema permissions or warehouse access
- **Solution**: Verify permissions and warehouse assignment

#### Slow performance
- **Cause**: Large datasets or warehouse sizing
- **Solution**: 
  - Use a larger warehouse for the app
  - Optimize queries with appropriate time ranges
  - Check clustering on aggregation tables

### Performance Optimization

1. **Warehouse Sizing**: Use MEDIUM or LARGE warehouse for better performance
2. **Caching**: The app uses Streamlit caching (60 seconds for dashboard, 5 minutes for other data)
3. **Time Ranges**: Default views show recent data to maintain responsiveness

## App Configuration

### Custom Styling
The app includes custom CSS for a professional manufacturing theme:
- Manufacturing blue color scheme
- KPI cards with status indicators
- Alert styling with priority colors
- Responsive layout for different screen sizes

### Caching Strategy
- Dashboard metrics: 60-second TTL (real-time updates)
- Equipment and production data: 5-minute TTL (balance between performance and freshness)
- Static reference data: Longer caching periods

## Support

For issues with the Streamlit app:
1. Check the Snowflake task logs for data generation issues
2. Verify all aggregation tables have recent data
3. Ensure proper permissions are granted
4. Review Streamlit app logs in Snowsight

## Future Enhancements

Potential improvements for the app:
- **Real-time Alerts**: Push notifications for critical issues
- **Custom Dashboards**: User-configurable views
- **Export Functionality**: PDF reports and data exports
- **Advanced Analytics**: Machine learning insights
- **Mobile Optimization**: Responsive design improvements 