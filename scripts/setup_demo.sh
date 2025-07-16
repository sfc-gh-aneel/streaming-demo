#!/bin/bash

# =====================================================
# Manufacturing Real-Time Streaming Demo Setup Script
# =====================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Configuration
SNOWFLAKE_ACCOUNT=""
SNOWFLAKE_USER=""
SNOWFLAKE_PASSWORD=""
SNOWFLAKE_ROLE=""
SKIP_BUILD=${SKIP_BUILD:-false}
SKIP_SQL=${SKIP_SQL:-false}
SKIP_CONTAINERS=${SKIP_CONTAINERS:-false}

# Help function
show_help() {
    echo "Manufacturing Real-Time Streaming Demo Setup"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -a, --account ACCOUNT      Snowflake account identifier"
    echo "  -u, --user USER           Snowflake username"
    echo "  -p, --password PASSWORD   Snowflake password"
    echo "  -r, --role ROLE           Snowflake role (default: PUBLIC)"
    echo "  --skip-build              Skip building containers"
    echo "  --skip-sql                Skip SQL setup"
    echo "  --skip-containers         Skip container deployment"
    echo "  -h, --help                Show this help message"
    echo ""
    echo "Environment Variables:"
    echo "  SNOWFLAKE_ACCOUNT         Snowflake account (can be used instead of -a)"
    echo "  SNOWFLAKE_USER            Snowflake user (can be used instead of -u)"
    echo "  SNOWFLAKE_PASSWORD        Snowflake password (can be used instead of -p)"
    echo "  SNOWFLAKE_ROLE            Snowflake role (can be used instead of -r)"
    echo ""
    echo "Example:"
    echo "  $0 -a myaccount -u myuser -p mypassword"
    echo "  SNOWFLAKE_ACCOUNT=myaccount SNOWFLAKE_USER=myuser SNOWFLAKE_PASSWORD=mypassword $0"
}

# Parse command line arguments
parse_args() {
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
            --skip-build)
                SKIP_BUILD=true
                shift
                ;;
            --skip-sql)
                SKIP_SQL=true
                shift
                ;;
            --skip-containers)
                SKIP_CONTAINERS=true
                shift
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

# Check prerequisites
check_prerequisites() {
    print_section "Checking Prerequisites"
    
    # Check if required tools are installed
    local tools=("docker" "java" "mvn" "python3" "pip")
    local missing_tools=()
    
    for tool in "${tools[@]}"; do
        if ! command -v $tool &> /dev/null; then
            missing_tools+=($tool)
        else
            print_message $GREEN "✓ $tool is installed"
        fi
    done
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_message $RED "✗ Missing required tools: ${missing_tools[*]}"
        print_message $YELLOW "Please install the missing tools and try again."
        exit 1
    fi
    
    # Check Snowflake credentials
    SNOWFLAKE_ACCOUNT=${SNOWFLAKE_ACCOUNT:-$SNOWFLAKE_ACCOUNT}
    SNOWFLAKE_USER=${SNOWFLAKE_USER:-$SNOWFLAKE_USER}
    SNOWFLAKE_PASSWORD=${SNOWFLAKE_PASSWORD:-$SNOWFLAKE_PASSWORD}
    SNOWFLAKE_ROLE=${SNOWFLAKE_ROLE:-"PUBLIC"}
    
    if [[ -z "$SNOWFLAKE_ACCOUNT" || -z "$SNOWFLAKE_USER" || -z "$SNOWFLAKE_PASSWORD" ]]; then
        print_message $RED "✗ Snowflake credentials not provided"
        print_message $YELLOW "Please provide Snowflake credentials via command line or environment variables."
        show_help
        exit 1
    fi
    
    print_message $GREEN "✓ Snowflake credentials provided"
    print_message $GREEN "Prerequisites check completed successfully"
}

