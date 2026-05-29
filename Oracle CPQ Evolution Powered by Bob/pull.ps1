# CPQ ToolKit - Universal Pull Script
# Download content from any CPQ environment

param(
    [Parameter(Mandatory=$true)]
    [string]$Environment
)

# Import configuration module
. "$PSScriptRoot\lib\Load-Config.ps1"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CPQ ToolKit - Universal Pull" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

try {
    # Load configuration
    $config = Load-Config -Environment $Environment
    
    Write-Host "Environment: $($config.Name)" -ForegroundColor Yellow
    Write-Host "Host: $($config.Host)" -ForegroundColor Yellow
    Write-Host "Username: $($config.Username)" -ForegroundColor Yellow
    Write-Host ""
    
    # Configure environment
    $env:JAVA_HOME = $config.JavaHome
    $env:PATH = "$($config.JavaHome)\bin;$env:PATH"
    Set-Environment -Config $config
    
    # Change to workspace
    Set-Location $config.WorkspacePath
    
    Write-Host "Downloading content from Oracle CPQ..." -ForegroundColor Green
    Write-Host "NOTE: This operation may take several minutes." -ForegroundColor Yellow
    Write-Host ""
    
    # Create temporary password file
    $tempPasswordFile = [System.IO.Path]::GetTempFileName()
    $config.Password | Out-File -FilePath $tempPasswordFile -Encoding ASCII -NoNewline
    
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
    
    $targetPath = $config.OutputPath
    Write-Host "Downloading to: $targetPath" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Executing: cpq-toolkit pull --basic-auth -u=$($config.Username) $targetPath" -ForegroundColor Gray
    Write-Host ""
    
    try {
        $output = & cmd /c "type `"$tempPasswordFile`" | `"$($config.CpqToolkitPath)`" pull --basic-auth -u=$($config.Username) $targetPath" 2>&1
        
        Write-Host $output
        Write-Host ""
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "========================================" -ForegroundColor Green
            Write-Host "OK DOWNLOAD COMPLETED" -ForegroundColor Green
            Write-Host "========================================" -ForegroundColor Green
            Write-Host ""
            
            # Show downloaded folders
            Write-Host "Downloaded folders:" -ForegroundColor Yellow
            $folders = Get-ChildItem -Path $config.OutputPath -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne ".cpqtoolkit" }
            foreach ($folder in $folders) {
                $fileCount = (Get-ChildItem -Path $folder.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count
                Write-Host "  - $($folder.Name) ($fileCount files)" -ForegroundColor Cyan
            }
            Write-Host ""
        }
        else {
            throw "Download failed. Exit code: $LASTEXITCODE"
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
