# Snowflake Connection Troubleshooting

This guide helps resolve common Snowflake connection issues encountered during setup.

## 🔍 Identifying Your Account Identifier

### Method 1: From Snowflake Web Console
1. **Login** to your Snowflake account via web browser
2. **Check the URL** in your browser's address bar:
   ```
   https://APP.snowflakecomputing.com
   ```
3. **Use the APP part** as your account identifier:
   ```bash
   # If URL is: https://ab12345.snowflakecomputing.com
   # Account identifier is: ab12345
   
   # If URL is: https://ab12345.us-east-1.snowflakecomputing.com  
   # Account identifier is: ab12345.us-east-1
   ```

### Method 2: From Snowflake Console
1. Login to Snowflake web console
2. Go to **Admin** > **Accounts** (if available)
3. Copy the **Account Identifier** from the account details

### Method 3: Ask Your Admin
If you don't have admin access:
1. Contact your Snowflake administrator
2. Ask for the **Account Identifier** (not the full URL)

## ❌ Common Errors and Solutions

### Error: 404 Not Found
```
404 Not Found: post https://sfsedemo231.snowflakecomputing.com:443/session/v1/login-request
```

**Cause**: Account identifier is incorrect

**Solution**: 
1. **Double-check account identifier format**:
   ```bash
   # Wrong formats (don't use):
   ❌ https://account.snowflakecomputing.com
   ❌ account.snowflakecomputing.com  
   ❌ account.snowflakecomputing.com:443
   
   # Correct formats:
   ✅ account
   ✅ account.region  
   ✅ account.region.cloud
   ✅ orgname-accountname
   ```

2. **Verify account exists**:
   ```bash
   # Test if account URL responds (replace 'account' with yours)
   curl -I https://account.snowflakecomputing.com
   
   # Should return: HTTP/2 200 OK
   ```

### Error: Authentication Failed
```
Authentication failed or user does not exist
```

**Solutions**:
1. **Check username** - use exact case (usually uppercase)
2. **Verify password** - ensure no extra spaces
3. **Test role access**:
   ```bash
   # Try with different role
   ./scripts/setup_mac.sh -a ACCOUNT -u USER -p PASS -r SYSADMIN
   ```

### Error: Access Denied
```
User does not have required privileges
```

**Solutions**:
1. **Contact admin** to grant privileges:
   ```sql
   -- Required privileges for demo setup:
   GRANT CREATE DATABASE ON ACCOUNT TO ROLE your_role;
   GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE your_role;
   GRANT CREATE INTEGRATION ON ACCOUNT TO ROLE your_role;
   ```

2. **Use appropriate role**:
   ```bash
   # Try with SYSADMIN role
   -r SYSADMIN
   
   # Or try with ACCOUNTADMIN role (if you have access)
   -r ACCOUNTADMIN
   ```

## 🔧 Account Identifier Examples

### Legacy Accounts (Most Common)
```bash
# Format: Short identifier
ab12345
xy67890
demo123
```

### Regional Accounts
```bash
# Format: account.region
ab12345.us-east-1
xy67890.eu-west-1
demo123.ap-southeast-2
```

### Cloud-Specific Accounts
```bash
# Format: account.region.cloud
ab12345.us-east-1.aws
xy67890.eu-west-1.azure
demo123.us-central1.gcp
```

### Organization Accounts (Newer)
```bash
# Format: orgname-accountname
mycompany-production
acme-development
startup-analytics
```

## 🧪 Testing Your Connection

### Quick Connection Test
```bash
# Replace with your actual credentials
python3 -c "
import snowflake.connector
try:
    conn = snowflake.connector.connect(
        account='YOUR_ACCOUNT',
        user='YOUR_USER', 
        password='YOUR_PASSWORD',
        role='PUBLIC'
    )
    print('✅ Connection successful!')
    conn.close()
except Exception as e:
    print(f'❌ Connection failed: {e}')
"
```

### Test Different Account Formats
If unsure about format, try variations:
```bash
# Test 1: Basic format
./scripts/setup_mac.sh -a ab12345 -u user -p pass

# Test 2: With region  
./scripts/setup_mac.sh -a ab12345.us-east-1 -u user -p pass

# Test 3: Organization format
./scripts/setup_mac.sh -a myorg-myaccount -u user -p pass
```

## 📞 Getting Help

### From Snowflake Support
1. **Account locator**: If you can't find your account identifier
2. **Connectivity issues**: Network or firewall problems
3. **Authentication problems**: User account issues

### From Your Organization
1. **IT/Admin team**: Account details and network configuration
2. **Data team**: Snowflake account access and permissions
3. **Security team**: Firewall and proxy settings

## 🔗 Useful Resources

- [Snowflake Account Identifiers Documentation](https://docs.snowflake.com/en/user-guide/admin-account-identifier.html)
- [Connection Parameters Reference](https://docs.snowflake.com/en/user-guide/python-connector-api.html#connect)
- [Network Connectivity Guide](https://docs.snowflake.com/en/user-guide/network-policies.html) 