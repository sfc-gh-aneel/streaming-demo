#!/bin/bash

# =====================================================
# Manufacturing Streaming Demo - Mac Easy Setup
# =====================================================
# Automatically installs prerequisites and sets up the demo on macOS
# Supports both Intel and Apple Silicon Macs

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Configuration
SNOWFLAKE_ACCOUNT=""
SNOWFLAKE_USER=""
SNOWFLAKE_PASSWORD=""
SNOWFLAKE_ROLE=""
SKIP_PREREQ_INSTALL=${SKIP_PREREQ_INSTALL:-false}

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

# Detect Mac architecture
detect_architecture() {
    local arch=$(uname -m)
    if [[ "$arch" == "arm64" ]]; then
        print_message $PURPLE "🍎 Detected: Apple Silicon Mac (M1/M2/M3)"
        echo "apple_silicon"
    else
        print_message $PURPLE "💻 Detected: Intel Mac"
        echo "intel"
    fi
}

# Install Homebrew if not present
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        print_message $YELLOW "📦 Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ $(detect_architecture) == "apple_silicon" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        
        print_message $GREEN "✅ Homebrew installed successfully"
    else
        print_message $GREEN "✅ Homebrew already installed"
    fi
}

# Install prerequisites via Homebrew
install_prerequisites() {
    if [[ "$SKIP_PREREQ_INSTALL" == "true" ]]; then
        print_message $YELLOW "⏭️  Skipping prerequisite installation"
        return
    fi
    
    print_section "Installing Prerequisites via Homebrew"
    
    # Update Homebrew
    print_message $YELLOW "🔄 Updating Homebrew..."
    brew update
    
    # Install required tools
    local tools=("docker" "openjdk@11" "maven" "python@3.11")
    
    for tool in "${tools[@]}"; do
        if brew list "$tool" &> /dev/null; then
            print_message $GREEN "✅ $tool already installed"
        else
            print_message $YELLOW "📦 Installing $tool..."
            brew install "$tool"
            print_message $GREEN "✅ $tool installed successfully"
        fi
    done
    
    # Special handling for Java on Mac
    print_message $YELLOW "🔧 Configuring Java environment..."
    if [[ $(detect_architecture) == "apple_silicon" ]]; then
        export JAVA_HOME="/opt/homebrew/opt/openjdk@11/libexec/openjdk.jdk/Contents/Home"
    else
        export JAVA_HOME="/usr/local/opt/openjdk@11/libexec/openjdk.jdk/Contents/Home"
    fi
    
    # Add Java to PATH if not already there
    if ! echo $PATH | grep -q "$JAVA_HOME/bin"; then
        export PATH="$JAVA_HOME/bin:$PATH"
        echo "export JAVA_HOME=\"$JAVA_HOME\"" >> ~/.zshrc
        echo "export PATH=\"\$JAVA_HOME/bin:\$PATH\"" >> ~/.zshrc
    fi
    
    # Install Python packages (PEP 668 compliant)
    print_message $YELLOW "🐍 Installing Python packages..."
    
    # First, try to upgrade pip with --user flag
    print_message $YELLOW "📦 Attempting user-level package installation..."
    if python3 -m pip install --user --upgrade pip &>/dev/null && \
       python3 -m pip install --user snowflake-connector-python pandas &>/dev/null; then
        print_message $GREEN "✅ Python packages installed to user directory"
    else
        print_message $YELLOW "📦 User installation failed, creating virtual environment..."
        
        # Create a virtual environment for the project
        if [[ ! -d "$PROJECT_ROOT/venv" ]]; then
            python3 -m venv "$PROJECT_ROOT/venv"
            print_message $GREEN "✅ Virtual environment created"
        else
            print_message $YELLOW "📁 Using existing virtual environment"
        fi
        
        # Activate virtual environment and install packages
        source "$PROJECT_ROOT/venv/bin/activate"
        python3 -m pip install --upgrade pip
        python3 -m pip install snowflake-connector-python pandas
        
        # Add activation hint to zshrc for convenience
        if ! grep -q "source.*streaming-demo.*venv" ~/.zshrc 2>/dev/null; then
            echo "" >> ~/.zshrc
            echo "# Manufacturing Demo Virtual Environment" >> ~/.zshrc
            echo "# Uncomment the next line to auto-activate the virtual environment" >> ~/.zshrc
            echo "# source \"$PROJECT_ROOT/venv/bin/activate\"" >> ~/.zshrc
        fi
        
        print_message $GREEN "✅ Virtual environment configured at $PROJECT_ROOT/venv"
        print_message $YELLOW "💡 To activate manually: source venv/bin/activate"
    fi
    
    # Start Docker Desktop if not running
    if ! docker info &> /dev/null; then
        print_message $YELLOW "🐳 Starting Docker Desktop..."
        open -a Docker
        print_message $YELLOW "⏳ Waiting for Docker to start (30 seconds)..."
        sleep 30
        
        # Check if Docker is now running
        local retries=0
        while ! docker info &> /dev/null && [ $retries -lt 6 ]; do
            print_message $YELLOW "⏳ Still waiting for Docker... (${retries}/6)"
            sleep 10
            ((retries++))
        done
        
        if ! docker info &> /dev/null; then
            print_message $RED "❌ Docker failed to start. Please start Docker Desktop manually and try again."
            exit 1
        fi
    fi
    
    print_message $GREEN "✅ All prerequisites installed and configured!"
}

