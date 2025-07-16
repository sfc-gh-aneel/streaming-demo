# Mac Setup Guide

This guide provides multiple easy ways to set up the Manufacturing Streaming Demo on macOS.

## 🚀 Quick Start Options

### Option 1: One-Command Setup (Recommended)
```bash
./scripts/setup_mac.sh -a YOUR_ACCOUNT -u YOUR_USER -p YOUR_PASSWORD
```

### Option 2: Interactive Setup
```bash
./scripts/setup_mac.sh
# Script will prompt for credentials
```

### Option 3: Skip Prerequisites (if already installed)
```bash
./scripts/setup_mac.sh --skip-prereq-install -a ACCOUNT -u USER -p PASS
```

## 🛠️ What Gets Installed Automatically

The Mac setup script uses **Homebrew** to install everything you need:

| Tool | Version | Purpose |
|------|---------|---------|
| **Homebrew** | Latest | Package manager for macOS |
| **Docker Desktop** | Latest | Container runtime |
| **OpenJDK 11** | 11.x | Java runtime for streaming app |
| **Maven** | 3.6+ | Java build tool |
| **Python 3.11** | 3.11.x | Data generator runtime |
| **snowflake-connector-python** | Latest | Snowflake Python SDK |
| **pandas** | Latest | Data manipulation library |

## 🍎 Apple Silicon vs Intel Compatibility

The setup script automatically detects your Mac architecture:

### Apple Silicon Macs (M1/M2/M3)
- ✅ Full native support
- ✅ Optimized Java and Python installations
- ✅ Homebrew installed to `/opt/homebrew/`
- ✅ Docker Desktop with Apple Silicon optimizations

### Intel Macs
- ✅ Full compatibility
- ✅ Standard Homebrew path `/usr/local/`
- ✅ Traditional x86_64 binaries

## 🐚 Shell Configuration

The script automatically configures your `~/.zshrc` with:

```bash
# Java Environment (Apple Silicon example)
export JAVA_HOME="/opt/homebrew/opt/openjdk@11/libexec/openjdk.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"

# Homebrew (Apple Silicon)
eval "$(/opt/homebrew/bin/brew shellenv)"
```

## 🔧 Troubleshooting

### Docker Issues

**Problem**: Docker fails to start
```bash
❌ Docker is not running
```

