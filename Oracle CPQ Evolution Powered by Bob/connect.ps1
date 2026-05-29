# CPQ ToolKit - Universal Connection Script
# Script universal para conectarse a cualquier ambiente CPQ

param(
    [Parameter(Mandatory=$true)]
    [string]$Environment,
    
    [Parameter(Mandatory=$false)]
    [switch]$ShowEnvironments
)

# Importar modulo de configuracion
. "$PSScriptRoot\lib\Load-Config.ps1"

# Si se solicita mostrar ambientes
if ($ShowEnvironments) {
    Show-AvailableEnvironments
    exit 0
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CPQ ToolKit - Conexion Universal" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

try {
    # Cargar configuracion del ambiente
    Write-Host "[1/5] Cargando configuracion del ambiente '$Environment'..." -ForegroundColor Yellow
    $config = Load-Config -Environment $Environment
    Write-Host "OK Configuracion cargada: $($config.Name)" -ForegroundColor Green
    Write-Host "  Host: $($config.Host)" -ForegroundColor White
    Write-Host ""
    
    # Verificar Java
    Write-Host "[2/5] Verificando Java..." -ForegroundColor Yellow
    $env:JAVA_HOME = $config.JavaHome
    $env:PATH = "$($config.JavaHome)\bin;$env:PATH"
    
    $javaVersion = & java -version 2>&1 | Select-Object -First 1
    Write-Host "OK Java encontrado: $javaVersion" -ForegroundColor Green
    Write-Host ""
    
    # Verificar CPQ ToolKit
    Write-Host "[3/5] Verificando CPQ ToolKit..." -ForegroundColor Yellow
    if (Test-Path $config.CpqToolkitPath) {
        Write-Host "OK CPQ ToolKit encontrado" -ForegroundColor Green
    }
    else {
        throw "CPQ ToolKit no encontrado en: $($config.CpqToolkitPath)"
    }
    Write-Host ""
    
    # Configurar workspace
    Write-Host "[4/5] Configurando workspace..." -ForegroundColor Yellow
    Set-Environment -Config $config
    Write-Host ""
    
    # Validar credenciales
    Write-Host "[5/5] Validando credenciales..." -ForegroundColor Yellow
    if ([string]::IsNullOrWhiteSpace($config.Username) -or [string]::IsNullOrWhiteSpace($config.Password)) {
        Write-Host "ADVERTENCIA: Credenciales no configuradas para este ambiente" -ForegroundColor Yellow
        Write-Host "  Edita el archivo: config\environments.json" -ForegroundColor White
        Write-Host ""
        Write-Host "Deseas ingresar las credenciales ahora? (S/N): " -ForegroundColor Cyan -NoNewline
        $response = Read-Host
        
        if ($response -eq "S" -or $response -eq "s") {
            $config.Username = Read-Host "Usuario"
            $securePassword = Read-Host "Contrasena" -AsSecureString
            $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
            $config.Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        }
        else {
            Write-Host ""
            Write-Host "Conexion cancelada. Configura las credenciales en config\environments.json" -ForegroundColor Yellow
            exit 1
        }
    }
    Write-Host "OK Usuario: $($config.Username)" -ForegroundColor Green
    Write-Host ""
    
    # Probar conexion
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Probando conexion con Oracle CPQ..." -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    Set-Location $config.WorkspacePath
    
    # Crear archivo temporal con contrasena
    $tempPasswordFile = [System.IO.Path]::GetTempFileName()
    $config.Password | Out-File -FilePath $tempPasswordFile -Encoding ASCII -NoNewline
    
    try {
        $output = & cmd /c "type `"$tempPasswordFile`" | `"$($config.CpqToolkitPath)`" package --basic-auth -u=$($config.Username) list" 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "========================================" -ForegroundColor Green
            Write-Host "OK CONEXION EXITOSA" -ForegroundColor Green
            Write-Host "========================================" -ForegroundColor Green
            Write-Host ""
            Write-Host "Ambiente: $($config.Name)" -ForegroundColor Cyan
            Write-Host "Host: $($config.Host)" -ForegroundColor Cyan
            Write-Host "Usuario: $($config.Username)" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "Comandos disponibles:" -ForegroundColor Yellow
            Write-Host "  .\pull.ps1 -Environment $Environment" -ForegroundColor White
            Write-Host "  .\push.ps1 -Environment $Environment" -ForegroundColor White
            Write-Host "  .\packages.ps1 -Environment $Environment" -ForegroundColor White
            Write-Host ""
        }
        else {
            throw "Fallo en la conexion. Codigo de salida: $LASTEXITCODE"
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
    Write-Host "Para ver ambientes disponibles:" -ForegroundColor Yellow
    Write-Host "  .\connect.ps1 -Environment test -ShowEnvironments" -ForegroundColor White
    exit 1
}

# Made with Bob