# Verify installation
verify_installation() {
    print_section "Verifying Installation"
    
    local tools=("docker" "java" "mvn" "python3")
    local all_good=true
    
    for tool in "${tools[@]}"; do
        if command -v $tool &> /dev/null; then
            local version=""
            case $tool in
                "docker") version=$(docker --version 2>/dev/null | head -1) ;;
                "java") 
                    # Ensure JAVA_HOME is set for verification
                    if [[ $(detect_architecture) == "apple_silicon" ]]; then
                        export JAVA_HOME="/opt/homebrew/opt/openjdk@11/libexec/openjdk.jdk/Contents/Home"
                    else
                        export JAVA_HOME="/usr/local/opt/openjdk@11/libexec/openjdk.jdk/Contents/Home"
                    fi
                    export PATH="$JAVA_HOME/bin:$PATH"
                    version=$(java -version 2>&1 | head -1) 
                    ;;
                "mvn") version=$(mvn --version 2>/dev/null | head -1) ;;
                "python3") version=$(python3 --version 2>/dev/null) ;;
            esac
            print_message $GREEN "✅ $tool: $version"
        else
            print_message $RED "❌ $tool not found"
            all_good=false
        fi
    done
    
    # Check Docker is running
    if docker info &> /dev/null; then
        print_message $GREEN "✅ Docker is running"
    else
        print_message $RED "❌ Docker is not running"
        all_good=false
    fi
    
    # Check Python packages
    print_message $YELLOW "🔍 Checking Python packages..."
    
    # Test packages in both potential environments
    local packages_found=false
    
    # First check if virtual environment exists and packages are there
    if [[ -d "$PROJECT_ROOT/venv" ]]; then
        if source "$PROJECT_ROOT/venv/bin/activate" && python3 -c "import snowflake.connector; import pandas" 2>/dev/null; then
            print_message $GREEN "✅ Python packages: snowflake-connector-python, pandas (virtual env)"
            packages_found=true
        fi
    fi
    
    # If not found in venv, check user installation
    if [[ "$packages_found" != "true" ]] && python3 -c "import snowflake.connector; import pandas" 2>/dev/null; then
        print_message $GREEN "✅ Python packages: snowflake-connector-python, pandas (user)"
        packages_found=true
    fi
    
    if [[ "$packages_found" != "true" ]]; then
        print_message $RED "❌ Required Python packages not found"
        all_good=false
    fi
    
    if [[ "$all_good" != "true" ]]; then
        print_message $RED "❌ Some tools are missing. Please check the installation."
        exit 1
    fi
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
            --skip-prereq-install)
                SKIP_PREREQ_INSTALL=true
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