**Solutions**:
1. Install Docker Desktop from [docker.com](https://www.docker.com/products/docker-desktop)
2. Start Docker Desktop manually from Applications
3. Wait for Docker to fully initialize (whale icon in menu bar)
4. Re-run the setup script

**Problem**: Docker permission denied
```bash
permission denied while trying to connect to the Docker daemon socket
```

**Solution**:
```bash
# Add yourself to docker group (requires restart)
sudo dscl . -append /Groups/docker GroupMembership $(whoami)
# OR restart Docker Desktop
```

### Java Issues

**Problem**: Java not found after installation
```bash
❌ java not found
```

**Solutions**:
1. Restart your terminal
2. Source your shell configuration:
   ```bash
   source ~/.zshrc
   ```
3. Manually set JAVA_HOME:
   ```bash
   # For Apple Silicon
   export JAVA_HOME="/opt/homebrew/opt/openjdk@11/libexec/openjdk.jdk/Contents/Home"
   
   # For Intel
   export JAVA_HOME="/usr/local/opt/openjdk@11/libexec/openjdk.jdk/Contents/Home"
   ```

### Python Issues

**Problem**: Python packages fail to install (PEP 668 error)
```bash
error: externally-managed-environment
× This environment is externally managed
```

**Solution**: The setup script now handles this automatically by:
1. **First trying** `--user` flag installation
2. **Fallback** to creating a virtual environment at `./venv/`
3. **Auto-activation** of the virtual environment for the demo

**Manual activation** (if needed):
```bash
source venv/bin/activate  # From project root
```

**Problem**: Legacy Python package installation errors
```bash
ERROR: Could not install packages due to an EnvironmentError
```

**Manual Solutions**:
1. Use virtual environment:
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install snowflake-connector-python pandas
   ```

2. Install with user flag:
   ```bash
   python3 -m pip install --user snowflake-connector-python pandas
   ```

### Homebrew Issues

**Problem**: Homebrew command not found
```bash
brew: command not found
```

**Solution**:
```bash
# Install Homebrew manually
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# For Apple Silicon, add to PATH
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
source ~/.zshrc
```

**Problem**: Permission denied on /opt/homebrew
```bash
Permission denied @ dir_s_mkdir - /opt/homebrew
```

**Solution**:
```bash
# Fix ownership (Apple Silicon)
sudo chown -R $(whoami) /opt/homebrew

# For Intel Macs
sudo chown -R $(whoami) /usr/local/Homebrew
```

### Snowflake Connection Issues

**Problem**: 404 Not Found error during connection
```bash
404 Not Found: post https://account.snowflakecomputing.com:443/session/v1/login-request
```

**Root Cause**: Account identifier is incorrect or malformed

**Solutions**:
1. **Find your correct account identifier**:
   - Login to Snowflake web console
   - Look at the URL: `https://APP.snowflakecomputing.com`
   - Use the `APP` part as your account identifier
   
2. **Common account identifier formats**:
   ```bash
   # Legacy format (most common)
   ab12345
   
   # With region
   ab12345.us-east-1
   
   # With cloud provider
   ab12345.us-east-1.aws
   
   # Organization format (newer accounts)
   myorg-myaccount
   ```

3. **Verify account format**:
   ```bash
   # DO NOT include these in account identifier:
   ❌ https://ab12345.snowflakecomputing.com
   ❌ ab12345.snowflakecomputing.com
   
   # Correct format:
   ✅ ab12345
   ✅ ab12345.us-east-1
   ✅ myorg-myaccount
   ```

**Problem**: Authentication failures

**Solutions**:
1. Verify account identifier format (see above)
2. Check network connectivity:
   ```bash
   # Test connection (replace with your account)
   curl -I https://ab12345.snowflakecomputing.com
   ```
3. Verify user permissions:
   - User needs CREATE DATABASE privileges
   - Role should have SYSADMIN or similar permissions

## 🚨 Common Error Messages

### "xcode-select: error: invalid developer path"
```bash
# Install Xcode Command Line Tools
xcode-select --install
```

### "Cannot connect to the Docker daemon"
```bash
# Start Docker Desktop
open -a Docker

# Wait for startup, then retry
```

### "JAVA_HOME is not set"
```bash
# Check Java installation
which java
/usr/libexec/java_home -V

# Set JAVA_HOME
export JAVA_HOME=$(/usr/libexec/java_home -v 11)
```

## 🧹 Clean Installation

If you need to start fresh:

```bash
# Remove installed packages
brew uninstall docker openjdk@11 maven python@3.11

# Remove Docker Desktop
# Use Docker Desktop's uninstaller or:
rm -rf ~/Library/Group\ Containers/group.com.docker
rm -rf ~/Library/Containers/com.docker.docker
rm -rf ~/.docker

# Clear Homebrew cache
brew cleanup --prune=all

# Remove configuration from shell
# Edit ~/.zshrc and remove Java/Homebrew exports
```

## 📋 Manual Installation

If the automatic setup doesn't work, install manually:

```bash
# 1. Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Install prerequisites
brew install docker openjdk@11 maven python@3.11

# 3. Configure Java
echo 'export JAVA_HOME="/opt/homebrew/opt/openjdk@11/libexec/openjdk.jdk/Contents/Home"' >> ~/.zshrc
echo 'export PATH="$JAVA_HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# 4. Install Python packages
python3 -m pip install snowflake-connector-python pandas

# 5. Start Docker Desktop
open -a Docker

# 6. Run main setup
./scripts/setup_demo.sh -a ACCOUNT -u USER -p PASSWORD
```

## 🎯 Next Steps

After successful setup:

1. **Verify Installation**: All tools should show ✅ in the verification step
2. **Check Snowflake**: Database `MANUFACTURING_DEMO` should be created
3. **Monitor Containers**: Check Snowpark Container Services in Snowflake UI
4. **Explore Data**: Query the streaming tables in real-time

## 💡 Pro Tips

- **Use Terminal.app or iTerm2** for best compatibility
- **Enable Docker Desktop startup** in preferences for convenience
- **Bookmark Snowflake console** for easy access to your data
- **Check Activity Monitor** if containers seem slow to start 