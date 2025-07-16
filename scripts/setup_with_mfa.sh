#!/bin/bash

# =====================================================
# Manufacturing Streaming Demo - MFA-Aware Setup
# =====================================================
# Special setup script for users with MFA enabled
# Provides better MFA handling and privilege management

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
SNOWFLAKE_ACCOUNT=""
SNOWFLAKE_USER=""
SNOWFLAKE_PASSWORD=""
SNOWFLAKE_ROLE="SYSADMIN"  # Default to SYSADMIN for database creation

# Print colored message
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Print section header
print_section() {
    echo ""
    print_message $BLUE "====================================================="
    print_message $BLUE "$1"
    print_message $BLUE "====================================================="
}

# Help function
show_help() {
    cat << EOF
Manufacturing Real-Time Streaming Demo - MFA Setup

Special setup script for Snowflake accounts with MFA enabled.

Usage: $0 [OPTIONS]

Options:
  -a, --account ACCOUNT         Snowflake account identifier
  -u, --user USER              Snowflake username  
  -p, --password PASSWORD      Snowflake password
  -r, --role ROLE              Snowflake role (default: SYSADMIN)
  -h, --help                   Show this help message

MFA Support:
  ✅ Extended login timeout (2 minutes)
  ✅ Session keep-alive during setup
  ✅ Better error handling for MFA timeouts
  ✅ Default SYSADMIN role for privileges

Examples:
  # Basic MFA setup
  $0 -a myaccount -u myuser -p mypassword
  
  # With specific role
  $0 -a myaccount -u myuser -p mypassword -r ACCOUNTADMIN

Required Privileges:
  Your role needs these permissions:
  • CREATE DATABASE ON ACCOUNT
  • CREATE WAREHOUSE ON ACCOUNT  
  • CREATE INTEGRATION ON ACCOUNT (for containers)

Recommended Roles:
  🔧 SYSADMIN    - Can create databases and warehouses
  👑 ACCOUNTADMIN - Full account privileges (if you have access)

EOF
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -a|--account)
                SNOWFLAKE_ACCOUNT="$2"
                shift 2
                ;;
            -u|--user)
                SNOWFLAKE_USER="$2"
                shift 2
                ;;
            -p|--password)
                SNOWFLAKE_PASSWORD="$2"
                shift 2
                ;;
            -r|--role)
                SNOWFLAKE_ROLE="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                echo -e "${RED}Error: Unknown option $1${NC}"
                show_help
                exit 1
                ;;
        esac
    done
}

# Test MFA connection
test_mfa_connection() {
    print_section "Testing MFA Connection"
    
    print_message $YELLOW "🔐 Testing Snowflake connection with MFA..."
    print_message $YELLOW "📱 Please complete MFA authentication when prompted"
    
    # Create a simple test script
    cat > /tmp/test_mfa_connection.py << EOF
import snowflake.connector
import sys

try:
    print("🔌 Attempting connection...")
    print("📱 Complete MFA authentication if prompted...")
    
    conn = snowflake.connector.connect(
        account='$SNOWFLAKE_ACCOUNT',
        user='$SNOWFLAKE_USER',
        password='$SNOWFLAKE_PASSWORD',
        role='$SNOWFLAKE_ROLE',
        client_session_keep_alive=True,
        login_timeout=120
    )
    
    # Test basic query
    cursor = conn.cursor()
    cursor.execute("SELECT CURRENT_USER(), CURRENT_ROLE(), CURRENT_ACCOUNT()")
    result = cursor.fetchone()
    
    print(f"✅ Connected successfully!")
    print(f"   User: {result[0]}")
    print(f"   Role: {result[1]}")
    print(f"   Account: {result[2]}")
    
    # Test database creation privileges
    try:
        cursor.execute("CREATE DATABASE IF NOT EXISTS MFA_TEST_DB")
        cursor.execute("DROP DATABASE IF EXISTS MFA_TEST_DB")
        print("✅ Database creation privileges confirmed")
    except Exception as e:
        if "Insufficient privileges" in str(e):
            print("❌ Insufficient privileges for database creation")
            print("💡 Try using SYSADMIN or ACCOUNTADMIN role")
            sys.exit(1)
        else:
            print(f"⚠️  Privilege test failed: {e}")
    
    cursor.close()
    conn.close()
    
except Exception as e:
    print(f"❌ Connection failed: {e}")
    if "timeout" in str(e).lower():
        print("💡 This might be an MFA timeout. Try running the script again.")
    elif "authentication" in str(e).lower():
        print("💡 Check your username, password, and complete MFA authentication.")
    sys.exit(1)
EOF

    # Run the test
    if [[ -d "venv" ]]; then
        source venv/bin/activate
    fi
    
    python3 /tmp/test_mfa_connection.py
    rm -f /tmp/test_mfa_connection.py
    
    print_message $GREEN "🎉 MFA connection test successful!"
}

# Main execution
main() {
    print_message $PURPLE "🔐 Manufacturing Streaming Demo - MFA Setup"
    print_message $PURPLE "Enhanced setup for Multi-Factor Authentication"
    echo ""
    
    # Parse arguments
    parse_arguments "$@"
    
    # Get credentials if not provided
    if [[ -z "$SNOWFLAKE_ACCOUNT" ]]; then
        read -p "Enter your Snowflake account identifier: " SNOWFLAKE_ACCOUNT
    fi
    if [[ -z "$SNOWFLAKE_USER" ]]; then
        read -p "Enter your Snowflake username: " SNOWFLAKE_USER
    fi
    if [[ -z "$SNOWFLAKE_PASSWORD" ]]; then
        read -s -p "Enter your Snowflake password: " SNOWFLAKE_PASSWORD
        echo ""
    fi
    
    print_message $YELLOW "🔧 Using role: $SNOWFLAKE_ROLE"
    
    # Test MFA connection first
    test_mfa_connection
    
    # Run the Mac setup script if available, otherwise run main setup
    if [[ -f "scripts/setup_mac.sh" ]]; then
        print_message $YELLOW "🍎 Running Mac setup script..."
        ./scripts/setup_mac.sh \
            --account "$SNOWFLAKE_ACCOUNT" \
            --user "$SNOWFLAKE_USER" \
            --password "$SNOWFLAKE_PASSWORD" \
            --role "$SNOWFLAKE_ROLE" \
            --skip-prereq-install
    else
        print_message $YELLOW "🔧 Running main setup script..."
        ./scripts/setup_demo.sh \
            --account "$SNOWFLAKE_ACCOUNT" \
            --user "$SNOWFLAKE_USER" \
            --password "$SNOWFLAKE_PASSWORD" \
            --role "$SNOWFLAKE_ROLE"
    fi
    
    print_message $GREEN "🎉 MFA setup completed successfully!"
    print_message $YELLOW "💡 Your Snowflake session will stay active during the demo"
}

# Run main function with all arguments
main "$@" 