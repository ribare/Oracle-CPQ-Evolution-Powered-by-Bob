# Sistema Universal de Gestion CPQ

Sistema reutilizable y configurable para gestionar multiples ambientes de Oracle CPQ.

## Estructura del Proyecto

```
C:\CPQ\workspace\
├── .cpqtoolkit\              # Configuracion interna del toolkit
├── config\
│   └── environments.json     # Configuracion de ambientes y credenciales
├── lib\
│   └── Load-Config.ps1       # Modulo de carga de configuracion
├── connect.ps1               # Script de conexion universal
├── pull.ps1                  # Descarga contenido completo
├── pull-process.ps1          # Descarga procesos especificos
├── push.ps1                  # Sube contenido a CPQ
├── packages.ps1              # Lista paquetes disponibles
├── GUIA-RAPIDA.md            # Guia rapida de uso
└── README-UNIVERSAL.md       # Documentacion tecnica completa
```

## Inicio Rapido

### 1. Configurar Ambientes

Edita `config/environments.json` con tus ambientes:

```json
{
  "environments": {
    "test": {
      "name": "Test Environment",
      "host": "test.bigmachines.com",
      "protocol": "https",
      "description": "Ambiente de pruebas",
      "download_mode": "all",
      "specific_processes": []
    }
  },
  "credentials": {
    "test": {
      "username": "tu-usuario",
      "password": "tu-contrasena"
    }
  }
}
```

### 2. Conectar

```powershell
.\connect.ps1 -Environment test
```

### 3. Descargar Contenido

**Opcion A: Descargar TODO**
```powershell
.\pull.ps1 -Environment test
```

**Opcion B: Descargar proceso especifico**
```powershell
# Listar procesos disponibles
.\pull-process.ps1 -Environment test -ListProcesses

# Descargar uno especifico
.\pull-process.ps1 -Environment test -ProcessName oraclecpqo_bmClone_1
```

### 4. Subir Cambios

```powershell
.\push.ps1 -Environment test
```

## Comandos Principales

| Comando | Descripcion |
|---------|-------------|
| `.\connect.ps1 -Environment X` | Conectar y validar ambiente |
| `.\connect.ps1 -Environment X -ShowEnvironments` | Ver ambientes disponibles |
| `.\pull.ps1 -Environment X` | Descargar TODO el contenido |
| `.\pull-process.ps1 -Environment X -ListProcesses` | Listar procesos locales |
| `.\pull-process.ps1 -Environment X -ProcessName Y` | Descargar proceso especifico |
| `.\push.ps1 -Environment X` | Subir cambios al ambiente |
| `.\packages.ps1 -Environment X` | Listar paquetes disponibles |

## Modos de Descarga

### Modo "all" - Descargar TODO

```json
"download_mode": "all",
"specific_processes": []
```

Descarga todo el contenido del sitio CPQ:
- Todos los procesos
- Documentos
- Recursos
- Configuraciones

### Modo "specific" - Descargar Solo Procesos Especificos

```json
"download_mode": "specific",
"specific_processes": [
  "oraclecpqo_bmClone_1",
  "metalsaProcess"
]
```

Descarga solo los procesos especificados en la lista.

## Documentacion

- **GUIA-RAPIDA.md** - Guia rapida con ejemplos y flujos de trabajo
- **README-UNIVERSAL.md** - Documentacion tecnica completa

## Requisitos

- Windows 10/11
- PowerShell 5.1 o superior
- Java JDK instalado
- Oracle CPQ ToolKit instalado

## Soporte

Para problemas o preguntas, consulta:
1. GUIA-RAPIDA.md - Seccion "Solucion de Problemas"
2. README-UNIVERSAL.md - Documentacion completa

---

**Creado por Bob - Sistema Universal de Gestion CPQ**
**Version: 1.0**
**Fecha: 2026-05-22**