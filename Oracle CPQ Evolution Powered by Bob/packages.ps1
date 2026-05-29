# CPQ ToolKit - Universal Packages Script
# Lista paquetes disponibles en cualquier ambiente CPQ

param(
    [Parameter(Mandatory=$true)]
    [string]$Environment
)

# Importar mÃ³dulo de configuraciÃ³n
. "$PSScriptRoot\lib\Load-Config.ps1"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CPQ ToolKit - Listar Paquetes" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

try {
    # Cargar configuraciÃ³n
    $config = Load-Config -Environment $Environment
    
    Write-Host "Ambiente: $($config.Name)" -ForegroundColor Yellow
    Write-Host "Host: $($config.Host)" -ForegroundColor Yellow
    Write-Host "Usuario: $($config.Username)" -ForegroundColor Yellow
    Write-Host ""
    
    # Configurar ambiente
    $env:JAVA_HOME = $config.JavaHome
    $env:PATH = "$($config.JavaHome)\bin;$env:PATH"
    Set-Environment -Config $config
    
    # Cambiar al workspace
    Set-Location $config.WorkspacePath
    
    Write-Host "Listando paquetes disponibles..." -ForegroundColor Green
    Write-Host ""
    
    # Crear archivo temporal con contraseÃ±a
    $tempPasswordFile = [System.IO.Path]::GetTempFileName()
    $config.Password | Out-File -FilePath $tempPasswordFile -Encoding ASCII -NoNewline
    
    try {
        $output = & cmd /c "type `"$tempPasswordFile`" | `"$($config.CpqToolkitPath)`" package --basic-auth -u=$($config.Username) list" 2>&1
        
        Write-Host $output
        Write-Host ""
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "========================================" -ForegroundColor Green
            Write-Host "âœ“ Listado completado" -ForegroundColor Green
            Write-Host "========================================" -ForegroundColor Green
            Write-Host ""
            Write-Host "Para descargar un paquete especÃ­fico:" -ForegroundColor Yellow
            Write-Host "  .\download-package.ps1 -Environment $Environment -PackageId [PACKAGE_ID]" -ForegroundColor White
            Write-Host ""
        }
        else {
            throw "Fallo al listar paquetes. CÃ³digo de salida: $LASTEXITCODE"
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
