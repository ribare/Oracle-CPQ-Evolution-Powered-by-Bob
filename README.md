# Universal CPQ Management System

Reusable and configurable system for managing multiple Oracle CPQ environments.

## Project Structure

```
C:\CPQ\workspace\
├── .cpqtoolkit\              # Internal toolkit configuration
├── config\
│   └── environments.json     # Environment and credentials configuration
├── lib\
│   └── Load-Config.ps1       # Configuration loading module
├── connect.ps1               # Universal connection script
├── pull.ps1                  # Download complete content
├── pull-process.ps1          # Download specific processes
├── push.ps1                  # Upload content to CPQ
├── packages.ps1              # List available packages
├── GUIA-RAPIDA.md            # Quick usage guide
└── README-UNIVERSAL.md       # Complete technical documentation
```

## Quick Start

### 1. Configure Environments

Edit `config/environments.json` with your environments:

```json
{
  "environments": {
    "test": {
      "name": "Test Environment",
      "host": "test.bigmachines.com",
      "protocol": "https",
      "description": "Testing environment",
      "download_mode": "all",
      "specific_processes": []
    }
  },
  "credentials": {
    "test": {
      "username": "your-username",
      "password": "your-password"
    }
  }
}
```

### 2. Connect

```powershell
.\connect.ps1 -Environment test
```

### 3. Download Content

**Option A: Download EVERYTHING**
```powershell
.\pull.ps1 -Environment test
```

**Option B: Download specific process**
```powershell
# List available processes
.\pull-process.ps1 -Environment test -ListProcesses

# Download a specific one
.\pull-process.ps1 -Environment test -ProcessName oraclecpqo_bmClone_1
```

### 4. Upload Changes

```powershell
.\push.ps1 -Environment test
```

## Main Commands

| Command | Description |
|---------|-------------|
| `.\connect.ps1 -Environment X` | Connect and validate environment |
| `.\connect.ps1 -Environment X -ShowEnvironments` | View available environments |
| `.\pull.ps1 -Environment X` | Download ALL content |
| `.\pull-process.ps1 -Environment X -ListProcesses` | List local processes |
| `.\pull-process.ps1 -Environment X -ProcessName Y` | Download specific process |
| `.\push.ps1 -Environment X` | Upload changes to environment |
| `.\packages.ps1 -Environment X` | List available packages |

## Download Modes

### "all" Mode - Download EVERYTHING

```json
"download_mode": "all",
"specific_processes": []
```

Downloads all CPQ site content:
- All processes
- Documents
- Resources
- Configurations

### "specific" Mode - Download Only Specific Processes

```json
"download_mode": "specific",
"specific_processes": [
  "oraclecpqo_bmClone_1",
  "metalsaProcess"
]
```

Downloads only the processes specified in the list.

## Documentation

- **QUICK-GUIDE.md** - Quick guide with examples and workflows
- **README-UNIVERSAL.md** - Complete technical documentation

## Requirements

- Windows 10/11
- PowerShell 5.1 or higher
- Java JDK installed
- Oracle CPQ ToolKit installed

## Support

For issues or questions, consult:
1. QUICK-GUIDE.md - "Troubleshooting" section
2. README-UNIVERSAL.md - Complete documentation

---

**Created by Bob - Universal CPQ Management System**
**Version: 1.0**
**Date: 2026-05-22**