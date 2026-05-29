# Guia Rapida - Sistema Universal CPQ

## Configuracion de Ambientes

### Archivo: `config/environments.json`

```json
{
  "environments": {
    "test": {
      "name": "Accel Alpha Test",
      "host": "accelalphatest.bigmachines.com",
      "protocol": "https",
      "description": "Ambiente de pruebas",
      "download_mode": "all",
      "specific_processes": []
    }
  }
}
```

### Opciones de `download_mode`:

- **`"all"`**: Descarga TODO el contenido del sitio (todos los procesos, documentos, etc.)
- **`"specific"`**: Descarga solo los procesos especificados en `specific_processes`

### Ejemplo de configuracion para descargar procesos especificos:

```json
{
  "environments": {
    "prod": {
      "name": "Production",
      "host": "prod.bigmachines.com",
      "protocol": "https",
      "description": "Ambiente de produccion",
      "download_mode": "specific",
      "specific_processes": [
        "oraclecpqo_bmClone_1",
        "metalsaProcess",
        "appleQuotingProcess"
      ]
    }
  }
}
```

## Comandos Principales

### 1. Conectar y Validar Ambiente

```powershell
.\connect.ps1 -Environment test
```

### 2. Ver Ambientes Disponibles

```powershell
.\connect.ps1 -Environment test -ShowEnvironments
```

### 3. Descargar TODO el Contenido

```powershell
# Descarga TODOS los procesos, documentos, recursos, etc.
.\pull.ps1 -Environment test
```

### 4. Listar Procesos Disponibles Localmente

```powershell
# Muestra los procesos que ya descargaste
.\pull-process.ps1 -Environment test -ListProcesses
```

### 5. Descargar un Proceso Especifico

```powershell
# Descarga solo el proceso indicado
.\pull-process.ps1 -Environment test -ProcessName oraclecpqo_bmClone_1
```

### 6. Subir Cambios

```powershell
# Sube TODO el contenido local al ambiente
.\push.ps1 -Environment test
```

### 7. Listar Paquetes Disponibles

```powershell
.\packages.ps1 -Environment test
```

## Flujos de Trabajo Comunes

### Flujo 1: Descargar TODO y Trabajar Localmente

```powershell
# 1. Conectar
.\connect.ps1 -Environment test

# 2. Descargar todo
.\pull.ps1 -Environment test

# 3. Editar archivos localmente
# ... hacer cambios ...

# 4. Subir cambios
.\push.ps1 -Environment test
```

### Flujo 2: Trabajar con un Proceso Especifico

```powershell
# 1. Conectar
.\connect.ps1 -Environment test

# 2. Ver procesos disponibles
.\pull-process.ps1 -Environment test -ListProcesses

# 3. Descargar proceso especifico
.\pull-process.ps1 -Environment test -ProcessName oraclecpqo_bmClone_1

# 4. Editar el proceso localmente
# ... hacer cambios en commerceAndDocuments\processDefinition\oraclecpqo_bmClone_1 ...

# 5. Subir cambios
.\push.ps1 -Environment test
```

### Flujo 3: Migrar Contenido entre Ambientes

```powershell
# 1. Descargar de test
.\pull.ps1 -Environment test

# 2. Subir a dev
.\push.ps1 -Environment dev

# 3. Verificar en dev
.\connect.ps1 -Environment dev
```

### Flujo 4: Configurar Descarga Selectiva

```powershell
# 1. Editar config/environments.json
# Cambiar "download_mode" a "specific"
# Agregar procesos en "specific_processes"

# 2. Descargar solo esos procesos
.\pull.ps1 -Environment prod
```

## Estructura de Archivos Descargados

```
C:\CPQ\workspace\
├── commerceAndDocuments\
│   ├── processDefinition\
│   │   ├── oraclecpqo_bmClone_1\
│   │   │   └── transaction\
│   │   │       └── libraries\
│   │   ├── metalsaProcess\
│   │   └── ... (otros procesos)
│   └── ... (documentos, etc.)
├── developerTools\
└── ... (otros recursos)
```

