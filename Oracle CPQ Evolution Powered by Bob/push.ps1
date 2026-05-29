# CPQ ToolKit - Universal Push Script
# Sube contenido a cualquier ambiente CPQ

param(
    [Parameter(Mandatory=$true)]
    [string]$Environment,
    
    [Parameter(Mandatory=$false)]
    [string]$Path = "."
)

# Importar modulo de configuracion
. "$PSScriptRoot\lib\Load-Config.ps1"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CPQ ToolKit - Push Universal" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

try {
    # Cargar configuracion
    $config = Load-Config -Environment $Environment
    
    Write-Host "Ambiente: $($config.Name)" -ForegroundColor Yellow
    Write-Host "Host: $($config.Host)" -ForegroundColor Yellow
    Write-Host "Usuario: $($config.Username)" -ForegroundColor Yellow
    Write-Host ""
    
    # Advertencia para produccion
    if ($Environment -eq "prod") {
        Write-Host "ADVERTENCIA: Estas a punto de subir cambios a PRODUCCION" -ForegroundColor Red
        Write-Host "Estas seguro de continuar? (S/N): " -ForegroundColor Yellow -NoNewline
        $response = Read-Host
        
        if ($response -ne "S" -and $response -ne "s") {
            Write-Host "Operacion cancelada." -ForegroundColor Yellow
            exit 0
        }
    }
    
    # Configurar ambiente
    $env:JAVA_HOME = $config.JavaHome
    $env:PATH = "$($config.JavaHome)\bin;$env:PATH"
    Set-Environment -Config $config
    
    # Cambiar al workspace
    Set-Location $config.WorkspacePath
    
    Write-Host "Subiendo contenido a Oracle CPQ..." -ForegroundColor Green
    Write-Host ""
    
    # Crear archivo temporal con contrasena
    $tempPasswordFile = [System.IO.Path]::GetTempFileName()
    $config.Password | Out-File -FilePath $tempPasswordFile -Encoding ASCII -NoNewline
    
    try {
        # Usar output_path si esta configurado, sino usar workspace
        $targetPath = if ([string]::IsNullOrWhiteSpace($config.OutputPath)) { 
            $config.WorkspacePath 
        } else { 
            $config.OutputPath 
        }
        
        Write-Host "Subiendo desde: $targetPath" -ForegroundColor Cyan
        Write-Host ""
        
        Write-Host "Ejecutando: cpq-toolkit push --basic-auth -u=$($config.Username) $targetPath" -ForegroundColor Gray
        Write-Host ""
        
        $output = & cmd /c "type `"$tempPasswordFile`" | `"$($config.CpqToolkitPath)`" push --basic-auth -u=$($config.Username) $targetPath" 2>&1
        
        Write-Host $output
        Write-Host ""
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "========================================" -ForegroundColor Green
            Write-Host "OK PUSH COMPLETADO" -ForegroundColor Green
            Write-Host "========================================" -ForegroundColor Green
            Write-Host ""
            Write-Host "Los cambios han sido subidos exitosamente a:" -ForegroundColor Cyan
            Write-Host "  $($config.Name) ($($config.Host))" -ForegroundColor White
            Write-Host ""
        }
        else {
            throw "Fallo en el push. Codigo de salida: $LASTEXITCODE"
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
