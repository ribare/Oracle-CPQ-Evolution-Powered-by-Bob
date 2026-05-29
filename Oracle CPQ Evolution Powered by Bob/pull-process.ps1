# CPQ ToolKit - Pull Specific Process Script
# Descarga un proceso especifico de Oracle CPQ

param(
    [Parameter(Mandatory=$true)]
    [string]$Environment,
    
    [Parameter(Mandatory=$false)]
    [string]$ProcessName,
    
    [Parameter(Mandatory=$false)]
    [switch]$ListProcesses
)

# Importar modulo de configuracion
. "$PSScriptRoot\lib\Load-Config.ps1"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CPQ ToolKit - Pull Process" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

try {
    # Cargar configuracion
    $config = Load-Config -Environment $Environment
    
    Write-Host "Ambiente: $($config.Name)" -ForegroundColor Yellow
    Write-Host "Host: $($config.Host)" -ForegroundColor Yellow
    Write-Host ""
    
    # Configurar ambiente
    $env:JAVA_HOME = $config.JavaHome
    $env:PATH = "$($config.JavaHome)\bin;$env:PATH"
    Set-Environment -Config $config
    
    # Cambiar al workspace
    Set-Location $config.WorkspacePath
    
    # Si se solicita listar procesos
    if ($ListProcesses) {
        Write-Host "Listando procesos disponibles en el workspace local..." -ForegroundColor Green
        Write-Host ""
        
        $processPath = "$($config.WorkspacePath)\commerceAndDocuments\processDefinition"
        
        if (Test-Path $processPath) {
            $processes = Get-ChildItem -Path $processPath -Directory | Select-Object Name
            
            if ($processes) {
                Write-Host "Procesos encontrados:" -ForegroundColor Cyan
                foreach ($proc in $processes) {
                    Write-Host "  - $($proc.Name)" -ForegroundColor White
                }
                Write-Host ""
                Write-Host "Total: $($processes.Count) procesos" -ForegroundColor Yellow
            }
            else {
                Write-Host "No se encontraron procesos. Ejecuta primero un pull completo." -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "No se encontro la carpeta de procesos." -ForegroundColor Yellow
            Write-Host "Ejecuta primero: .\pull.ps1 -Environment $Environment" -ForegroundColor White
        }
        
        Write-Host ""
        Write-Host "Para descargar un proceso especifico:" -ForegroundColor Yellow
        Write-Host "  .\pull-process.ps1 -Environment $Environment -ProcessName [NOMBRE_PROCESO]" -ForegroundColor White
        exit 0
    }
    
    # Validar que se proporciono un nombre de proceso
    if ([string]::IsNullOrWhiteSpace($ProcessName)) {
        Write-Host "ERROR: Debes especificar un nombre de proceso" -ForegroundColor Red
        Write-Host ""
        Write-Host "Uso:" -ForegroundColor Yellow
        Write-Host "  .\pull-process.ps1 -Environment $Environment -ProcessName oraclecpqo_bmClone_1" -ForegroundColor White
        Write-Host ""
        Write-Host "Para ver procesos disponibles:" -ForegroundColor Yellow
        Write-Host "  .\pull-process.ps1 -Environment $Environment -ListProcesses" -ForegroundColor White
        exit 1
    }
    
    Write-Host "Descargando proceso: $ProcessName" -ForegroundColor Green
    Write-Host ""
    
    # Crear archivo temporal con contrasena
    $tempPasswordFile = [System.IO.Path]::GetTempFileName()
    $config.Password | Out-File -FilePath $tempPasswordFile -Encoding ASCII -NoNewline
    
    try {
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
        
        $basePath = $config.OutputPath
        Write-Host "Descargando en: $basePath" -ForegroundColor Cyan
        
        # Construir ruta del proceso
        $processPath = "commerceAndDocuments\processDefinition\$ProcessName"
        $fullProcessPath = "$basePath\$processPath"
        Write-Host ""
        
        Write-Host "Ejecutando: cpq-toolkit pull --basic-auth -u=$($config.Username) $fullProcessPath" -ForegroundColor Gray
        Write-Host ""
        
        $output = & cmd /c "type `"$tempPasswordFile`" | `"$($config.CpqToolkitPath)`" pull --basic-auth -u=$($config.Username) $fullProcessPath" 2>&1
        
        Write-Host $output
        Write-Host ""
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "========================================" -ForegroundColor Green
            Write-Host "OK DESCARGA COMPLETADA" -ForegroundColor Green
            Write-Host "========================================" -ForegroundColor Green
            Write-Host ""
            Write-Host "Proceso descargado en:" -ForegroundColor Yellow
            Write-Host "  $fullProcessPath" -ForegroundColor Cyan
            Write-Host ""
            
            # Mostrar estadisticas
            if (Test-Path $fullProcessPath) {
                $fileCount = (Get-ChildItem -Path $fullProcessPath -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count
                $dirCount = (Get-ChildItem -Path $fullProcessPath -Recurse -Directory -ErrorAction SilentlyContinue | Measure-Object).Count
                
                Write-Host "Estadisticas:" -ForegroundColor Yellow
                Write-Host "  Archivos: $fileCount" -ForegroundColor White
                Write-Host "  Directorios: $dirCount" -ForegroundColor White
                Write-Host ""
            }
        }
        else {
            throw "Fallo en la descarga del proceso. Codigo de salida: $LASTEXITCODE"
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