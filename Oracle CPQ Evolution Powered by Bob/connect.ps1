# CPQ ToolKit - Universal Connection Script
# Universal script to connect to any CPQ environment

param(
    [Parameter(Mandatory=$true)]
    [string]$Environment,
    
    [Parameter(Mandatory=$false)]
    [switch]$ShowEnvironments
)

# Import configuration module
. "$PSScriptRoot\lib\Load-Config.ps1"

# If showing environments is requested
if ($ShowEnvironments) {
    Show-AvailableEnvironments
    exit 0
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CPQ ToolKit - Universal Connection" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

try {
    # Load environment configuration
    Write-Host "[1/5] Loading configuration for environment '$Environment'..." -ForegroundColor Yellow
    $config = Load-Config -Environment $Environment
    Write-Host "OK Configuration loaded: $($config.Name)" -ForegroundColor Green
    Write-Host "  Host: $($config.Host)" -ForegroundColor White
    Write-Host ""
    
    # Verify Java
    Write-Host "[2/5] Verifying Java..." -ForegroundColor Yellow
    $env:JAVA_HOME = $config.JavaHome
    $env:PATH = "$($config.JavaHome)\bin;$env:PATH"
    
    $javaVersion = & java -version 2>&1 | Select-Object -First 1
    Write-Host "OK Java found: $javaVersion" -ForegroundColor Green
    Write-Host ""
    
    # Verify CPQ ToolKit
    Write-Host "[3/5] Verifying CPQ ToolKit..." -ForegroundColor Yellow
    if (Test-Path $config.CpqToolkitPath) {
        Write-Host "OK CPQ ToolKit found" -ForegroundColor Green
    }
    else {
        throw "CPQ ToolKit not found at: $($config.CpqToolkitPath)"
    }
    Write-Host ""
    
    # Configure workspace
    Write-Host "[4/5] Configuring workspace..." -ForegroundColor Yellow
    Set-Environment -Config $config
    Write-Host ""
    
    # Validate credentials
    Write-Host "[5/5] Validating credentials..." -ForegroundColor Yellow
    if ([string]::IsNullOrWhiteSpace($config.Username) -or [string]::IsNullOrWhiteSpace($config.Password)) {
        Write-Host "WARNING: Credentials not configured for this environment" -ForegroundColor Yellow
        Write-Host "  Edit the file: config\environments.json" -ForegroundColor White
        Write-Host ""
        Write-Host "Do you want to enter credentials now? (Y/N): " -ForegroundColor Cyan -NoNewline
        $response = Read-Host
        
        if ($response -eq "Y" -or $response -eq "y") {
            $config.Username = Read-Host "Username"
            $securePassword = Read-Host "Password" -AsSecureString
            $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
            $config.Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        }
        else {
            Write-Host ""
            Write-Host "Connection cancelled. Configure credentials in config\environments.json" -ForegroundColor Yellow
            exit 1
        }
    }
    Write-Host "OK Username: $($config.Username)" -ForegroundColor Green
    Write-Host ""
    
    # Test connection
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Testing connection with Oracle CPQ..." -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    Set-Location $config.WorkspacePath
    
    # Create temporary password file
    $tempPasswordFile = [System.IO.Path]::GetTempFileName()
    $config.Password | Out-File -FilePath $tempPasswordFile -Encoding ASCII -NoNewline
    
    try {
        $output = & cmd /c "type `"$tempPasswordFile`" | `"$($config.CpqToolkitPath)`" package --basic-auth -u=$($config.Username) list" 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "========================================" -ForegroundColor Green
            Write-Host "OK CONNECTION SUCCESSFUL" -ForegroundColor Green
            Write-Host "========================================" -ForegroundColor Green
            Write-Host ""
            Write-Host "Environment: $($config.Name)" -ForegroundColor Cyan
            Write-Host "Host: $($config.Host)" -ForegroundColor Cyan
            Write-Host "Username: $($config.Username)" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "Available commands:" -ForegroundColor Yellow
            Write-Host "  .\pull.ps1 -Environment $Environment" -ForegroundColor White
            Write-Host "  .\push.ps1 -Environment $Environment" -ForegroundColor White
            Write-Host "  .\packages.ps1 -Environment $Environment" -ForegroundColor White
            Write-Host ""
        }
        else {
            throw "Connection failed. Exit code: $LASTEXITCODE"
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
    Write-Host ""
    Write-Host "To view available environments:" -ForegroundColor Yellow
    Write-Host "  .\connect.ps1 -Environment test -ShowEnvironments" -ForegroundColor White
    exit 1
}

# Made with Bob
