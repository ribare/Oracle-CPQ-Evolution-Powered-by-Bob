# CPQ ToolKit - Pull Specific Process Script
# Download a specific process from Oracle CPQ

param(
    [Parameter(Mandatory=$true)]
    [string]$Environment,
    
    [Parameter(Mandatory=$false)]
    [string]$ProcessName,
    
    [Parameter(Mandatory=$false)]
    [switch]$ListProcesses
)

# Import configuration module
. "$PSScriptRoot\lib\Load-Config.ps1"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CPQ ToolKit - Pull Process" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

try {
    # Load configuration
    $config = Load-Config -Environment $Environment
    
    Write-Host "Environment: $($config.Name)" -ForegroundColor Yellow
    Write-Host "Host: $($config.Host)" -ForegroundColor Yellow
    Write-Host ""
    
    # Configure environment
    $env:JAVA_HOME = $config.JavaHome
    $env:PATH = "$($config.JavaHome)\bin;$env:PATH"
    Set-Environment -Config $config
    
    # Change to workspace
    Set-Location $config.WorkspacePath
    
    # If listing processes is requested
    if ($ListProcesses) {
        Write-Host "Listing processes available in local workspace..." -ForegroundColor Green
        Write-Host ""
        
        $processPath = "$($config.WorkspacePath)\commerceAndDocuments\processDefinition"
        
        if (Test-Path $processPath) {
            $processes = Get-ChildItem -Path $processPath -Directory | Select-Object Name
            
            if ($processes) {
                Write-Host "Processes found:" -ForegroundColor Cyan
                foreach ($proc in $processes) {
                    Write-Host "  - $($proc.Name)" -ForegroundColor White
                }
                Write-Host ""
                Write-Host "Total: $($processes.Count) processes" -ForegroundColor Yellow
            }
            else {
                Write-Host "No processes found. Run a full pull first." -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "Process folder not found." -ForegroundColor Yellow
            Write-Host "Run first: .\pull.ps1 -Environment $Environment" -ForegroundColor White
        }
        
        Write-Host ""
        Write-Host "To download a specific process:" -ForegroundColor Yellow
        Write-Host "  .\pull-process.ps1 -Environment $Environment -ProcessName [PROCESS_NAME]" -ForegroundColor White
        exit 0
    }
    
    # Validate that a process name was provided
    if ([string]::IsNullOrWhiteSpace($ProcessName)) {
        Write-Host "ERROR: You must specify a process name" -ForegroundColor Red
        Write-Host ""
        Write-Host "Usage:" -ForegroundColor Yellow
        Write-Host "  .\pull-process.ps1 -Environment $Environment -ProcessName oraclecpqo_bmClone_1" -ForegroundColor White
        Write-Host ""
        Write-Host "To view available processes:" -ForegroundColor Yellow
        Write-Host "  .\pull-process.ps1 -Environment $Environment -ListProcesses" -ForegroundColor White
        exit 1
    }
    
    Write-Host "Downloading process: $ProcessName" -ForegroundColor Green
    Write-Host ""
    
    # Create temporary password file
    $tempPasswordFile = [System.IO.Path]::GetTempFileName()
    $config.Password | Out-File -FilePath $tempPasswordFile -Encoding ASCII -NoNewline
    
    try {
        # Validate that output_path is configured
        if ([string]::IsNullOrWhiteSpace($config.OutputPath)) {
            Write-Host ""
            Write-Host "========================================" -ForegroundColor Red
            Write-Host "ERROR: output_path not configured" -ForegroundColor Red
            Write-Host "========================================" -ForegroundColor Red
            Write-Host ""
            Write-Host "You must specify a download path in config\environments.json" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Example:" -ForegroundColor White
            Write-Host '  "output_path": "C:\\MyProjects\\CPQ-Test"' -ForegroundColor Cyan
            Write-Host ""
            throw "output_path not configured for environment $Environment"
        }
        
        # Create directory if it doesn't exist
        if (-not (Test-Path $config.OutputPath)) {
            New-Item -Path $config.OutputPath -ItemType Directory -Force | Out-Null
            Write-Host "Directory created: $($config.OutputPath)" -ForegroundColor Green
        }
        
        $basePath = $config.OutputPath
        Write-Host "Downloading to: $basePath" -ForegroundColor Cyan
        
        # Build process path
        $processPath = "commerceAndDocuments\processDefinition\$ProcessName"
        $fullProcessPath = "$basePath\$processPath"
        Write-Host ""
        
        Write-Host "Executing: cpq-toolkit pull --basic-auth -u=$($config.Username) $fullProcessPath" -ForegroundColor Gray
        Write-Host ""
        
        $output = & cmd /c "type `"$tempPasswordFile`" | `"$($config.CpqToolkitPath)`" pull --basic-auth -u=$($config.Username) $fullProcessPath" 2>&1
        
        Write-Host $output
        Write-Host ""
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "========================================" -ForegroundColor Green
            Write-Host "OK DOWNLOAD COMPLETED" -ForegroundColor Green
            Write-Host "========================================" -ForegroundColor Green
            Write-Host ""
            Write-Host "Process downloaded to:" -ForegroundColor Yellow
            Write-Host "  $fullProcessPath" -ForegroundColor Cyan
            Write-Host ""
            
            # Show statistics
            if (Test-Path $fullProcessPath) {
                $fileCount = (Get-ChildItem -Path $fullProcessPath -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count
                $dirCount = (Get-ChildItem -Path $fullProcessPath -Recurse -Directory -ErrorAction SilentlyContinue | Measure-Object).Count
                
                Write-Host "Statistics:" -ForegroundColor Yellow
                Write-Host "  Files: $fileCount" -ForegroundColor White
                Write-Host "  Directories: $dirCount" -ForegroundColor White
                Write-Host ""
            }
        }
        else {
            throw "Process download failed. Exit code: $LASTEXITCODE"
        }
    }
    finally {
        if (Test-Path $tempPasswordFile) {
            Remove-Item $tempPasswordFile -Force
        }
    }
}
catch {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "ERROR" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# Made with Bob