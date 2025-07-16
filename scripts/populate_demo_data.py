#!/usr/bin/env python3
"""
Populate Manufacturing Demo Dimension Tables

This script populates the dimension tables and creates sample fact data 
for the manufacturing streaming demo.
"""

import os
import sys
import argparse
import getpass
import logging
from pathlib import Path
from execute_sql import execute_sql_file, setup_logging, validate_account_identifier

try:
    import snowflake.connector
except ImportError:
    print("Error: snowflake-connector-python is required. Install with: pip install snowflake-connector-python")
    sys.exit(1)

def main():
    parser = argparse.ArgumentParser(description='Populate Manufacturing Demo Dimension Tables')
    parser.add_argument('--account', required=True, help='Snowflake account name (e.g., abc12345.us-east-1)')
    parser.add_argument('--user', required=True, help='Snowflake username')
    parser.add_argument('--password', help='Snowflake password (will prompt if not provided)')
    parser.add_argument('--database', default='MANUFACTURING_DEMO', help='Database name (default: MANUFACTURING_DEMO)')
    parser.add_argument('--warehouse', default='ANALYTICS_WH', help='Warehouse to use (default: ANALYTICS_WH)')
    parser.add_argument('--role', default='SYSADMIN', help='Role to use (default: SYSADMIN)')
    
    args = parser.parse_args()
    
    # Get password if not provided
    if not args.password:
        args.password = getpass.getpass("Enter Snowflake password: ")
    
    # SQL file to execute
    sql_file = os.path.join(os.path.dirname(__file__), '..', 'sql', '07_populate_dimension_tables.sql')
    
    if not os.path.exists(sql_file):
        print(f"Error: SQL file not found: {sql_file}")
        sys.exit(1)
    
    print("🏭 Manufacturing Demo - Populating Dimension Tables")
    print("=" * 60)
    print(f"Account: {args.account}")
    print(f"User: {args.user}")
    print(f"Database: {args.database}")
    print(f"Warehouse: {args.warehouse}")
    print(f"Role: {args.role}")
    print("-" * 60)
    
    try:
        # Setup logging
        logger = setup_logging()
        
        # Validate account identifier
        is_valid, validated_account = validate_account_identifier(args.account)
        if not is_valid:
            print(f"❌ Error: Invalid account identifier: {validated_account}")
            sys.exit(1)
        
        if validated_account != args.account:
            print(f"Using cleaned account identifier: {validated_account}")
            args.account = validated_account
        
        print("📊 Executing dimension table population script...")
        print("This will populate:")
        print("  • DIM_EQUIPMENT (12 manufacturing equipment items)")
        print("  • DIM_PRODUCTION_LINE (4 production lines)")
        print("  • DIM_PRODUCT (16 products across 4 categories)")
        print("  • DIM_TIME (365 days with hourly/15-min intervals)")
        print("  • Sample FACT data (last 24 hours)")
        print("  • AGG_PREDICTIVE_MAINTENANCE data")
        print()
        
        # Connect to Snowflake
        print("Connecting to Snowflake...")
        conn_params = {
            'account': args.account,
            'user': args.user,
            'password': args.password,
            'role': args.role,
            'warehouse': args.warehouse,
            'database': args.database,
            'client_session_keep_alive': True,
            'login_timeout': 120
        }
        
        conn = snowflake.connector.connect(**conn_params)
        print("✅ Connected to Snowflake successfully")
        
        # Execute SQL file
        result = execute_sql_file(conn, Path(sql_file))
        
        # Close connection
        conn.close()
        
        if result:
            print("✅ SUCCESS: Dimension tables populated successfully!")
            print()
            print("📋 Next Steps:")
            print("1. Run aggregation tasks to populate AGG_* tables:")
            print("   CALL MANUFACTURING_DEMO.UTILITIES.CALCULATE_EQUIPMENT_PERFORMANCE();")
            print("   CALL MANUFACTURING_DEMO.UTILITIES.CALCULATE_PRODUCTION_METRICS();")
            print("   CALL MANUFACTURING_DEMO.UTILITIES.CALCULATE_QUALITY_SUMMARY();")
            print()
            print("2. Update your Streamlit app in Snowflake")
            print("3. Test all dashboard features!")
            print()
            print("🎯 Your manufacturing analytics dashboard should now have data!")
            
        else:
            print("❌ Error: Failed to populate dimension tables")
            sys.exit(1)
            
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main() 