# Setup Snowflake database and schemas
setup_snowflake() {
    if [ "$SKIP_SQL" = "true" ]; then
        print_message $YELLOW "Skipping Snowflake SQL setup"
        return
    fi
    
    print_section "Setting Up Snowflake Database and Schemas"
    
    local sql_files=(
        "01_database_setup.sql"
        "02_raw_tables.sql"
        "03_star_schema.sql"
        "04_aggregation_layer.sql"
        "05_streams_and_transforms.sql"
        "06_aggregation_tasks.sql"
    )
    
    for sql_file in "${sql_files[@]}"; do
        local file_path="$PROJECT_ROOT/sql/$sql_file"
        if [ -f "$file_path" ]; then
            print_message $YELLOW "Executing $sql_file..."
            
            # Use SnowSQL or Python connector to execute SQL
            if command -v snowsql &> /dev/null; then
                snowsql -a "$SNOWFLAKE_ACCOUNT" -u "$SNOWFLAKE_USER" -r "$SNOWFLAKE_ROLE" -f "$file_path" <<< "$SNOWFLAKE_PASSWORD"
            else
                # Fallback to Python execution
                python3 "$SCRIPT_DIR/execute_sql.py" \
                    --account "$SNOWFLAKE_ACCOUNT" \
                    --user "$SNOWFLAKE_USER" \
                    --password "$SNOWFLAKE_PASSWORD" \
                    --role "$SNOWFLAKE_ROLE" \
                    --file "$file_path"
            fi
            
            print_message $GREEN "✓ $sql_file executed successfully"
        else
            print_message $RED "✗ SQL file not found: $file_path"
            exit 1
        fi
    done
    
    print_message $GREEN "Snowflake setup completed successfully"
}

# Build Docker containers
build_containers() {
    if [ "$SKIP_BUILD" = "true" ]; then
        print_message $YELLOW "Skipping container build"
        return
    fi
    
    print_section "Building Docker Containers"
    
    # Build data generator container
    print_message $YELLOW "Building manufacturing data generator..."
    cd "$PROJECT_ROOT/data-generator"
    docker build -t manufacturing-data-generator:latest .
    print_message $GREEN "✓ Data generator container built"
    
    # Build Java streaming application
    print_message $YELLOW "Building Java streaming application..."
    cd "$PROJECT_ROOT/java-streaming"
    mvn clean package -DskipTests
    docker build -t manufacturing-streaming:latest .
    print_message $GREEN "✓ Java streaming container built"
    
    cd "$PROJECT_ROOT"
    print_message $GREEN "Container build completed successfully"
}

# Deploy containers to Snowpark Container Services
deploy_containers() {
    if [ "$SKIP_CONTAINERS" = "true" ]; then
        print_message $YELLOW "Skipping container deployment"
        return
    fi
    
    print_section "Deploying Containers to Snowpark Container Services"
    
    # Create image repository
    print_message $YELLOW "Creating image repository..."
    python3 "$SCRIPT_DIR/deploy_containers.py" \
        --account "$SNOWFLAKE_ACCOUNT" \
        --user "$SNOWFLAKE_USER" \
        --password "$SNOWFLAKE_PASSWORD" \
        --role "$SNOWFLAKE_ROLE" \
        --action create-repo
    
    # Push images
    print_message $YELLOW "Pushing container images..."
    python3 "$SCRIPT_DIR/deploy_containers.py" \
        --account "$SNOWFLAKE_ACCOUNT" \
        --user "$SNOWFLAKE_USER" \
        --password "$SNOWFLAKE_PASSWORD" \
        --role "$SNOWFLAKE_ROLE" \
        --action push-images
    
    # Deploy services
    print_message $YELLOW "Deploying container services..."
    python3 "$SCRIPT_DIR/deploy_containers.py" \
        --account "$SNOWFLAKE_ACCOUNT" \
        --user "$SNOWFLAKE_USER" \
        --password "$SNOWFLAKE_PASSWORD" \
        --role "$SNOWFLAKE_ROLE" \
        --action deploy-services
    
    print_message $GREEN "Container deployment completed successfully"
}

