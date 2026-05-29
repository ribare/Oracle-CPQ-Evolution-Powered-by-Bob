# CPQ ToolKit - Configuration Loader
# Carga la configuracion de ambientes y credenciales

function Load-Config {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Environment
    )
    
    $configPath = "C:\CPQ\workspace\config\environments.json"
    
    if (-not (Test-Path $configPath)) {
        throw "Archivo de configuracion no encontrado: $configPath"
    }
    
    $config = Get-Content $configPath -Raw | ConvertFrom-Json
    
    # Validar que el ambiente existe
    if (-not $config.environments.$Environment) {
        $availableEnvs = ($config.environments | Get-Member -MemberType NoteProperty).Name -join ", "
        throw "Ambiente '$Environment' no encontrado. Ambientes disponibles: $availableEnvs"
    }
    
    # Crear objeto de configuracion
    $envConfig = @{
        Name = $config.environments.$Environment.name
        Host = $config.environments.$Environment.host
        Protocol = $config.environments.$Environment.protocol
        Description = $config.environments.$Environment.description
        Username = $config.credentials.$Environment.username
        Password = $config.credentials.$Environment.password
        JavaHome = $config.settings.java_home
        CpqToolkitPath = $config.settings.cpq_toolkit_path
        WorkspacePath = $config.settings.workspace_path
        OutputPath = $config.environments.$Environment.output_path
        DownloadMode = $config.environments.$Environment.download_mode
        SpecificProcesses = $config.environments.$Environment.specific_processes
    }
    
    return $envConfig
}

function Set-Environment {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Config
    )
    
    # Configurar Java
    $env:JAVA_HOME = $Config.JavaHome
    $env:PATH = "$($Config.JavaHome)\bin;$env:PATH"
    
    # Actualizar workspace.properties
    $workspacePropertiesPath = "$($Config.WorkspacePath)\.cpqtoolkit\settings\workspace.properties"
    
    if (Test-Path $workspacePropertiesPath) {
        $content = @"
# CPQ Toolkit Workspace Configuration
# Generated automatically - Do not edit manually

remote.host=$($Config.Host)
remote.protocol=$($Config.Protocol)
"@
        $content | Out-File -FilePath $workspacePropertiesPath -Encoding UTF8
        Write-Host "OK Workspace configurado para: $($Config.Name)" -ForegroundColor Green
    }
}

function Show-AvailableEnvironments {
    $configPath = "C:\CPQ\workspace\config\environments.json"
    
    if (-not (Test-Path $configPath)) {
        Write-Host "Archivo de configuracion no encontrado" -ForegroundColor Red
        return
    }
    
    $config = Get-Content $configPath -Raw | ConvertFrom-Json
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Ambientes Disponibles" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    foreach ($env in ($config.environments | Get-Member -MemberType NoteProperty).Name) {
        $envData = $config.environments.$env
        Write-Host "[$env]" -ForegroundColor Yellow
        Write-Host "  Nombre: $($envData.name)" -ForegroundColor White
        Write-Host "  Host: $($envData.host)" -ForegroundColor White
        Write-Host "  Descripcion: $($envData.description)" -ForegroundColor Gray
        Write-Host ""
    }
}

# Made with Bob