# Help function
show_help() {
    cat << EOF
Manufacturing Real-Time Streaming Demo - Mac Easy Setup

This script automatically installs all prerequisites using Homebrew and sets up the demo.

Usage: $0 [OPTIONS]

Options:
  -a, --account ACCOUNT         Snowflake account identifier
  -u, --user USER              Snowflake username  
  -p, --password PASSWORD      Snowflake password
  -r, --role ROLE              Snowflake role (default: PUBLIC)
  --skip-prereq-install        Skip automatic installation of prerequisites
  -h, --help                   Show this help message

Examples:
  # Full automatic setup
  $0 -a myaccount -u myuser -p mypassword
  
  # Skip prerequisite installation (if already installed)
  $0 --skip-prereq-install -a myaccount -u myuser -p mypassword

Prerequisites installed automatically:
  ✅ Homebrew (if not present)
  ✅ Docker Desktop
  ✅ Java 11 (OpenJDK)
  ✅ Maven 3.6+
  ✅ Python 3.11
  ✅ Required Python packages

Supported Systems:
  🍎 Apple Silicon Macs (M1/M2/M3)
  💻 Intel Macs
  🐚 zsh shell (default on macOS)

EOF
}

# Main execution
main() {
    print_message $PURPLE "🚀 Manufacturing Streaming Demo - Mac Easy Setup"
    print_message $PURPLE "Automatic installation and configuration for macOS"
    echo ""
    
    # Detect system
    local arch=$(detect_architecture)
    
    # Parse arguments
    parse_arguments "$@"
    
    # Install Homebrew if needed
    install_homebrew
    
    # Install prerequisites
    install_prerequisites
    
    # Verify installation
    verify_installation
    
    # Get Snowflake credentials if not provided
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
    if [[ -z "$SNOWFLAKE_ROLE" ]]; then
        SNOWFLAKE_ROLE="PUBLIC"
    fi
    
    # Run the main setup script
    print_section "Running Main Setup Script"
    
    # Ensure setup script is executable
    chmod +x "$SCRIPT_DIR/setup_demo.sh"
    
    # Activate virtual environment if it exists
    if [[ -d "$PROJECT_ROOT/venv" ]]; then
        print_message $YELLOW "🔌 Activating virtual environment..."
        source "$PROJECT_ROOT/venv/bin/activate"
    fi
    
    # Ensure Java environment is set for the main script
    if [[ $(detect_architecture) == "apple_silicon" ]]; then
        export JAVA_HOME="/opt/homebrew/opt/openjdk@11/libexec/openjdk.jdk/Contents/Home"
    else
        export JAVA_HOME="/usr/local/opt/openjdk@11/libexec/openjdk.jdk/Contents/Home"
    fi
    export PATH="$JAVA_HOME/bin:$PATH"
    
    "$SCRIPT_DIR/setup_demo.sh" \
        --account "$SNOWFLAKE_ACCOUNT" \
        --user "$SNOWFLAKE_USER" \
        --password "$SNOWFLAKE_PASSWORD" \
        --role "$SNOWFLAKE_ROLE"
    
    print_message $GREEN "🎉 Setup completed successfully!"
    print_message $YELLOW "💡 Next steps:"
    echo "   1. Open your Snowflake console"
    echo "   2. Navigate to database: MANUFACTURING_DEMO"
    echo "   3. Explore schemas: RAW_DATA, ANALYTICS, AGGREGATION"
    echo "   4. Check the containerized applications in Snowpark Container Services"
}

# Run main function with all arguments
main "$@" 