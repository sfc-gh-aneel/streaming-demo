#!/usr/bin/env python3
"""
Interactive Data Generator Launcher
Prompts for Snowflake credentials and starts the high-volume data generator
"""

import subprocess
import sys
import getpass
import re

def validate_account_identifier(account):
    """Validate Snowflake account identifier format"""
    # Basic validation for account identifier
    if not account:
        return False, "Account identifier cannot be empty"
    
    # Should be in format like 'orgname-account' or 'account.region.cloud'
    if not re.match(r'^[a-zA-Z0-9._-]+$', account):
        return False, "Account identifier contains invalid characters"
    
    return True, "Valid"

def validate_email(email):
    """Basic email validation"""
    if not email:
        return False, "Email cannot be empty"
    
    if not re.match(r'^[^@]+@[^@]+\.[^@]+$', email):
        return False, "Invalid email format"
    
    return True, "Valid"

def check_docker():
    """Check if Docker is running"""
    try:
        result = subprocess.run(['docker', 'info'], 
                              capture_output=True, text=True, timeout=10)
        return result.returncode == 0
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return False

def check_image_exists():
    """Check if the data generator image exists"""
    try:
        result = subprocess.run(['docker', 'images', '-q', 'manufacturing-data-generator:latest'], 
                              capture_output=True, text=True)
        return bool(result.stdout.strip())
    except FileNotFoundError:
        return False

def stop_existing_container():
    """Stop and remove any existing data generator container"""
    try:
        # Check if container exists
        result = subprocess.run(['docker', 'ps', '-a', '--filter', 'name=data-gen', '--format', '{{.Names}}'], 
                              capture_output=True, text=True)
        
        if 'data-gen' in result.stdout:
            print("🔄 Stopping existing data generator container...")
            subprocess.run(['docker', 'stop', 'data-gen'], capture_output=True)
            subprocess.run(['docker', 'rm', 'data-gen'], capture_output=True)
            print("✅ Existing container removed")
        
    except FileNotFoundError:
        pass

def main():
    print("🏭 Manufacturing Data Generator Launcher")
    print("=" * 50)
    
    # Check prerequisites
    print("📋 Checking prerequisites...")
    
    if not check_docker():
        print("❌ Docker is not running or not installed")
        print("   Please start Docker Desktop and try again")
        sys.exit(1)
    
    if not check_image_exists():
        print("❌ Data generator image not found")
        print("   Please build the image first:")
        print("   cd data-generator && docker build -t manufacturing-data-generator:latest .")
        sys.exit(1)
    
    print("✅ Prerequisites check passed")
    print()
    
    # Get Snowflake credentials
    print("🔐 Enter your Snowflake credentials:")
    
    while True:
        account = input("Account Identifier (e.g., orgb-qrb47683): ").strip()
        is_valid, message = validate_account_identifier(account)
        if is_valid:
            break
        print(f"❌ {message}")
    
    while True:
        username = input("Username (email): ").strip()
        is_valid, message = validate_email(username)
        if is_valid:
            break
        print(f"❌ {message}")
    
    while True:
        password = getpass.getpass("Password (hidden): ")
        if password.strip():
            break
        print("❌ Password cannot be empty")
    
    # Optional settings
    print("\n⚙️  Optional settings (press Enter for defaults):")
    
    database = input("Database [MANUFACTURING_DEMO]: ").strip() or "MANUFACTURING_DEMO"
    warehouse = input("Warehouse [STREAMING_WH]: ").strip() or "STREAMING_WH"
    role = input("Role [PUBLIC]: ").strip() or "PUBLIC"
    
    print(f"\n📊 Configuration:")
    print(f"  Account: {account}")
    print(f"  User: {username}")
    print(f"  Database: {database}")
    print(f"  Warehouse: {warehouse}")
    print(f"  Role: {role}")
    print(f"  Data Rate: ~8,160 records/minute (40x normal)")
    
    # Confirm before starting
    confirm = input(f"\n🚀 Start high-volume data generation? [y/N]: ").strip().lower()
    if confirm not in ['y', 'yes']:
        print("❌ Cancelled")
        sys.exit(0)
    
    # Stop any existing container
    stop_existing_container()
    
    # Build and run the container
    print("\n🚀 Starting data generator...")
    
    docker_cmd = [
        'docker', 'run', '--name', 'data-gen', '-d',
        '-e', f'SNOWFLAKE_ACCOUNT={account}',
        '-e', f'SNOWFLAKE_USER={username}',
        '-e', f'SNOWFLAKE_PASSWORD={password}',
        '-e', f'SNOWFLAKE_DATABASE={database}',
        '-e', f'SNOWFLAKE_WAREHOUSE={warehouse}',
        '-e', f'SNOWFLAKE_ROLE={role}',
        'manufacturing-data-generator:latest'
    ]
    
    try:
        result = subprocess.run(docker_cmd, capture_output=True, text=True, timeout=30)
        
        if result.returncode == 0:
            container_id = result.stdout.strip()
            print(f"✅ Data generator started successfully!")
            print(f"   Container ID: {container_id[:12]}...")
            print()
            print("📊 Expected data generation rates:")
            print("   • Sensor data: 6,000 records/minute")
            print("   • Production data: 1,500 records/minute") 
            print("   • Quality data: 660 records/minute")
            print("   • Total: ~8,160 records/minute")
            print()
            print("🔍 Monitor the generator:")
            print("   View logs: docker logs -f data-gen")
            print("   Check status: docker ps --filter 'name=data-gen'")
            print("   Stop generator: docker stop data-gen")
            print()
            print("📈 Your Streamlit dashboard should now have abundant real-time data!")
            
        else:
            print("❌ Failed to start container:")
            print(result.stderr)
            sys.exit(1)
            
    except subprocess.TimeoutExpired:
        print("❌ Container startup timed out")
        sys.exit(1)
    except KeyboardInterrupt:
        print("\n❌ Cancelled by user")
        sys.exit(1)

if __name__ == "__main__":
    main() 