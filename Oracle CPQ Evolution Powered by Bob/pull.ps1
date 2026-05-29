# CPQ ToolKit - Universal Pull Script
# Descarga contenido de cualquier ambiente CPQ

param(
    [Parameter(Mandatory=$true)]
    [string]$Environment
)

# Importar mÃ³dulo de configuraciÃ³n
. "$PSScriptRoot\lib\Load-Config.ps1"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CPQ ToolKit - Pull Universal" -ForegroundColor Cyan
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
    
    Write-Host "Descargando contenido de Oracle CPQ..." -ForegroundColor Green
    Write-Host "NOTA: Esta operaciÃ³n puede tomar varios minutos." -ForegroundColor Yellow
    Write-Host ""
    
    # Crear archivo temporal con contraseÃ±a
    $tempPasswordFile = [System.IO.Path]::GetTempFileName()
    $config.Password | Out-File -FilePath $tempPasswordFile -Encoding ASCII -NoNewline
    
    # Validar que output_path este configurado
    if ([string]::IsNullOrWhiteSpace($config.OutputPath)) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Red
        Write-Host "ERROR: output_path no configurado" -ForegroundColor Red
        Write-Host "========================================" -ForegroundColor Red
        Write-Host ""
        Write-Host "Debes especificar una ruta de descarga en config\environments.json" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Ejemplo:" -ForegroundColor White
        Write-Host '  "output_path": "C:\\MisProyectos\\CPQ-Test"' -ForegroundColor Cyan
        Write-Host ""
        throw "output_path no configurado para el ambiente $Environment"
    }
    
    # Crear directorio si no existe
    if (-not (Test-Path $config.OutputPath)) {
        New-Item -Path $config.OutputPath -ItemType Directory -Force | Out-Null
        Write-Host "Directorio creado: $($config.OutputPath)" -ForegroundColor Green
    }
    
    $targetPath = $config.OutputPath
    Write-Host "Descargando en: $targetPath" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Ejecutando: cpq-toolkit pull --basic-auth -u=$($config.Username) $targetPath" -ForegroundColor Gray
    Write-Host ""
    
    try {
        $output = & cmd /c "type `"$tempPasswordFile`" | `"$($config.CpqToolkitPath)`" pull --basic-auth -u=$($config.Username) $targetPath" 2>&1
        
        Write-Host $output
        Write-Host ""
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "========================================" -ForegroundColor Green
            Write-Host "OK DESCARGA COMPLETADA" -ForegroundColor Green
            Write-Host "========================================" -ForegroundColor Green
            Write-Host ""
            
            # Mostrar carpetas descargadas
            Write-Host "Carpetas descargadas:" -ForegroundColor Yellow
            $folders = Get-ChildItem -Path $config.OutputPath -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne ".cpqtoolkit" }
            foreach ($folder in $folders) {
                $fileCount = (Get-ChildItem -Path $folder.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count
                Write-Host "  - $($folder.Name) ($fileCount archivos)" -ForegroundColor Cyan
            }
            Write-Host ""
        }
        else {
            throw "Fallo en la descarga. Codigo de salida: $LASTEXITCODE"
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
