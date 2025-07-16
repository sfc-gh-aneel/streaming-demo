#!/usr/bin/env python3
"""
SQL Executor for Snowflake
Executes SQL files against Snowflake when SnowSQL CLI is not available
"""

import argparse
import sys
import logging
from pathlib import Path

try:
    import snowflake.connector
except ImportError:
    print("Error: snowflake-connector-python is required. Install with: pip install snowflake-connector-python")
    sys.exit(1)

def setup_logging():
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s'
    )
    return logging.getLogger(__name__)

def validate_account_identifier(account):
    """Validate and provide suggestions for account identifier format"""
    logger = logging.getLogger(__name__)
    
    if not account:
        return False, "Account identifier is empty"
    
    # Common account identifier patterns
    valid_patterns = [
        "ACCOUNT.snowflakecomputing.com",
        "ACCOUNT.REGION.snowflakecomputing.com", 
        "ACCOUNT.REGION.CLOUD.snowflakecomputing.com",
        "ORGNAME-ACCOUNTNAME"
    ]
    
    # Check for common issues
    if '.snowflakecomputing.com' in account:
        logger.warning("Account identifier should not include '.snowflakecomputing.com' suffix")
        account = account.replace('.snowflakecomputing.com', '')
    
    if 'https://' in account:
        logger.warning("Account identifier should not include 'https://' prefix")
        account = account.replace('https://', '')
    
    return True, account

def execute_sql_file(connection, file_path):
    """Execute SQL commands from a file"""
    logger = logging.getLogger(__name__)
    
    try:
        with open(file_path, 'r') as file:
            sql_content = file.read()
        
        # Smart SQL statement splitting that handles stored procedures with $$ delimiters
        statements = []
        current_statement = ""
        in_procedure = False
        lines = sql_content.split('\n')
        
        for line in lines:
            # Skip pure comment lines and empty lines when not in a procedure
            if not in_procedure and (line.strip().startswith('--') or line.strip() == ''):
                continue
                
            current_statement += line + '\n'
            
            # Check if we're entering a stored procedure/function
            if '$$' in line and not in_procedure:
                in_procedure = True
            # Check if we're exiting a stored procedure/function
            elif '$$;' in line and in_procedure:
                in_procedure = False
                statements.append(current_statement.strip())
                current_statement = ""
            # Regular statement ending (not in procedure)
            elif line.strip().endswith(';') and not in_procedure:
                statements.append(current_statement.strip())
                current_statement = ""
        
        # Add any remaining statement
        if current_statement.strip():
            statements.append(current_statement.strip())
        
        # Filter out empty statements
        statements = [stmt for stmt in statements if stmt.strip()]
        
        cursor = connection.cursor()
        
        for i, statement in enumerate(statements, 1):
            if statement:
                try:
                    logger.info(f"Executing statement {i}/{len(statements)}...")
                    cursor.execute(statement)
                    logger.debug(f"Statement executed: {statement[:100]}...")
                except Exception as e:
                    logger.error(f"Error executing statement {i}: {str(e)}")
                    logger.error(f"Statement: {statement}")
                    raise
        
        cursor.close()
        logger.info(f"Successfully executed {len(statements)} statements from {file_path}")
        
    except Exception as e:
        logger.error(f"Error executing SQL file {file_path}: {str(e)}")
        raise

