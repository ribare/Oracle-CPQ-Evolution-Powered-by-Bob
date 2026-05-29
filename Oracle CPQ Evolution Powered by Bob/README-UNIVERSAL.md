# CPQ ToolKit - Universal Management System

Reusable system for connecting and managing multiple Oracle CPQ environments.

## 📋 Table of Contents

- [Features](#features)
- [Project Structure](#project-structure)
- [Initial Configuration](#initial-configuration)
- [Basic Usage](#basic-usage)
- [Available Commands](#available-commands)
- [Environment Management](#environment-management)
- [Usage Examples](#usage-examples)

## ✨ Features

- ✅ **Multi-environment**: Connect to different environments (test, dev, prod) with a single command
- ✅ **Centralized configuration**: All credentials and configurations in a single JSON file
- ✅ **Reusable**: Switch environments without modifying scripts
- ✅ **Secure**: Special warnings for production operations
- ✅ **Easy to use**: Simple and clear commands

## 📁 Project Structure

```
C:\CPQ\workspace\
├── config/
│   └── environments.json          # Environment and credentials configuration
├── lib/
│   └── Load-Config.ps1            # Configuration loading module
├── connect.ps1                    # Universal connection script
├── pull.ps1                       # Download content from CPQ
├── push.ps1                       # Upload content to CPQ
├── packages.ps1                   # List available packages
├── commerceAndDocuments/          # Downloaded content
├── developerTools/                # Development tools
└── README-UNIVERSAL.md            # This documentation
```

## ⚙️ Initial Configuration

### 1. Edit Environment Configuration

Edit the `config/environments.json` file:

```json
{
  "environments": {
    "test": {
      "name": "Accel Alpha Test",
      "host": "accelalphatest.bigmachines.com",
      "protocol": "https",
      "description": "Testing environment"
    },
    "dev": {
      "name": "Development",
      "host": "your-dev-environment.bigmachines.com",
      "protocol": "https",
      "description": "Development environment"
    },
    "prod": {
      "name": "Production",
      "host": "your-prod-environment.bigmachines.com",
      "protocol": "https",
      "description": "Production environment"
    }
  },
  "credentials": {
    "test": {
      "username": "your-username",
      "password": "your-password"
    },
    "dev": {
      "username": "your-username",
      "password": "your-password"
    },
    "prod": {
      "username": "your-username",
      "password": "your-password"
    }
  }
}
```

### 2. Configure Download Paths (REQUIRED)

Each environment must have the `output_path` parameter configured, which indicates where files will be downloaded:

```json
"test": {
  "name": "Accel Alpha Test",
  "host": "accelalphatest.bigmachines.com",
  "protocol": "https",
  "description": "Testing environment",
  "download_mode": "all",
  "specific_processes": [],
  "output_path": "C:\\MyProjects\\CPQ-Test"
}
```

**⚠️ IMPORTANT:**
- The `output_path` field is **REQUIRED** to download content
- The `pull.ps1` and `pull-process.ps1` scripts will validate that it's configured
- If you try to download without configuring this field, you'll receive an error
- Use absolute paths (e.g., `C:\\MyProjects\\CPQ-Test`)

### 3. Verify System Paths

Make sure the paths in the JSON file's `settings` are correct:

```json
"settings": {
  "java_home": "C:\\Program Files\\Java\\jdk-25.0.3",
  "cpq_toolkit_path": "C:\\CPQ\\CPQToolkit-windows\\CPQToolkit-24.4.0-SNAPSHOT\\bin\\cpq-toolkit.bat",
  "workspace_path": "C:\\CPQ\\workspace"
}
```

## 🚀 Basic Usage

### View Available Environments

```powershell
.\connect.ps1 -Environment test -ShowEnvironments
```

### Connect to an Environment

```powershell
.\connect.ps1 -Environment test
```

### Download Content (Pull)

```powershell
.\pull.ps1 -Environment test
```

### Upload Content (Push)

```powershell
.\push.ps1 -Environment test
```

### List Packages

```powershell
.\packages.ps1 -Environment test
```

## 📝 Available Commands

### `connect.ps1`

Tests connection with a CPQ environment.

**Parameters:**
- `-Environment`: Environment name (test, dev, prod)
- `-ShowEnvironments`: Shows all available environments

**Examples:**
```powershell
# Connect to test
.\connect.ps1 -Environment test

# View available environments
.\connect.ps1 -Environment test -ShowEnvironments
```

### `pull.ps1`

Downloads all content from the CPQ site.

**Parameters:**
- `-Environment`: Environment name

**Requirements:**
- The `output_path` field must be configured in `config/environments.json`

**Example:**
```powershell
# Download all content
.\pull.ps1 -Environment test
```

**Note:** Files will be downloaded to the path specified in the environment's `output_path`.

### `push.ps1`

Uploads content to the CPQ site from the workspace.

**Parameters:**
- `-Environment`: Environment name

**Example:**
```powershell
# Upload all content from workspace
.\push.ps1 -Environment test
```

**⚠️ Note:** When pushing to production, additional confirmation will be requested.

### `packages.ps1`

Lists all available packages in the environment.

**Parameters:**
- `-Environment`: Environment name

**Example:**
```powershell
.\packages.ps1 -Environment test
```

## 🌍 Environment Management

### Add a New Environment

1. Edit `config/environments.json`
2. Add the new environment in the `environments` section:

```json
"qa": {
  "name": "Quality Assurance",
  "host": "qa.bigmachines.com",
  "protocol": "https",
  "description": "QA environment"
}
```

3. Add credentials in the `credentials` section:

```json
"qa": {
  "username": "qa-user",
  "password": "qa-password"
}
```

### Switch Environments

Simply use the `-Environment` parameter with the desired environment name:

```powershell
# Work in test
.\connect.ps1 -Environment test
.\pull.ps1 -Environment test

# Switch to dev
.\connect.ps1 -Environment dev
.\pull.ps1 -Environment dev

# Switch to prod
.\connect.ps1 -Environment prod
.\pull.ps1 -Environment prod
```

## 💡 Usage Examples

### Complete Flow: Test → Dev → Prod

```powershell
# 1. Download from test
.\pull.ps1 -Environment test

# 2. Make local changes
# ... edit files ...

# 3. Upload to dev for testing
.\push.ps1 -Environment dev

# 4. Verify in dev
.\connect.ps1 -Environment dev

# 5. If everything is good, upload to prod
.\push.ps1 -Environment prod
```

### Migrate Content Between Environments

```powershell
# Download from test
.\pull.ps1 -Environment test

# Upload directly to dev
.\push.ps1 -Environment dev
```

### List and Analyze Packages

```powershell
# View packages in test
.\packages.ps1 -Environment test

# View packages in prod
.\packages.ps1 -Environment prod
```

## 🔒 Security

### Credential Protection

- Passwords are stored in `config/environments.json`
- **DO NOT** upload this file to public repositories
- Consider using environment variables for sensitive credentials

### Production Confirmation

The `push.ps1` script requests additional confirmation when attempting to upload to production:

```
⚠ WARNING: You are about to upload changes to PRODUCTION
Are you sure you want to continue? (Y/N):
```

## 🛠️ Troubleshooting

### Error: "Environment not found"

Verify that the environment name exists in `config/environments.json`.

```powershell
.\connect.ps1 -Environment test -ShowEnvironments
```

### Error: "Java not found"

Verify the Java path in `config/environments.json`:

```json
"java_home": "C:\\Program Files\\Java\\jdk-25.0.3"
```

### Error: "CPQ ToolKit not found"

Verify the toolkit path in `config/environments.json`:

```json
"cpq_toolkit_path": "C:\\CPQ\\CPQToolkit-windows\\CPQToolkit-24.4.0-SNAPSHOT\\bin\\cpq-toolkit.bat"
```

## 📚 Additional Resources

- [Oracle CPQ Documentation](https://docs.oracle.com/en/cloud/saas/cpq-cloud/)
- [CPQ ToolKit Guide](https://docs.oracle.com/en/cloud/saas/cpq-cloud/toolkit/)

## 👨‍💻 Author

Created by Bob - Universal CPQ Management System

---

**Last updated:** 2026-05-22