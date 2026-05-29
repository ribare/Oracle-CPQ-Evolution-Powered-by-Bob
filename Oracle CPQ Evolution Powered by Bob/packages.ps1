# CPQ ToolKit - Universal Packages Script
# List available packages in any CPQ environment

param(
    [Parameter(Mandatory=$true)]
    [string]$Environment
)

# Import configuration module
. "$PSScriptRoot\lib\Load-Config.ps1"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CPQ ToolKit - List Packages" -ForegroundColor Cyan
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
    
    Write-Host "Listing available packages..." -ForegroundColor Green
    Write-Host ""
    
    # Create temporary password file
    $tempPasswordFile = [System.IO.Path]::GetTempFileName()
    $config.Password | Out-File -FilePath $tempPasswordFile -Encoding ASCII -NoNewline
    
    try {
        $output = & cmd /c "type `"$tempPasswordFile`" | `"$($config.CpqToolkitPath)`" package --basic-auth -u=$($config.Username) list" 2>&1
        
        Write-Host $output
        Write-Host ""
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "========================================" -ForegroundColor Green
            Write-Host "✓ Listing completed" -ForegroundColor Green
            Write-Host "========================================" -ForegroundColor Green
            Write-Host ""
            Write-Host "To download a specific package:" -ForegroundColor Yellow
            Write-Host "  .\download-package.ps1 -Environment $Environment -PackageId [PACKAGE_ID]" -ForegroundColor White
            Write-Host ""
        }
        else {
            throw "Failed to list packages. Exit code: $LASTEXITCODE"
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