# Initialize reference data
initialize_data() {
    print_section "Initializing Reference Data"
    
    print_message $YELLOW "Generating initial dimension data..."
    
    # Run data generator in initialization mode
    docker run --rm \
        -e SNOWFLAKE_ACCOUNT="$SNOWFLAKE_ACCOUNT" \
        -e SNOWFLAKE_USER="$SNOWFLAKE_USER" \
        -e SNOWFLAKE_PASSWORD="$SNOWFLAKE_PASSWORD" \
        -e GENERATE_INITIAL_DATA="true" \
        manufacturing-data-generator:latest
    
    print_message $GREEN "Reference data initialization completed"
}

# Verify deployment
verify_deployment() {
    print_section "Verifying Deployment"
    
    print_message $YELLOW "Running deployment verification..."
    
    python3 "$SCRIPT_DIR/verify_deployment.py" \
        --account "$SNOWFLAKE_ACCOUNT" \
        --user "$SNOWFLAKE_USER" \
        --password "$SNOWFLAKE_PASSWORD" \
        --role "$SNOWFLAKE_ROLE"
    
    print_message $GREEN "Deployment verification completed"
}

# Start streaming services
start_services() {
    print_section "Starting Streaming Services"
    
    print_message $YELLOW "Starting manufacturing data generator..."
    # Start the services via Snowpark Container Services
    python3 "$SCRIPT_DIR/manage_services.py" \
        --account "$SNOWFLAKE_ACCOUNT" \
        --user "$SNOWFLAKE_USER" \
        --password "$SNOWFLAKE_PASSWORD" \
        --role "$SNOWFLAKE_ROLE" \
        --action start
    
    print_message $GREEN "Streaming services started successfully"
}

# Display completion message
show_completion() {
    print_section "Setup Completed Successfully!"
    
    print_message $GREEN "🎉 Manufacturing Real-Time Streaming Demo is ready!"
    echo ""
    print_message $BLUE "What's running:"
    print_message $YELLOW "  • Manufacturing data generator (generating synthetic sensor, production, and quality data)"
    print_message $YELLOW "  • Java streaming application (continuous data ingestion via Snowpipe)"
    print_message $YELLOW "  • Real-time transformation tasks (raw data → star schema)"
    print_message $YELLOW "  • Aggregation tasks (KPI calculation and dashboard metrics)"
    echo ""
    print_message $BLUE "Access your data:"
    print_message $YELLOW "  • Database: MANUFACTURING_DEMO"
    print_message $YELLOW "  • Raw data schema: RAW_DATA"
    print_message $YELLOW "  • Analytics schema: ANALYTICS (star schema)"
    print_message $YELLOW "  • Aggregation schema: AGGREGATION (KPIs and dashboards)"
    echo ""
    print_message $BLUE "Next steps:"
    print_message $YELLOW "  • Run queries against the AGGREGATION schema for real-time KPIs"
    print_message $YELLOW "  • Monitor the AGG_REALTIME_DASHBOARD table for live metrics"
    print_message $YELLOW "  • Check the streaming logs with: $SCRIPT_DIR/view_logs.sh"
    print_message $YELLOW "  • Stop the demo with: $SCRIPT_DIR/stop_demo.sh"
    echo ""
    print_message $GREEN "Happy streaming! 🚀"
}

# Main execution
main() {
    # Parse arguments
    parse_args "$@"
    
    # Display banner
    print_message $BLUE "======================================"
    print_message $BLUE "Manufacturing Streaming Demo Setup"
    print_message $BLUE "======================================"
    
    # Execute setup steps
    check_prerequisites
    setup_snowflake
    build_containers
    deploy_containers
    initialize_data
    verify_deployment
    start_services
    show_completion
}

# Run main function
main "$@" 