## Consejos y Mejores Practicas

### 1. Siempre Conectar Primero

```powershell
.\connect.ps1 -Environment test
```

Esto valida que:
- Java esta instalado
- CPQ ToolKit esta disponible
- Las credenciales son correctas
- El ambiente es accesible

### 2. Usar Descarga Selectiva en Produccion

Para produccion, es mejor configurar `download_mode: "specific"` para:
- Descargas mas rapidas
- Menor uso de espacio
- Enfoque en procesos criticos

### 3. Listar Procesos Antes de Descargar

```powershell
.\pull-process.ps1 -Environment test -ListProcesses
```

Esto te muestra exactamente que procesos estan disponibles.

### 4. Backup Antes de Push a Produccion

```powershell
# Descargar estado actual de prod
.\pull.ps1 -Environment prod

# Hacer backup
Copy-Item -Path "C:\CPQ\workspace\commerceAndDocuments" -Destination "C:\CPQ\backup\$(Get-Date -Format 'yyyyMMdd-HHmmss')" -Recurse

# Ahora si, hacer push
.\push.ps1 -Environment prod
```

## Ejemplos de Configuracion

### Ejemplo 1: Ambiente de Desarrollo (Descargar Todo)

```json
"dev": {
  "name": "Development",
  "host": "dev.bigmachines.com",
  "protocol": "https",
  "description": "Ambiente de desarrollo",
  "download_mode": "all",
  "specific_processes": []
}
```

### Ejemplo 2: Ambiente de Produccion (Solo Procesos Criticos)

```json
"prod": {
  "name": "Production",
  "host": "prod.bigmachines.com",
  "protocol": "https",
  "description": "Ambiente de produccion",
  "download_mode": "specific",
  "specific_processes": [
    "oraclecpqo_bmClone_1",
    "metalsaQuotingProcess",
    "standardProcess2024"
  ]
}
```

### Ejemplo 3: Ambiente de QA (Procesos de Prueba)

```json
"qa": {
  "name": "Quality Assurance",
  "host": "qa.bigmachines.com",
  "protocol": "https",
  "description": "Ambiente de QA",
  "download_mode": "specific",
  "specific_processes": [
    "testProcess",
    "demoProcess"
  ]
}
```

## Solucion de Problemas

### Problema: "Ambiente no encontrado"

**Solucion:** Verifica que el nombre del ambiente existe en `config/environments.json`

```powershell
.\connect.ps1 -Environment test -ShowEnvironments
```

### Problema: "Proceso no encontrado"

**Solucion:** Lista los procesos disponibles primero

```powershell
.\pull-process.ps1 -Environment test -ListProcesses
```

### Problema: "Credenciales incorrectas"

**Solucion:** Edita `config/environments.json` y actualiza username/password

### Problema: "Java no encontrado"

**Solucion:** Verifica la ruta de Java en `config/environments.json`:

```json
"settings": {
  "java_home": "C:\\Program Files\\Java\\jdk-25.0.3"
}
```

## Resumen de Comandos

| Comando | Descripcion |
|---------|-------------|
| `.\connect.ps1 -Environment test` | Conectar y validar ambiente |
| `.\connect.ps1 -Environment test -ShowEnvironments` | Ver ambientes disponibles |
| `.\pull.ps1 -Environment test` | Descargar TODO el contenido |
| `.\pull-process.ps1 -Environment test -ListProcesses` | Listar procesos locales |
| `.\pull-process.ps1 -Environment test -ProcessName X` | Descargar proceso especifico |
| `.\push.ps1 -Environment test` | Subir cambios |
| `.\packages.ps1 -Environment test` | Listar paquetes |

---

**Creado por Bob - Sistema Universal de Gestion CPQ**