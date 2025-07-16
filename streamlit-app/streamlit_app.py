"""
Manufacturing Streaming Demo - Streamlit in Snowflake App

This app provides interactive visualization and analysis of real-time manufacturing data
including equipment performance, production metrics, quality control, and predictive maintenance.
"""

import streamlit as st
from snowflake.snowpark.context import get_active_session
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
from datetime import datetime, timedelta
import numpy as np

# Page configuration
st.set_page_config(
    page_title="Manufacturing Analytics Dashboard",
    page_icon="🏭",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Initialize Snowflake session
@st.cache_resource
def get_snowflake_session():
    """Get the active Snowflake session"""
    return get_active_session()

session = get_snowflake_session()

# Custom CSS for better styling
st.markdown("""
<style>
.main-header {
    font-size: 3rem;
    color: #1f77b4;
    text-align: center;
    margin-bottom: 2rem;
}
.kpi-card {
    background-color: #f0f2f6;
    padding: 1rem;
    border-radius: 0.5rem;
    border: 1px solid #e1e5e9;
    text-align: center;
    margin-bottom: 1rem;
}
.metric-value {
    font-size: 2.5rem;
    font-weight: bold;
    color: #262730;
}
.metric-label {
    font-size: 1rem;
    color: #64748b;
    margin-top: 0.5rem;
}
.alert-high {
    background-color: #fee2e2;
    border-color: #fca5a5;
    color: #991b1b;
}
.alert-medium {
    background-color: #fef3c7;
    border-color: #fcd34d;
    color: #92400e;
}
.alert-low {
    background-color: #dcfce7;
    border-color: #86efac;
    color: #166534;
}
</style>
""", unsafe_allow_html=True)

# Navigation
def show_navigation():
    """Display the navigation sidebar"""
    st.sidebar.markdown("# 🏭 Manufacturing Analytics")
    st.sidebar.markdown("---")
    
    pages = {
        "🏠 Real-time Dashboard": "dashboard",
        "⚙️ Equipment Performance": "equipment", 
        "📊 Production Analytics": "production",
        "🔍 Quality Control": "quality",
        "🔧 Predictive Maintenance": "maintenance"
    }
    
    selected_page = st.sidebar.radio(
        "Navigate to:",
        list(pages.keys()),
        index=0
    )
    
    return pages[selected_page]

# Utility functions
@st.cache_data(ttl=60)
def get_dashboard_metrics(_session):
    """Get real-time dashboard metrics"""
    query = """
    SELECT 
        total_active_equipment,
        equipment_online_count,
        equipment_offline_count,
        equipment_alert_count,
        current_production_rate_per_hour,
        today_units_produced,
        today_production_target,
        today_efficiency_percent,
        today_tests_conducted,
        today_pass_rate_percent,
        today_defect_rate,
        critical_alerts_count,
        high_priority_alerts_count,
        medium_priority_alerts_count,
        last_updated
    FROM MANUFACTURING_DEMO.AGGREGATION.AGG_REALTIME_DASHBOARD
    ORDER BY snapshot_timestamp DESC
    LIMIT 1
    """
    df = _session.sql(query).to_pandas()
    # Convert Snowflake uppercase column names to lowercase
    df.columns = df.columns.str.lower()
    return df

@st.cache_data(ttl=300)
def get_equipment_list(_session):
    """Get list of equipment with current status"""
    query = """
    SELECT DISTINCT
        equipment_id,
        equipment_name,
        equipment_type,
        overall_health_score,
        maintenance_priority,
        temperature_alert,
        vibration_alert,
        pressure_alert,
        efficiency_alert
    FROM MANUFACTURING_DEMO.AGGREGATION.AGG_PREDICTIVE_MAINTENANCE
    WHERE snapshot_timestamp >= CURRENT_TIMESTAMP() - INTERVAL '1 hour'
    ORDER BY equipment_id
    """
    df = _session.sql(query).to_pandas()
    # Convert Snowflake uppercase column names to lowercase
    df.columns = df.columns.str.lower()
    return df

@st.cache_data(ttl=300)
def get_production_lines(_session):
    """Get production line information"""
    query = """
    SELECT DISTINCT
        line_id,
        line_name,
        facility_name,
        target_capacity_per_hour,
        is_active
    FROM MANUFACTURING_DEMO.ANALYTICS.DIM_PRODUCTION_LINE
    WHERE is_active = TRUE
    ORDER BY line_id
    """
    df = _session.sql(query).to_pandas()
    # Convert Snowflake uppercase column names to lowercase
    df.columns = df.columns.str.lower()
    return df

# Helper function to execute query and normalize column names
def execute_snowflake_query(_session, query):
    """Execute query and convert column names to lowercase"""
    df = _session.sql(query).to_pandas()
    df.columns = df.columns.str.lower()
    return df

# Dashboard Components
def render_dashboard():
    """Render the real-time dashboard"""
    st.markdown('<h1 class="main-header">🏠 Real-time Manufacturing Dashboard</h1>', unsafe_allow_html=True)
    
    # Get dashboard data
    try:
        dashboard_data = get_dashboard_metrics(session)
        
        if dashboard_data.empty:
            st.warning("No dashboard data available. Please ensure the aggregation tasks are running.")
            return
            
        data = dashboard_data.iloc[0]
        
        # Key metrics row
        col1, col2, col3, col4 = st.columns(4)
        
        with col1:
            st.markdown(f"""
            <div class="kpi-card">
                <div class="metric-value">{data['equipment_online_count']}/{data['total_active_equipment']}</div>
                <div class="metric-label">Equipment Online</div>
            </div>
            """, unsafe_allow_html=True)
            
        with col2:
            efficiency = data['today_efficiency_percent']
            efficiency_color = "🟢" if efficiency >= 90 else "🟡" if efficiency >= 75 else "🔴"
            st.markdown(f"""
            <div class="kpi-card">
                <div class="metric-value">{efficiency:.1f}% {efficiency_color}</div>
                <div class="metric-label">Today's Efficiency</div>
            </div>
            """, unsafe_allow_html=True)
            
        with col3:
            production_rate = data['current_production_rate_per_hour']
            st.markdown(f"""
            <div class="kpi-card">
                <div class="metric-value">{production_rate:,.0f}</div>
                <div class="metric-label">Units/Hour</div>
            </div>
            """, unsafe_allow_html=True)
            
        with col4:
            pass_rate = data['today_pass_rate_percent']
            quality_color = "🟢" if pass_rate >= 95 else "🟡" if pass_rate >= 90 else "🔴"
            st.markdown(f"""
            <div class="kpi-card">
                <div class="metric-value">{pass_rate:.1f}% {quality_color}</div>
                <div class="metric-label">Quality Pass Rate</div>
            </div>
            """, unsafe_allow_html=True)
        
        # Second row - Production progress and alerts
        col1, col2 = st.columns([2, 1])
        
        with col1:
            st.subheader("📈 Production Progress")
            
            produced = data['today_units_produced']
            target = data['today_production_target']
            progress = min(produced / target * 100, 100) if target > 0 else 0
            
            fig = go.Figure(go.Indicator(
                mode = "gauge+number+delta",
                value = progress,
                domain = {'x': [0, 1], 'y': [0, 1]},
                title = {'text': "Production Target Progress (%)"},
                delta = {'reference': 100, 'increasing': {'color': "green"}},
                gauge = {
                    'axis': {'range': [None, 100]},
                    'bar': {'color': "darkblue"},
                    'steps': [
                        {'range': [0, 50], 'color': "lightgray"},
                        {'range': [50, 80], 'color': "yellow"},
                        {'range': [80, 100], 'color': "lightgreen"}
                    ],
                    'threshold': {
                        'line': {'color': "red", 'width': 4},
                        'thickness': 0.75,
                        'value': 90
                    }
                }
            ))
            fig.update_layout(height=300)
            st.plotly_chart(fig, use_container_width=True)
            
            st.metric(
                label="Units Produced Today",
                value=f"{produced:,}",
                delta=f"{produced - target:,} vs target"
            )
        
        with col2:
            st.subheader("🚨 Active Alerts")
            
            critical_alerts = data['critical_alerts_count']
            high_alerts = data['high_priority_alerts_count'] 
            medium_alerts = data['medium_priority_alerts_count']
            
            if critical_alerts > 0:
                st.markdown(f"""
                <div class="kpi-card alert-high">
                    <div class="metric-value">{critical_alerts}</div>
                    <div class="metric-label">🔴 Critical Alerts</div>
                </div>
                """, unsafe_allow_html=True)
            
            if high_alerts > 0:
                st.markdown(f"""
                <div class="kpi-card alert-medium">
                    <div class="metric-value">{high_alerts}</div>
                    <div class="metric-label">🟡 High Priority</div>
                </div>
                """, unsafe_allow_html=True)
            
            if medium_alerts > 0:
                st.markdown(f"""
                <div class="kpi-card alert-low">
                    <div class="metric-value">{medium_alerts}</div>
                    <div class="metric-label">🟠 Medium Priority</div>
                </div>
                """, unsafe_allow_html=True)
            
            if critical_alerts == 0 and high_alerts == 0 and medium_alerts == 0:
                st.success("✅ No active alerts")
        
        # Equipment status overview
        st.subheader("⚙️ Equipment Status Overview")
        
        try:
            equipment_data = get_equipment_list(session)
            
            if not equipment_data.empty:
                # Create equipment health chart
                fig = px.scatter(
                    equipment_data,
                    x='equipment_id',
                    y='overall_health_score',
                    color='maintenance_priority',
                    hover_data=['equipment_name', 'equipment_type'],
                    color_discrete_map={
                        'LOW': 'green',
                        'MEDIUM': 'yellow', 
                        'HIGH': 'orange',
                        'CRITICAL': 'red'
                    },
                    title="Equipment Health Scores"
                )
                fig.update_layout(height=400)
                fig.update_xaxes(tickangle=45)
                st.plotly_chart(fig, use_container_width=True)
                
                # Equipment alerts summary
                col1, col2, col3 = st.columns(3)
                
                with col1:
                    temp_alerts = equipment_data['temperature_alert'].sum()
                    st.metric("🌡️ Temperature Alerts", temp_alerts)
                
                with col2:
                    vibration_alerts = equipment_data['vibration_alert'].sum()
                    st.metric("📳 Vibration Alerts", vibration_alerts)
                
                with col3:
                    pressure_alerts = equipment_data['pressure_alert'].sum()
                    st.metric("💨 Pressure Alerts", pressure_alerts)
            else:
                st.info("No equipment data available.")
                
        except Exception as e:
            st.error(f"Error loading equipment data: {str(e)}")
        
        # Last updated info
        st.markdown("---")
        st.caption(f"Last updated: {data['last_updated']}")
        
    except Exception as e:
        st.error(f"Error loading dashboard data: {str(e)}")
        st.info("Please ensure the MANUFACTURING_DEMO database and aggregation tables exist.")

def render_equipment():
    """Render equipment performance page"""
    st.markdown('<h1 class="main-header">⚙️ Equipment Performance</h1>', unsafe_allow_html=True)
    
    try:
        equipment_data = get_equipment_list(session)
        
        if equipment_data.empty:
            st.warning("No equipment data available.")
            return
        
        # Equipment selector
        selected_equipment = st.selectbox(
            "Select Equipment:",
            equipment_data['equipment_id'].tolist(),
            format_func=lambda x: f"{x} - {equipment_data[equipment_data['equipment_id']==x]['equipment_name'].iloc[0] if not equipment_data[equipment_data['equipment_id']==x]['equipment_name'].empty else x}"
        )
        
        if selected_equipment:
            # Get equipment performance data
            query = f"""
            SELECT *
            FROM MANUFACTURING_DEMO.AGGREGATION.AGG_EQUIPMENT_PERFORMANCE
            WHERE equipment_id = '{selected_equipment}'
                AND time_window_start >= CURRENT_TIMESTAMP() - INTERVAL '24 hours'
            ORDER BY time_window_start DESC
            """
            
            perf_data = execute_snowflake_query(session, query)
            
            if not perf_data.empty:
                # Display current metrics
                latest = perf_data.iloc[0]
                
                col1, col2, col3, col4 = st.columns(4)
                
                with col1:
                    health_score = equipment_data[equipment_data['equipment_id']==selected_equipment]['overall_health_score'].iloc[0]
                    st.metric("Health Score", f"{health_score:.1f}%")
                
                with col2:
                    st.metric("Availability", f"{latest['availability_percent']:.1f}%")
                
                with col3:
                    st.metric("Efficiency", f"{latest['avg_efficiency_percent']:.1f}%")
                
                with col4:
                    st.metric("Downtime", f"{latest['downtime_minutes']:.1f} min")
                
                # Temperature trend
                if len(perf_data) > 1:
                    st.subheader("📊 Performance Trends (Last 24 Hours)")
                    
                    fig = make_subplots(
                        rows=2, cols=2,
                        subplot_titles=('Temperature', 'Pressure', 'Efficiency', 'Power Consumption'),
                        vertical_spacing=0.1
                    )
                    
                    # Temperature
                    fig.add_trace(
                        go.Scatter(x=perf_data['time_window_start'], y=perf_data['avg_temperature'], name='Avg Temp'),
                        row=1, col=1
                    )
                    
                    # Pressure  
                    fig.add_trace(
                        go.Scatter(x=perf_data['time_window_start'], y=perf_data['avg_pressure'], name='Avg Pressure'),
                        row=1, col=2
                    )
                    
                    # Efficiency
                    fig.add_trace(
                        go.Scatter(x=perf_data['time_window_start'], y=perf_data['avg_efficiency_percent'], name='Efficiency %'),
                        row=2, col=1
                    )
                    
                    # Power consumption
                    fig.add_trace(
                        go.Scatter(x=perf_data['time_window_start'], y=perf_data['avg_power_consumption'], name='Power (kW)'),
                        row=2, col=2
                    )
                    
                    fig.update_layout(height=600, showlegend=False)
                    st.plotly_chart(fig, use_container_width=True)
                
            else:
                st.info(f"No performance data available for {selected_equipment}")
        
    except Exception as e:
        st.error(f"Error loading equipment data: {str(e)}")

def render_production():
    """Render production analytics page"""
    st.markdown('<h1 class="main-header">📊 Production Analytics</h1>', unsafe_allow_html=True)
    
    try:
        # Get production lines
        production_lines = get_production_lines(session)
        
        if production_lines.empty:
            st.warning("No production line data available.")
            return
        
        # Time range selector
        col1, col2 = st.columns(2)
        with col1:
            time_range = st.selectbox(
                "Time Range:",
                ["Last Hour", "Last 4 Hours", "Last 24 Hours", "Last Week"],
                index=2
            )
        
        with col2:
            selected_line = st.selectbox(
                "Production Line:",
                ["All Lines"] + production_lines['line_id'].tolist(),
                format_func=lambda x: x if x == "All Lines" else f"{x} - {production_lines[production_lines['line_id']==x]['line_name'].iloc[0] if not production_lines[production_lines['line_id']==x]['line_name'].empty else x}"
            )
        
        # Map time range to hours
        time_map = {
            "Last Hour": 1,
            "Last 4 Hours": 4, 
            "Last 24 Hours": 24,
            "Last Week": 168
        }
        hours = time_map[time_range]
        
        # Build query based on selection
        line_filter = f"AND line_id = '{selected_line}'" if selected_line != "All Lines" else ""
        
        query = f"""
        SELECT 
            line_id,
            line_name,
            time_window_start,
            time_window_end,
            shift_name,
            total_units_produced,
            total_planned_units,
            production_efficiency_percent,
            avg_cycle_time_seconds,
            total_reject_count,
            reject_rate_percent,
            first_pass_yield_percent,
            total_downtime_minutes,
            unplanned_downtime_minutes,
            downtime_events_count,
            units_per_hour,
            throughput_vs_target_percent
        FROM MANUFACTURING_DEMO.AGGREGATION.AGG_PRODUCTION_METRICS
        WHERE time_window_start >= CURRENT_TIMESTAMP() - INTERVAL '{hours} hours'
            {line_filter}
            AND aggregation_level = 'HOUR'
        ORDER BY time_window_start DESC
        """
        
        production_data = execute_snowflake_query(session, query)
        
        if production_data.empty:
            st.info("No production data available for the selected timeframe.")
            return
        
        # Current metrics summary
        st.subheader("📊 Current Performance Summary")
        
        if selected_line != "All Lines":
            # Single line metrics
            latest_data = production_data.iloc[0]
            
            col1, col2, col3, col4 = st.columns(4)
            
            with col1:
                st.metric(
                    "Production Efficiency",
                    f"{latest_data['production_efficiency_percent']:.1f}%"
                )
            
            with col2:
                st.metric(
                    "Units/Hour",
                    f"{latest_data['units_per_hour']:.0f}"
                )
            
            with col3:
                st.metric(
                    "First Pass Yield",
                    f"{latest_data['first_pass_yield_percent']:.1f}%"
                )
            
            with col4:
                st.metric(
                    "Downtime Events",
                    f"{latest_data['downtime_events_count']:.0f}"
                )
        
        else:
            # Aggregate metrics across all lines
            latest_hour = production_data['time_window_start'].max()
            latest_data = production_data[production_data['time_window_start'] == latest_hour]
            
            col1, col2, col3, col4 = st.columns(4)
            
            with col1:
                avg_efficiency = latest_data['production_efficiency_percent'].mean()
                st.metric(
                    "Avg Efficiency",
                    f"{avg_efficiency:.1f}%"
                )
            
            with col2:
                total_units = latest_data['units_per_hour'].sum()
                st.metric(
                    "Total Units/Hour",
                    f"{total_units:.0f}"
                )
            
            with col3:
                avg_yield = latest_data['first_pass_yield_percent'].mean()
                st.metric(
                    "Avg First Pass Yield",
                    f"{avg_yield:.1f}%"
                )
            
            with col4:
                total_downtime = latest_data['downtime_events_count'].sum()
                st.metric(
                    "Total Downtime Events",
                    f"{total_downtime:.0f}"
                )
        
        # Production trends
        st.subheader("📈 Production Trends")
        
        if len(production_data) > 1:
            # Create trend charts
            fig = make_subplots(
                rows=2, cols=2,
                subplot_titles=(
                    'Production Efficiency %',
                    'Units per Hour',
                    'First Pass Yield %', 
                    'Downtime Minutes'
                ),
                vertical_spacing=0.1
            )
            
            if selected_line != "All Lines":
                # Single line trends
                fig.add_trace(
                    go.Scatter(
                        x=production_data['time_window_start'],
                        y=production_data['production_efficiency_percent'],
                        mode='lines+markers',
                        name='Efficiency %',
                        line=dict(color='blue')
                    ),
                    row=1, col=1
                )
                
                fig.add_trace(
                    go.Scatter(
                        x=production_data['time_window_start'],
                        y=production_data['units_per_hour'],
                        mode='lines+markers',
                        name='Units/Hour',
                        line=dict(color='green')
                    ),
                    row=1, col=2
                )
                
                fig.add_trace(
                    go.Scatter(
                        x=production_data['time_window_start'],
                        y=production_data['first_pass_yield_percent'],
                        mode='lines+markers',
                        name='First Pass Yield %',
                        line=dict(color='orange')
                    ),
                    row=2, col=1
                )
                
                fig.add_trace(
                    go.Scatter(
                        x=production_data['time_window_start'],
                        y=production_data['total_downtime_minutes'],
                        mode='lines+markers',
                        name='Downtime Minutes',
                        line=dict(color='red')
                    ),
                    row=2, col=2
                )
            
            else:
                # Multi-line trends (aggregate by time)
                agg_data = production_data.groupby('time_window_start').agg({
                    'production_efficiency_percent': 'mean',
                    'units_per_hour': 'sum',
                    'first_pass_yield_percent': 'mean',
                    'total_downtime_minutes': 'sum'
                }).reset_index()
                
                fig.add_trace(
                    go.Scatter(
                        x=agg_data['time_window_start'],
                        y=agg_data['production_efficiency_percent'],
                        mode='lines+markers',
                        name='Avg Efficiency %',
                        line=dict(color='blue')
                    ),
                    row=1, col=1
                )
                
                fig.add_trace(
                    go.Scatter(
                        x=agg_data['time_window_start'],
                        y=agg_data['units_per_hour'],
                        mode='lines+markers',
                        name='Total Units/Hour',
                        line=dict(color='green')
                    ),
                    row=1, col=2
                )
                
                fig.add_trace(
                    go.Scatter(
                        x=agg_data['time_window_start'],
                        y=agg_data['first_pass_yield_percent'],
                        mode='lines+markers',
                        name='Avg First Pass Yield %',
                        line=dict(color='orange')
                    ),
                    row=2, col=1
                )
                
                fig.add_trace(
                    go.Scatter(
                        x=agg_data['time_window_start'],
                        y=agg_data['total_downtime_minutes'],
                        mode='lines+markers',
                        name='Total Downtime Minutes',
                        line=dict(color='red')
                    ),
                    row=2, col=2
                )
            
            fig.update_layout(height=600, showlegend=False)
            st.plotly_chart(fig, use_container_width=True)
        
        # Production line comparison (if showing all lines)
        if selected_line == "All Lines":
            st.subheader("🏭 Production Line Comparison")
            
            # Get latest data for each line
            latest_hour = production_data['time_window_start'].max()
            comparison_data = production_data[production_data['time_window_start'] == latest_hour]
            
            col1, col2 = st.columns(2)
            
            with col1:
                # Efficiency comparison
                fig = px.bar(
                    comparison_data,
                    x='line_id',
                    y='production_efficiency_percent',
                    title="Production Efficiency by Line",
                    color='production_efficiency_percent',
                    color_continuous_scale='RdYlGn'
                )
                fig.update_layout(height=400)
                st.plotly_chart(fig, use_container_width=True)
            
            with col2:
                # Units per hour comparison
                fig = px.bar(
                    comparison_data,
                    x='line_id',
                    y='units_per_hour',
                    title="Production Rate by Line (Units/Hour)",
                    color='units_per_hour',
                    color_continuous_scale='Blues'
                )
                fig.update_layout(height=400)
                st.plotly_chart(fig, use_container_width=True)
        
        # Detailed data table
        st.subheader("📋 Detailed Production Data")
        
        # Format data for display
        display_data = production_data.copy()
        display_data['time_window_start'] = pd.to_datetime(display_data['time_window_start']).dt.strftime('%Y-%m-%d %H:%M')
        
        # Select relevant columns for display
        display_columns = [
            'time_window_start', 'line_id', 'line_name', 'shift_name',
            'total_units_produced', 'production_efficiency_percent',
            'units_per_hour', 'first_pass_yield_percent', 'total_downtime_minutes'
        ]
        
        if all(col in display_data.columns for col in display_columns):
            st.dataframe(
                display_data[display_columns].round(2),
                use_container_width=True,
                hide_index=True
            )
        else:
            st.dataframe(display_data.round(2), use_container_width=True, hide_index=True)
    
    except Exception as e:
        st.error(f"Error loading production data: {str(e)}")
        st.info("Please ensure the production aggregation tables contain data.")

def render_quality():
    """Render quality control page"""
    st.markdown('<h1 class="main-header">🔍 Quality Control</h1>', unsafe_allow_html=True)
    
    try:
        # Get product list for filtering
        product_query = """
        SELECT DISTINCT
            product_id,
            product_name,
            product_category
        FROM MANUFACTURING_DEMO.ANALYTICS.DIM_PRODUCT
        WHERE is_active = TRUE
        ORDER BY product_id
        """
        products = session.sql(product_query).to_pandas()
        
        if products.empty:
            st.warning("No product data available.")
            return
        
        # Time range and filter controls
        col1, col2, col3 = st.columns(3)
        
        with col1:
            time_range = st.selectbox(
                "Time Range:",
                ["Last Hour", "Last 4 Hours", "Last 24 Hours", "Last Week"],
                index=2
            )
        
        with col2:
            selected_product = st.selectbox(
                "Product:",
                ["All Products"] + products['product_id'].tolist(),
                format_func=lambda x: x if x == "All Products" else f"{x} - {products[products['product_id']==x]['product_name'].iloc[0] if not products[products['product_id']==x]['product_name'].empty else x}"
            )
        
        with col3:
            aggregation_level = st.selectbox(
                "Aggregation:",
                ["HOUR", "SHIFT", "DAY"],
                index=0
            )
        
        # Map time range to hours
        time_map = {
            "Last Hour": 1,
            "Last 4 Hours": 4,
            "Last 24 Hours": 24, 
            "Last Week": 168
        }
        hours = time_map[time_range]
        
        # Build query filters
        product_filter = f"AND product_id = '{selected_product}'" if selected_product != "All Products" else ""
        
        quality_query = f"""
        SELECT 
            product_id,
            product_name,
            line_id,
            time_window_start,
            time_window_end,
            aggregation_level,
            total_tests_conducted,
            tests_passed,
            tests_failed,
            pass_rate_percent,
            critical_defects_count,
            major_defects_count,
            minor_defects_count,
            total_defects_count,
            defect_rate_per_thousand,
            top_defect_type_1,
            top_defect_type_1_count,
            top_defect_type_2,
            top_defect_type_2_count,
            top_defect_type_3,
            top_defect_type_3_count
        FROM MANUFACTURING_DEMO.AGGREGATION.AGG_QUALITY_SUMMARY
        WHERE time_window_start >= CURRENT_TIMESTAMP() - INTERVAL '{hours} hours'
            {product_filter}
            AND aggregation_level = '{aggregation_level}'
        ORDER BY time_window_start DESC
        """
        
        quality_data = session.sql(quality_query).to_pandas()
        
        if quality_data.empty:
            st.info("No quality data available for the selected filters.")
            return
        
        # Current quality metrics summary
        st.subheader("📊 Current Quality Performance")
        
        if selected_product != "All Products":
            # Single product metrics
            latest_data = quality_data.iloc[0]
            
            col1, col2, col3, col4 = st.columns(4)
            
            with col1:
                pass_rate = latest_data['pass_rate_percent']
                pass_color = "🟢" if pass_rate >= 95 else "🟡" if pass_rate >= 90 else "🔴"
                st.metric(
                    "Pass Rate",
                    f"{pass_rate:.1f}% {pass_color}"
                )
            
            with col2:
                st.metric(
                    "Tests Conducted", 
                    f"{latest_data['total_tests_conducted']:,.0f}"
                )
            
            with col3:
                st.metric(
                    "Defect Rate",
                    f"{latest_data['defect_rate_per_thousand']:.1f}/1000"
                )
            
            with col4:
                st.metric(
                    "Critical Defects",
                    f"{latest_data['critical_defects_count']:,.0f}"
                )
        
        else:
            # Aggregate metrics across all products
            latest_time = quality_data['time_window_start'].max()
            latest_data = quality_data[quality_data['time_window_start'] == latest_time]
            
            col1, col2, col3, col4 = st.columns(4)
            
            with col1:
                # Weighted average pass rate
                total_tests = latest_data['total_tests_conducted'].sum()
                total_passed = latest_data['tests_passed'].sum()
                avg_pass_rate = (total_passed / total_tests * 100) if total_tests > 0 else 0
                pass_color = "🟢" if avg_pass_rate >= 95 else "🟡" if avg_pass_rate >= 90 else "🔴"
                st.metric(
                    "Overall Pass Rate",
                    f"{avg_pass_rate:.1f}% {pass_color}"
                )
            
            with col2:
                total_tests_all = latest_data['total_tests_conducted'].sum()
                st.metric(
                    "Total Tests",
                    f"{total_tests_all:,.0f}"
                )
            
            with col3:
                total_defects = latest_data['total_defects_count'].sum()
                total_units = latest_data['total_tests_conducted'].sum()
                defect_rate = (total_defects / total_units * 1000) if total_units > 0 else 0
                st.metric(
                    "Avg Defect Rate",
                    f"{defect_rate:.1f}/1000"
                )
            
            with col4:
                total_critical = latest_data['critical_defects_count'].sum()
                st.metric(
                    "Total Critical Defects",
                    f"{total_critical:,.0f}"
                )
        
        # Quality trends
        st.subheader("📈 Quality Trends")
        
        if len(quality_data) > 1:
            fig = make_subplots(
                rows=2, cols=2,
                subplot_titles=(
                    'Pass Rate %',
                    'Defect Rate per 1000',
                    'Tests Conducted',
                    'Critical Defects'
                ),
                vertical_spacing=0.1
            )
            
            if selected_product != "All Products":
                # Single product trends
                fig.add_trace(
                    go.Scatter(
                        x=quality_data['time_window_start'],
                        y=quality_data['pass_rate_percent'],
                        mode='lines+markers',
                        name='Pass Rate %',
                        line=dict(color='green')
                    ),
                    row=1, col=1
                )
                
                fig.add_trace(
                    go.Scatter(
                        x=quality_data['time_window_start'],
                        y=quality_data['defect_rate_per_thousand'],
                        mode='lines+markers',
                        name='Defect Rate',
                        line=dict(color='red')
                    ),
                    row=1, col=2
                )
                
                fig.add_trace(
                    go.Scatter(
                        x=quality_data['time_window_start'],
                        y=quality_data['total_tests_conducted'],
                        mode='lines+markers',
                        name='Tests Conducted',
                        line=dict(color='blue')
                    ),
                    row=2, col=1
                )
                
                fig.add_trace(
                    go.Scatter(
                        x=quality_data['time_window_start'],
                        y=quality_data['critical_defects_count'],
                        mode='lines+markers',
                        name='Critical Defects',
                        line=dict(color='orange')
                    ),
                    row=2, col=2
                )
            
            else:
                # Multi-product trends (aggregate by time)
                agg_data = quality_data.groupby('time_window_start').agg({
                    'total_tests_conducted': 'sum',
                    'tests_passed': 'sum',
                    'total_defects_count': 'sum',
                    'critical_defects_count': 'sum'
                }).reset_index()
                
                # Calculate aggregated metrics
                agg_data['pass_rate_percent'] = (agg_data['tests_passed'] / agg_data['total_tests_conducted'] * 100).fillna(0)
                agg_data['defect_rate_per_thousand'] = (agg_data['total_defects_count'] / agg_data['total_tests_conducted'] * 1000).fillna(0)
                
                fig.add_trace(
                    go.Scatter(
                        x=agg_data['time_window_start'],
                        y=agg_data['pass_rate_percent'],
                        mode='lines+markers',
                        name='Overall Pass Rate %',
                        line=dict(color='green')
                    ),
                    row=1, col=1
                )
                
                fig.add_trace(
                    go.Scatter(
                        x=agg_data['time_window_start'],
                        y=agg_data['defect_rate_per_thousand'],
                        mode='lines+markers',
                        name='Overall Defect Rate',
                        line=dict(color='red')
                    ),
                    row=1, col=2
                )
                
                fig.add_trace(
                    go.Scatter(
                        x=agg_data['time_window_start'],
                        y=agg_data['total_tests_conducted'],
                        mode='lines+markers',
                        name='Total Tests',
                        line=dict(color='blue')
                    ),
                    row=2, col=1
                )
                
                fig.add_trace(
                    go.Scatter(
                        x=agg_data['time_window_start'],
                        y=agg_data['critical_defects_count'],
                        mode='lines+markers',
                        name='Total Critical Defects',
                        line=dict(color='orange')
                    ),
                    row=2, col=2
                )
            
            fig.update_layout(height=600, showlegend=False)
            st.plotly_chart(fig, use_container_width=True)
        
        # Defect analysis
        st.subheader("🔍 Defect Analysis")
        
        col1, col2 = st.columns(2)
        
        with col1:
            # Defect type breakdown (latest data)
            latest_time = quality_data['time_window_start'].max()
            latest_defects = quality_data[quality_data['time_window_start'] == latest_time]
            
            if not latest_defects.empty:
                # Aggregate defect types
                defect_summary = latest_defects.agg({
                    'critical_defects_count': 'sum',
                    'major_defects_count': 'sum', 
                    'minor_defects_count': 'sum'
                })
                
                defect_types = ['Critical', 'Major', 'Minor']
                defect_counts = [
                    defect_summary['critical_defects_count'],
                    defect_summary['major_defects_count'],
                    defect_summary['minor_defects_count']
                ]
                
                fig = px.pie(
                    values=defect_counts,
                    names=defect_types,
                    title="Defect Severity Distribution",
                    color_discrete_map={
                        'Critical': '#ff6b6b',
                        'Major': '#ffa726', 
                        'Minor': '#ffee58'
                    }
                )
                fig.update_layout(height=400)
                st.plotly_chart(fig, use_container_width=True)
        
        with col2:
            # Top defect types
            st.markdown("### 🏷️ Top Defect Types")
            
            latest_defects = quality_data[quality_data['time_window_start'] == latest_time]
            
            if not latest_defects.empty:
                # Collect all defect types and counts
                all_defects = []
                for _, row in latest_defects.iterrows():
                    if pd.notna(row['top_defect_type_1']) and row['top_defect_type_1_count'] > 0:
                        all_defects.append({
                            'type': row['top_defect_type_1'],
                            'count': row['top_defect_type_1_count']
                        })
                    if pd.notna(row['top_defect_type_2']) and row['top_defect_type_2_count'] > 0:
                        all_defects.append({
                            'type': row['top_defect_type_2'],
                            'count': row['top_defect_type_2_count']
                        })
                    if pd.notna(row['top_defect_type_3']) and row['top_defect_type_3_count'] > 0:
                        all_defects.append({
                            'type': row['top_defect_type_3'],
                            'count': row['top_defect_type_3_count']
                        })
                
                if all_defects:
                    defect_df = pd.DataFrame(all_defects)
                    defect_summary = defect_df.groupby('type')['count'].sum().sort_values(ascending=False).head(5)
                    
                    fig = px.bar(
                        x=defect_summary.values,
                        y=defect_summary.index,
                        orientation='h',
                        title="Top 5 Defect Types",
                        labels={'x': 'Count', 'y': 'Defect Type'}
                    )
                    fig.update_layout(height=400)
                    st.plotly_chart(fig, use_container_width=True)
                else:
                    st.info("No defect type data available.")
        
        # Product comparison (if showing all products)
        if selected_product == "All Products":
            st.subheader("📋 Product Quality Comparison")
            
            latest_time = quality_data['time_window_start'].max()
            comparison_data = quality_data[quality_data['time_window_start'] == latest_time]
            
            if not comparison_data.empty:
                col1, col2 = st.columns(2)
                
                with col1:
                    fig = px.bar(
                        comparison_data,
                        x='product_id',
                        y='pass_rate_percent',
                        title="Pass Rate by Product",
                        color='pass_rate_percent',
                        color_continuous_scale='RdYlGn'
                    )
                    fig.update_layout(height=400)
                    fig.update_xaxes(tickangle=45)
                    st.plotly_chart(fig, use_container_width=True)
                
                with col2:
                    fig = px.bar(
                        comparison_data,
                        x='product_id',
                        y='defect_rate_per_thousand',
                        title="Defect Rate by Product",
                        color='defect_rate_per_thousand',
                        color_continuous_scale='Reds'
                    )
                    fig.update_layout(height=400)
                    fig.update_xaxes(tickangle=45)
                    st.plotly_chart(fig, use_container_width=True)
        
        # Detailed data table
        st.subheader("📋 Detailed Quality Data")
        
        # Format data for display
        display_data = quality_data.copy()
        display_data['time_window_start'] = pd.to_datetime(display_data['time_window_start']).dt.strftime('%Y-%m-%d %H:%M')
        
        # Select relevant columns
        display_columns = [
            'time_window_start', 'product_id', 'product_name', 'line_id',
            'total_tests_conducted', 'pass_rate_percent', 'defect_rate_per_thousand',
            'critical_defects_count', 'major_defects_count', 'minor_defects_count'
        ]
        
        if all(col in display_data.columns for col in display_columns):
            st.dataframe(
                display_data[display_columns].round(2),
                use_container_width=True,
                hide_index=True
            )
        else:
            st.dataframe(display_data.round(2), use_container_width=True, hide_index=True)
    
    except Exception as e:
        st.error(f"Error loading quality data: {str(e)}")
        st.info("Please ensure the quality aggregation tables contain data.")

def render_maintenance():
    """Render predictive maintenance page"""
    st.markdown('<h1 class="main-header">🔧 Predictive Maintenance</h1>', unsafe_allow_html=True)
    
    try:
        # Get equipment list for filtering
        equipment_query = """
        SELECT DISTINCT
            equipment_id,
            equipment_name,
            equipment_type
        FROM MANUFACTURING_DEMO.ANALYTICS.DIM_EQUIPMENT
        WHERE is_active = TRUE
        ORDER BY equipment_id
        """
        equipment_list = session.sql(equipment_query).to_pandas()
        
        if equipment_list.empty:
            st.warning("No equipment data available.")
            return
        
        # Filter controls
        col1, col2 = st.columns(2)
        
        with col1:
            selected_equipment = st.selectbox(
                "Equipment:",
                ["All Equipment"] + equipment_list['equipment_id'].tolist(),
                format_func=lambda x: x if x == "All Equipment" else f"{x} - {equipment_list[equipment_list['equipment_id']==x]['equipment_name'].iloc[0] if not equipment_list[equipment_list['equipment_id']==x]['equipment_name'].empty else x}"
            )
        
        with col2:
            priority_filter = st.selectbox(
                "Priority Filter:",
                ["All Priorities", "CRITICAL", "HIGH", "MEDIUM", "LOW"]
            )
        
        # Build query filters
        equipment_filter = f"AND equipment_id = '{selected_equipment}'" if selected_equipment != "All Equipment" else ""
        priority_filter_sql = f"AND maintenance_priority = '{priority_filter}'" if priority_filter != "All Priorities" else ""
        
        # Get maintenance data
        maintenance_query = f"""
        SELECT 
            equipment_id,
            equipment_name,
            equipment_type,
            snapshot_timestamp,
            overall_health_score,
            health_trend,
            motor_health_score,
            bearing_health_score,
            belt_health_score,
            sensor_health_score,
            predicted_failure_days,
            failure_probability_30_days,
            failure_probability_60_days,
            failure_probability_90_days,
            recommended_action,
            maintenance_priority,
            estimated_maintenance_cost,
            estimated_downtime_hours,
            days_since_last_maintenance,
            next_scheduled_maintenance_date,
            maintenance_overdue_days,
            temperature_alert,
            vibration_alert,
            pressure_alert,
            efficiency_alert
        FROM MANUFACTURING_DEMO.AGGREGATION.AGG_PREDICTIVE_MAINTENANCE
        WHERE snapshot_timestamp >= CURRENT_TIMESTAMP() - INTERVAL '1 hour'
            {equipment_filter}
            {priority_filter_sql}
        ORDER BY maintenance_priority DESC, overall_health_score ASC
        """
        
        maintenance_data = session.sql(maintenance_query).to_pandas()
        
        if maintenance_data.empty:
            st.info("No maintenance data available for the selected filters.")
            return
        
        # Alert summary
        st.subheader("🚨 Maintenance Alerts Summary")
        
        col1, col2, col3, col4 = st.columns(4)
        
        critical_count = len(maintenance_data[maintenance_data['maintenance_priority'] == 'CRITICAL'])
        high_count = len(maintenance_data[maintenance_data['maintenance_priority'] == 'HIGH'])
        overdue_count = len(maintenance_data[maintenance_data['maintenance_overdue_days'] > 0])
        avg_health = maintenance_data['overall_health_score'].mean()
        
        with col1:
            if critical_count > 0:
                st.markdown(f"""
                <div class="kpi-card alert-high">
                    <div class="metric-value">{critical_count}</div>
                    <div class="metric-label">🔴 Critical Alerts</div>
                </div>
                """, unsafe_allow_html=True)
            else:
                st.success(f"✅ No Critical Alerts")
        
        with col2:
            if high_count > 0:
                st.markdown(f"""
                <div class="kpi-card alert-medium">
                    <div class="metric-value">{high_count}</div>
                    <div class="metric-label">🟡 High Priority</div>
                </div>
                """, unsafe_allow_html=True)
            else:
                st.success(f"✅ No High Priority Alerts")
        
        with col3:
            if overdue_count > 0:
                st.markdown(f"""
                <div class="kpi-card alert-high">
                    <div class="metric-value">{overdue_count}</div>
                    <div class="metric-label">⏰ Overdue Maintenance</div>
                </div>
                """, unsafe_allow_html=True)
            else:
                st.success("✅ No Overdue Maintenance")
        
        with col4:
            health_color = "🟢" if avg_health >= 80 else "🟡" if avg_health >= 60 else "🔴"
            st.metric(
                "Avg Health Score",
                f"{avg_health:.1f}% {health_color}"
            )
        
        # Equipment health overview
        if selected_equipment == "All Equipment":
            st.subheader("⚙️ Equipment Health Overview")
            
            # Health score distribution
            col1, col2 = st.columns(2)
            
            with col1:
                fig = px.scatter(
                    maintenance_data,
                    x='equipment_id',
                    y='overall_health_score',
                    color='maintenance_priority',
                    size='predicted_failure_days',
                    hover_data=['equipment_name', 'equipment_type', 'health_trend'],
                    color_discrete_map={
                        'LOW': 'green',
                        'MEDIUM': 'yellow',
                        'HIGH': 'orange', 
                        'CRITICAL': 'red'
                    },
                    title="Equipment Health Scores by Priority"
                )
                fig.update_layout(height=400)
                fig.update_xaxes(tickangle=45)
                st.plotly_chart(fig, use_container_width=True)
            
            with col2:
                # Maintenance priority distribution
                priority_counts = maintenance_data['maintenance_priority'].value_counts()
                
                fig = px.pie(
                    values=priority_counts.values,
                    names=priority_counts.index,
                    title="Maintenance Priority Distribution",
                    color_discrete_map={
                        'LOW': '#90EE90',
                        'MEDIUM': '#FFD700',
                        'HIGH': '#FFA500',
                        'CRITICAL': '#FF6347'
                    }
                )
                fig.update_layout(height=400)
                st.plotly_chart(fig, use_container_width=True)
        
        # Detailed equipment view
        if selected_equipment != "All Equipment":
            st.subheader(f"🔧 Detailed Analysis: {selected_equipment}")
            
            equipment_detail = maintenance_data.iloc[0]
            
            # Component health scores
            st.markdown("### 🎯 Component Health Scores")
            
            col1, col2, col3, col4 = st.columns(4)
            
            with col1:
                motor_score = equipment_detail['motor_health_score']
                motor_color = "🟢" if motor_score >= 80 else "🟡" if motor_score >= 60 else "🔴"
                st.metric("Motor Health", f"{motor_score:.1f}% {motor_color}")
            
            with col2:
                bearing_score = equipment_detail['bearing_health_score']
                bearing_color = "🟢" if bearing_score >= 80 else "🟡" if bearing_score >= 60 else "🔴"
                st.metric("Bearing Health", f"{bearing_score:.1f}% {bearing_color}")
            
            with col3:
                belt_score = equipment_detail['belt_health_score']
                belt_color = "🟢" if belt_score >= 80 else "🟡" if belt_score >= 60 else "🔴"
                st.metric("Belt Health", f"{belt_score:.1f}% {belt_color}")
            
            with col4:
                sensor_score = equipment_detail['sensor_health_score']
                sensor_color = "🟢" if sensor_score >= 80 else "🟡" if sensor_score >= 60 else "🔴"
                st.metric("Sensor Health", f"{sensor_score:.1f}% {sensor_color}")
            
            # Failure predictions
            st.markdown("### 📈 Failure Probability Predictions")
            
            failure_data = {
                'Time Period': ['30 Days', '60 Days', '90 Days'],
                'Failure Probability': [
                    equipment_detail['failure_probability_30_days'],
                    equipment_detail['failure_probability_60_days'],
                    equipment_detail['failure_probability_90_days']
                ]
            }
            
            fig = px.bar(
                failure_data,
                x='Time Period',
                y='Failure Probability',
                title="Predicted Failure Probability",
                color='Failure Probability',
                color_continuous_scale='Reds'
            )
            fig.update_layout(height=400)
            st.plotly_chart(fig, use_container_width=True)
            
            # Maintenance recommendations
            st.markdown("### 💡 Maintenance Recommendations")
            
            col1, col2 = st.columns(2)
            
            with col1:
                st.info(f"**Recommended Action:** {equipment_detail['recommended_action']}")
                st.metric("Estimated Cost", f"${equipment_detail['estimated_maintenance_cost']:,.0f}")
                st.metric("Estimated Downtime", f"{equipment_detail['estimated_downtime_hours']:.1f} hours")
            
            with col2:
                st.metric("Days Since Last Maintenance", f"{equipment_detail['days_since_last_maintenance']:.0f}")
                
                if pd.notna(equipment_detail['next_scheduled_maintenance_date']):
                    st.info(f"**Next Scheduled:** {equipment_detail['next_scheduled_maintenance_date']}")
                
                if equipment_detail['maintenance_overdue_days'] > 0:
                    st.error(f"⚠️ **Overdue by {equipment_detail['maintenance_overdue_days']:.0f} days**")
        
        # Alert status table
        st.subheader("🚨 Current Alert Status")
        
        # Create alert summary
        alert_data = []
        
        for _, row in maintenance_data.iterrows():
            alerts = []
            if row['temperature_alert']:
                alerts.append('🌡️ Temperature')
            if row['vibration_alert']:
                alerts.append('📳 Vibration')
            if row['pressure_alert']:
                alerts.append('💨 Pressure')
            if row['efficiency_alert']:
                alerts.append('⚡ Efficiency')
            
            alert_data.append({
                'Equipment ID': row['equipment_id'],
                'Equipment Name': row['equipment_name'],
                'Health Score': f"{row['overall_health_score']:.1f}%",
                'Priority': row['maintenance_priority'],
                'Health Trend': row['health_trend'],
                'Days to Failure': row['predicted_failure_days'],
                'Active Alerts': ', '.join(alerts) if alerts else 'None',
                'Recommended Action': row['recommended_action']
            })
        
        if alert_data:
            alert_df = pd.DataFrame(alert_data)
            
            # Style the dataframe
            def highlight_priority(val):
                if val == 'CRITICAL':
                    return 'background-color: #ffebee; color: #c62828'
                elif val == 'HIGH':
                    return 'background-color: #fff3e0; color: #ef6c00'
                elif val == 'MEDIUM':
                    return 'background-color: #f3e5f5; color: #7b1fa2'
                return ''
            
            styled_df = alert_df.style.applymap(highlight_priority, subset=['Priority'])
            st.dataframe(styled_df, use_container_width=True, hide_index=True)
        
        # Cost analysis
        if len(maintenance_data) > 1:
            st.subheader("💰 Maintenance Cost Analysis")
            
            col1, col2 = st.columns(2)
            
            with col1:
                # Cost by priority
                cost_by_priority = maintenance_data.groupby('maintenance_priority')['estimated_maintenance_cost'].sum().sort_values(ascending=False)
                
                fig = px.bar(
                    x=cost_by_priority.index,
                    y=cost_by_priority.values,
                    title="Estimated Maintenance Cost by Priority",
                    labels={'x': 'Priority', 'y': 'Cost ($)'},
                    color=cost_by_priority.index,
                    color_discrete_map={
                        'CRITICAL': '#ff6b6b',
                        'HIGH': '#ffa726',
                        'MEDIUM': '#ab47bc',
                        'LOW': '#66bb6a'
                    }
                )
                fig.update_layout(height=400)
                st.plotly_chart(fig, use_container_width=True)
            
            with col2:
                # Downtime analysis
                downtime_by_priority = maintenance_data.groupby('maintenance_priority')['estimated_downtime_hours'].sum().sort_values(ascending=False)
                
                fig = px.bar(
                    x=downtime_by_priority.index,
                    y=downtime_by_priority.values,
                    title="Estimated Downtime by Priority",
                    labels={'x': 'Priority', 'y': 'Hours'},
                    color=downtime_by_priority.index,
                    color_discrete_map={
                        'CRITICAL': '#ff6b6b',
                        'HIGH': '#ffa726',
                        'MEDIUM': '#ab47bc',
                        'LOW': '#66bb6a'
                    }
                )
                fig.update_layout(height=400)
                st.plotly_chart(fig, use_container_width=True)
        
        # Summary metrics
        total_cost = maintenance_data['estimated_maintenance_cost'].sum()
        total_downtime = maintenance_data['estimated_downtime_hours'].sum()
        
        st.markdown("---")
        col1, col2, col3 = st.columns(3)
        
        with col1:
            st.metric("Total Estimated Cost", f"${total_cost:,.0f}")
        
        with col2:
            st.metric("Total Estimated Downtime", f"{total_downtime:.1f} hours")
        
        with col3:
            equipment_count = len(maintenance_data)
            st.metric("Equipment Monitored", f"{equipment_count}")
    
    except Exception as e:
        st.error(f"Error loading maintenance data: {str(e)}")
        st.info("Please ensure the predictive maintenance aggregation tables contain data.")

# Main app logic
def main():
    """Main application logic"""
    page = show_navigation()
    
    if page == "dashboard":
        render_dashboard()
    elif page == "equipment":
        render_equipment()
    elif page == "production":
        render_production()
    elif page == "quality":
        render_quality()
    elif page == "maintenance":
        render_maintenance()

if __name__ == "__main__":
    main() 