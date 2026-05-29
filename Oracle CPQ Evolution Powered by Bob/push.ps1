# CPQ ToolKit - Universal Push Script
# Upload content to any CPQ environment

param(
    [Parameter(Mandatory=$true)]
    [string]$Environment,
    
    [Parameter(Mandatory=$false)]
    [string]$Path = "."
)

# Import configuration module
. "$PSScriptRoot\lib\Load-Config.ps1"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CPQ ToolKit - Universal Push" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

try {
    # Load configuration
    $config = Load-Config -Environment $Environment
    
    Write-Host "Environment: $($config.Name)" -ForegroundColor Yellow
    Write-Host "Host: $($config.Host)" -ForegroundColor Yellow
    Write-Host "Username: $($config.Username)" -ForegroundColor Yellow
    Write-Host ""
    
    # Warning for production
    if ($Environment -eq "prod") {
        Write-Host "WARNING: You are about to upload changes to PRODUCTION" -ForegroundColor Red
        Write-Host "Are you sure you want to continue? (Y/N): " -ForegroundColor Yellow -NoNewline
        $response = Read-Host
        
        if ($response -ne "Y" -and $response -ne "y") {
            Write-Host "Operation cancelled." -ForegroundColor Yellow
            exit 0
        }
    }
    
    # Configure environment
    $env:JAVA_HOME = $config.JavaHome
    $env:PATH = "$($config.JavaHome)\bin;$env:PATH"
    Set-Environment -Config $config
    
    # Change to workspace
    Set-Location $config.WorkspacePath
    
    Write-Host "Uploading content to Oracle CPQ..." -ForegroundColor Green
    Write-Host ""
    
    # Create temporary password file
    $tempPasswordFile = [System.IO.Path]::GetTempFileName()
    $config.Password | Out-File -FilePath $tempPasswordFile -Encoding ASCII -NoNewline
    
    try {
        # Use output_path if configured, otherwise use workspace
        $targetPath = if ([string]::IsNullOrWhiteSpace($config.OutputPath)) { 
            $config.WorkspacePath 
        } else { 
            $config.OutputPath 
        }
        
        Write-Host "Uploading from: $targetPath" -ForegroundColor Cyan
        Write-Host ""
        
        Write-Host "Executing: cpq-toolkit push --basic-auth -u=$($config.Username) $targetPath" -ForegroundColor Gray
        Write-Host ""
        
        $output = & cmd /c "type `"$tempPasswordFile`" | `"$($config.CpqToolkitPath)`" push --basic-auth -u=$($config.Username) $targetPath" 2>&1
        
        Write-Host $output
        Write-Host ""
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "========================================" -ForegroundColor Green
            Write-Host "OK PUSH COMPLETED" -ForegroundColor Green
            Write-Host "========================================" -ForegroundColor Green
            Write-Host ""
            Write-Host "Changes have been successfully uploaded to:" -ForegroundColor Cyan
            Write-Host "  $($config.Name) ($($config.Host))" -ForegroundColor White
            Write-Host ""
        }
        else {
            throw "Push failed. Exit code: $LASTEXITCODE"
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