def main():
    parser = argparse.ArgumentParser(description='Execute SQL files against Snowflake')
    parser.add_argument('--account', required=True, help='Snowflake account identifier')
    parser.add_argument('--user', required=True, help='Snowflake username')
    parser.add_argument('--password', required=True, help='Snowflake password')
    parser.add_argument('--role', default='PUBLIC', help='Snowflake role')
    parser.add_argument('--warehouse', help='Snowflake warehouse')
    parser.add_argument('--database', help='Snowflake database')
    parser.add_argument('--schema', help='Snowflake schema')
    parser.add_argument('--file', required=True, help='SQL file to execute')
    parser.add_argument('--verbose', '-v', action='store_true', help='Enable verbose logging')
    
    args = parser.parse_args()
    
    # Setup logging
    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)
    
    logger = setup_logging()
    
    # Check if file exists
    sql_file = Path(args.file)
    if not sql_file.exists():
        logger.error(f"SQL file not found: {args.file}")
        sys.exit(1)
    
    try:
        # Validate account identifier
        is_valid, validated_account = validate_account_identifier(args.account)
        if not is_valid:
            logger.error(f"Invalid account identifier: {validated_account}")
            sys.exit(1)
        
        if validated_account != args.account:
            logger.info(f"Using cleaned account identifier: {validated_account}")
            args.account = validated_account
        
        # Connect to Snowflake
        logger.info("Connecting to Snowflake...")
        logger.info(f"Account: {args.account}")
        logger.info(f"User: {args.user}")
        logger.info(f"Role: {args.role}")
        
        conn_params = {
            'account': args.account,
            'user': args.user,
            'password': args.password,
            'role': args.role,
            'client_session_keep_alive': True,
            'login_timeout': 120  # Extended timeout for MFA
        }
        
        if args.warehouse:
            conn_params['warehouse'] = args.warehouse
        if args.database:
            conn_params['database'] = args.database
        if args.schema:
            conn_params['schema'] = args.schema
        
        conn = snowflake.connector.connect(**conn_params)
        logger.info("Connected to Snowflake successfully")
        
        # Execute SQL file
        execute_sql_file(conn, sql_file)
        
        # Close connection
        conn.close()
        logger.info("Disconnected from Snowflake")
        
        print("✓ SQL execution completed successfully")
        
    except snowflake.connector.errors.DatabaseError as e:
        error_str = str(e)
        if "404 Not Found" in error_str:
            logger.error("❌ Snowflake Connection Failed - 404 Not Found")
            logger.error("This usually means:")
            logger.error("  1. Account identifier is incorrect")
            logger.error("  2. Account doesn't exist or is suspended")
            logger.error("  3. Wrong region specified")
            logger.error("")
            logger.error("💡 Solutions:")
            logger.error("  • Check your account identifier format:")
            logger.error("    - Legacy: ACCOUNT (e.g., 'ab12345')")
            logger.error("    - With region: ACCOUNT.REGION (e.g., 'ab12345.us-east-1')")
            logger.error("    - With cloud: ACCOUNT.REGION.CLOUD (e.g., 'ab12345.us-east-1.aws')")
            logger.error("    - Organization: ORGNAME-ACCOUNTNAME (e.g., 'myorg-myaccount')")
            logger.error("  • Verify in Snowflake console: Admin > Accounts")
            logger.error("  • Check if account is active and not suspended")
        elif "Authentication" in error_str or "Login" in error_str:
            logger.error("❌ Authentication Failed")
            logger.error("Please check your username and password")
        elif "Insufficient privileges" in error_str or "SQL access control error" in error_str:
            logger.error("❌ Insufficient Privileges")
            logger.error("Your user account doesn't have permission to create databases.")
            logger.error("")
            logger.error("💡 Solutions:")
            logger.error("  1. Use a role with higher privileges:")
            logger.error("     --role SYSADMIN")
            logger.error("     --role ACCOUNTADMIN")
            logger.error("")
            logger.error("  2. Ask your admin to grant privileges:")
            logger.error("     GRANT CREATE DATABASE ON ACCOUNT TO ROLE your_role;")
            logger.error("     GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE your_role;")
            logger.error("")
            logger.error("  3. Try the setup with SYSADMIN role:")
            logger.error("     ./scripts/setup_mac.sh -a ACCOUNT -u USER -p PASS -r SYSADMIN")
        else:
            logger.error(f"❌ Database connection error: {str(e)}")
        sys.exit(1)
    except Exception as e:
        logger.error(f"❌ SQL execution failed: {str(e)}")
        sys.exit(1)

if __name__ == '__main__':
    main() 