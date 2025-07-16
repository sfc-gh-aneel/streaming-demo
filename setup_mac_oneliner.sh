#!/bin/bash

# One-liner Mac setup for Manufacturing Streaming Demo
# Usage: curl -sSL https://raw.githubusercontent.com/your-repo/setup_mac_oneliner.sh | bash -s -- -a ACCOUNT -u USER -p PASS

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script is designed for macOS only"
    exit 1
fi

# Print welcome message
echo "🚀 Manufacturing Streaming Demo - One-liner Mac Setup"
echo ""

# Check if git is available and repo is cloned
if [[ ! -d ".git" ]]; then
    echo "📥 Cloning repository..."
    if command -v git &> /dev/null; then
        # Replace with your actual repo URL when publishing
        git clone https://github.com/your-org/streaming-demo.git
        cd streaming-demo
    else
        echo "❌ Git not found. Please install Xcode Command Line Tools:"
        echo "   xcode-select --install"
        exit 1
    fi
fi

# Run the Mac setup script
if [[ -f "scripts/setup_mac.sh" ]]; then
    echo "🔧 Running Mac setup script..."
    ./scripts/setup_mac.sh "$@"
else
    echo "❌ Setup script not found. Please ensure you're in the correct directory."
    exit 1
fi 