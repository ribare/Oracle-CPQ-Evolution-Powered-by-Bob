# Quick Guide - Universal CPQ System

## Environment Configuration

### File: `config/environments.json`

```json
{
  "environments": {
    "test": {
      "name": "Accel Alpha Test",
      "host": "accelalphatest.bigmachines.com",
      "protocol": "https",
      "description": "Testing environment",
      "download_mode": "all",
      "specific_processes": []
    }
  }
}
```

### `download_mode` Options:

- **`"all"`**: Downloads ALL site content (all processes, documents, etc.)
- **`"specific"`**: Downloads only the processes specified in `specific_processes`

### Example configuration for downloading specific processes:

```json
{
  "environments": {
    "prod": {
      "name": "Production",
      "host": "prod.bigmachines.com",
      "protocol": "https",
      "description": "Production environment",
      "download_mode": "specific",
      "specific_processes": [
        "oraclecpqo_bmClone_1",
        "metalsaProcess",
        "appleQuotingProcess"
      ]
    }
  }
}
```

## Main Commands

### 1. Connect and Validate Environment

```powershell
.\connect.ps1 -Environment test
```

### 2. View Available Environments

```powershell
.\connect.ps1 -Environment test -ShowEnvironments
```

### 3. Download ALL Content

```powershell
# Downloads ALL processes, documents, resources, etc.
.\pull.ps1 -Environment test
```

### 4. List Locally Available Processes

```powershell
# Shows the processes you've already downloaded
.\pull-process.ps1 -Environment test -ListProcesses
```

### 5. Download a Specific Process

```powershell
# Downloads only the specified process
.\pull-process.ps1 -Environment test -ProcessName oraclecpqo_bmClone_1
```

### 6. Upload Changes

```powershell
# Uploads ALL local content to the environment
.\push.ps1 -Environment test
```

### 7. List Available Packages

```powershell
.\packages.ps1 -Environment test
```

## Common Workflows

### Workflow 1: Download Everything and Work Locally

```powershell
# 1. Connect
.\connect.ps1 -Environment test

# 2. Download everything
.\pull.ps1 -Environment test

# 3. Edit files locally
# ... make changes ...

# 4. Upload changes
.\push.ps1 -Environment test
```

### Workflow 2: Work with a Specific Process

```powershell
# 1. Connect
.\connect.ps1 -Environment test

# 2. View available processes
.\pull-process.ps1 -Environment test -ListProcesses

# 3. Download specific process
.\pull-process.ps1 -Environment test -ProcessName oraclecpqo_bmClone_1

# 4. Edit the process locally
# ... make changes in commerceAndDocuments\processDefinition\oraclecpqo_bmClone_1 ...

# 5. Upload changes
.\push.ps1 -Environment test
```

### Workflow 3: Migrate Content Between Environments

```powershell
# 1. Download from test
.\pull.ps1 -Environment test

# 2. Upload to dev
.\push.ps1 -Environment dev

# 3. Verify in dev
.\connect.ps1 -Environment dev
```

### Workflow 4: Configure Selective Download

```powershell
# 1. Edit config/environments.json
# Change "download_mode" to "specific"
# Add processes in "specific_processes"

# 2. Download only those processes
.\pull.ps1 -Environment prod
```

## Downloaded Files Structure

```
C:\CPQ\workspace\
├── commerceAndDocuments\
│   ├── processDefinition\
│   │   ├── oraclecpqo_bmClone_1\
│   │   │   └── transaction\
│   │   │       └── libraries\
│   │   ├── metalsaProcess\
│   │   └── ... (other processes)
│   └── ... (documents, etc.)
├── developerTools\
└── ... (other resources)
```

## Tips and Best Practices

### 1. Always Connect First

```powershell
.\connect.ps1 -Environment test
```

This validates that:
- Java is installed
- CPQ ToolKit is available
- Credentials are correct
- Environment is accessible

### 2. Use Selective Download in Production

For production, it's better to configure `download_mode: "specific"` for:
- Faster downloads
- Less disk space usage
- Focus on critical processes

### 3. List Processes Before Downloading

```powershell
.\pull-process.ps1 -Environment test -ListProcesses
```

This shows you exactly which processes are available.

### 4. Backup Before Push to Production

```powershell
# Download current prod state
.\pull.ps1 -Environment prod

# Make backup
Copy-Item -Path "C:\CPQ\workspace\commerceAndDocuments" -Destination "C:\CPQ\backup\$(Get-Date -Format 'yyyyMMdd-HHmmss')" -Recurse

# Now push
.\push.ps1 -Environment prod
```

## Configuration Examples

### Example 1: Development Environment (Download Everything)

```json
"dev": {
  "name": "Development",
  "host": "dev.bigmachines.com",
  "protocol": "https",
  "description": "Development environment",
  "download_mode": "all",
  "specific_processes": []
}
```

### Example 2: Production Environment (Critical Processes Only)

```json
"prod": {
  "name": "Production",
  "host": "prod.bigmachines.com",
  "protocol": "https",
  "description": "Production environment",
  "download_mode": "specific",
  "specific_processes": [
    "oraclecpqo_bmClone_1",
    "metalsaQuotingProcess",
    "standardProcess2024"
  ]
}
```

### Example 3: QA Environment (Test Processes)

```json
"qa": {
  "name": "Quality Assurance",
  "host": "qa.bigmachines.com",
  "protocol": "https",
  "description": "QA environment",
  "download_mode": "specific",
  "specific_processes": [
    "testProcess",
    "demoProcess"
  ]
}
```

## Troubleshooting

### Problem: "Environment not found"

**Solution:** Verify that the environment name exists in `config/environments.json`

```powershell
.\connect.ps1 -Environment test -ShowEnvironments
```

### Problem: "Process not found"

**Solution:** List available processes first

```powershell
.\pull-process.ps1 -Environment test -ListProcesses
```

### Problem: "Incorrect credentials"

**Solution:** Edit `config/environments.json` and update username/password

### Problem: "Java not found"

**Solution:** Verify Java path in `config/environments.json`:

```json
"settings": {
  "java_home": "C:\\Program Files\\Java\\jdk-25.0.3"
}
```

## Command Summary

| Command | Description |
|---------|-------------|
| `.\connect.ps1 -Environment test` | Connect and validate environment |
| `.\connect.ps1 -Environment test -ShowEnvironments` | View available environments |
| `.\pull.ps1 -Environment test` | Download ALL content |
| `.\pull-process.ps1 -Environment test -ListProcesses` | List local processes |
| `.\pull-process.ps1 -Environment test -ProcessName X` | Download specific process |
| `.\push.ps1 -Environment test` | Upload changes |
| `.\packages.ps1 -Environment test` | List packages |

---

**Created by Bob - Universal CPQ Management System**