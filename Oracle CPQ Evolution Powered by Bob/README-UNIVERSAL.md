# CPQ ToolKit - Sistema Universal de Gestión

Sistema reutilizable para conectarse y gestionar múltiples ambientes de Oracle CPQ.

## 📋 Tabla de Contenidos

- [Características](#características)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Configuración Inicial](#configuración-inicial)
- [Uso Básico](#uso-básico)
- [Comandos Disponibles](#comandos-disponibles)
- [Gestión de Ambientes](#gestión-de-ambientes)
- [Ejemplos de Uso](#ejemplos-de-uso)

## ✨ Características

- ✅ **Multi-ambiente**: Conecta a diferentes ambientes (test, dev, prod) con un solo comando
- ✅ **Configuración centralizada**: Todas las credenciales y configuraciones en un solo archivo JSON
- ✅ **Reutilizable**: Cambia de ambiente sin modificar scripts
- ✅ **Seguro**: Advertencias especiales para operaciones en producción
- ✅ **Fácil de usar**: Comandos simples y claros

## 📁 Estructura del Proyecto

```
C:\CPQ\workspace\
├── config/
│   └── environments.json          # Configuración de ambientes y credenciales
├── lib/
│   └── Load-Config.ps1            # Módulo de carga de configuración
├── connect.ps1                    # Script de conexión universal
├── pull.ps1                       # Descarga contenido de CPQ
├── push.ps1                       # Sube contenido a CPQ
├── packages.ps1                   # Lista paquetes disponibles
├── commerceAndDocuments/          # Contenido descargado
├── developerTools/                # Herramientas de desarrollo
└── README-UNIVERSAL.md            # Esta documentación
```

## ⚙️ Configuración Inicial

### 1. Editar Configuración de Ambientes

Edita el archivo `config/environments.json`:

```json
{
  "environments": {
    "test": {
      "name": "Accel Alpha Test",
      "host": "accelalphatest.bigmachines.com",
      "protocol": "https",
      "description": "Ambiente de pruebas"
    },
    "dev": {
      "name": "Development",
      "host": "tu-ambiente-dev.bigmachines.com",
      "protocol": "https",
      "description": "Ambiente de desarrollo"
    },
    "prod": {
      "name": "Production",
      "host": "tu-ambiente-prod.bigmachines.com",
      "protocol": "https",
      "description": "Ambiente de producción"
    }
  },
  "credentials": {
    "test": {
      "username": "tu-usuario",
      "password": "tu-contraseña"
    },
    "dev": {
      "username": "tu-usuario",
      "password": "tu-contraseña"
    },
    "prod": {
      "username": "tu-usuario",
      "password": "tu-contraseña"
    }
  }
}
```

### 2. Configurar Rutas de Descarga (OBLIGATORIO)

Cada ambiente debe tener configurado el parámetro `output_path` que indica dónde se descargarán los archivos:

```json
"test": {
  "name": "Accel Alpha Test",
  "host": "accelalphatest.bigmachines.com",
  "protocol": "https",
  "description": "Ambiente de pruebas",
  "download_mode": "all",
  "specific_processes": [],
  "output_path": "C:\\MisProyectos\\CPQ-Test"
}
```

**⚠️ IMPORTANTE:**
- El campo `output_path` es **OBLIGATORIO** para poder descargar contenido
- Los scripts `pull.ps1` y `pull-process.ps1` validarán que esté configurado
- Si intentas descargar sin configurar este campo, recibirás un error
- Usa rutas absolutas (ej: `C:\\MisProyectos\\CPQ-Test`)

### 3. Verificar Rutas del Sistema

Asegúrate de que las rutas en `settings` del archivo JSON sean correctas:

```json
"settings": {
  "java_home": "C:\\Program Files\\Java\\jdk-25.0.3",
  "cpq_toolkit_path": "C:\\CPQ\\CPQToolkit-windows\\CPQToolkit-24.4.0-SNAPSHOT\\bin\\cpq-toolkit.bat",
  "workspace_path": "C:\\CPQ\\workspace"
}
```

## 🚀 Uso Básico

### Ver Ambientes Disponibles

```powershell
.\connect.ps1 -Environment test -ShowEnvironments
```

### Conectar a un Ambiente

```powershell
.\connect.ps1 -Environment test
```

### Descargar Contenido (Pull)

```powershell
.\pull.ps1 -Environment test
```

### Subir Contenido (Push)

```powershell
.\push.ps1 -Environment test
```

### Listar Paquetes

```powershell
.\packages.ps1 -Environment test
```

## 📝 Comandos Disponibles

### `connect.ps1`

Prueba la conexión con un ambiente CPQ.

**Parámetros:**
- `-Environment`: Nombre del ambiente (test, dev, prod)
- `-ShowEnvironments`: Muestra todos los ambientes disponibles

**Ejemplos:**
```powershell
# Conectar a test
.\connect.ps1 -Environment test

# Ver ambientes disponibles
.\connect.ps1 -Environment test -ShowEnvironments
```

### `pull.ps1`

Descarga todo el contenido del sitio CPQ.

**Parámetros:**
- `-Environment`: Nombre del ambiente

**Requisitos:**
- El campo `output_path` debe estar configurado en `config/environments.json`

**Ejemplo:**
```powershell
# Descargar todo el contenido
.\pull.ps1 -Environment test
```

**Nota:** Los archivos se descargarán en la ruta especificada en `output_path` del ambiente.

### `push.ps1`

Sube contenido al sitio CPQ desde el workspace.

**Parámetros:**
- `-Environment`: Nombre del ambiente

**Ejemplo:**
```powershell
# Subir todo el contenido desde el workspace
.\push.ps1 -Environment test
```

**⚠️ Nota:** Al hacer push a producción, se solicitará confirmación adicional.

### `packages.ps1`

Lista todos los paquetes disponibles en el ambiente.

**Parámetros:**
- `-Environment`: Nombre del ambiente

**Ejemplo:**
```powershell
.\packages.ps1 -Environment test
```

## 🌍 Gestión de Ambientes

### Agregar un Nuevo Ambiente

1. Edita `config/environments.json`
2. Agrega el nuevo ambiente en la sección `environments`:

```json
"qa": {
  "name": "Quality Assurance",
  "host": "qa.bigmachines.com",
  "protocol": "https",
  "description": "Ambiente de QA"
}
```

3. Agrega las credenciales en la sección `credentials`:

```json
"qa": {
  "username": "qa-user",
  "password": "qa-password"
}
```

### Cambiar de Ambiente

Simplemente usa el parámetro `-Environment` con el nombre del ambiente deseado:

```powershell
# Trabajar en test
.\connect.ps1 -Environment test
.\pull.ps1 -Environment test

# Cambiar a dev
.\connect.ps1 -Environment dev
.\pull.ps1 -Environment dev

# Cambiar a prod
.\connect.ps1 -Environment prod
.\pull.ps1 -Environment prod
```

## 💡 Ejemplos de Uso

### Flujo Completo: Test → Dev → Prod

```powershell
# 1. Descargar de test
.\pull.ps1 -Environment test

# 2. Hacer cambios locales
# ... editar archivos ...

# 3. Subir a dev para pruebas
.\push.ps1 -Environment dev

# 4. Verificar en dev
.\connect.ps1 -Environment dev

# 5. Si todo está bien, subir a prod
.\push.ps1 -Environment prod
```

### Migrar Contenido entre Ambientes

```powershell
# Descargar de test
.\pull.ps1 -Environment test

# Subir directamente a dev
.\push.ps1 -Environment dev
```

### Listar y Analizar Paquetes

```powershell
# Ver paquetes en test
.\packages.ps1 -Environment test

# Ver paquetes en prod
.\packages.ps1 -Environment prod
```

## 🔒 Seguridad

### Protección de Credenciales

- Las contraseñas se almacenan en `config/environments.json`
- **NO** subas este archivo a repositorios públicos
- Considera usar variables de entorno para credenciales sensibles

### Confirmación en Producción

El script `push.ps1` solicita confirmación adicional cuando se intenta subir a producción:

```
⚠ ADVERTENCIA: Estás a punto de subir cambios a PRODUCCIÓN
¿Estás seguro de continuar? (S/N):
```

## 🛠️ Solución de Problemas

### Error: "Ambiente no encontrado"

Verifica que el nombre del ambiente existe en `config/environments.json`.

```powershell
.\connect.ps1 -Environment test -ShowEnvironments
```

### Error: "Java no encontrado"

Verifica la ruta de Java en `config/environments.json`:

```json
"java_home": "C:\\Program Files\\Java\\jdk-25.0.3"
```

### Error: "CPQ ToolKit no encontrado"

Verifica la ruta del toolkit en `config/environments.json`:

```json
"cpq_toolkit_path": "C:\\CPQ\\CPQToolkit-windows\\CPQToolkit-24.4.0-SNAPSHOT\\bin\\cpq-toolkit.bat"
```

## 📚 Recursos Adicionales

- [Oracle CPQ Documentation](https://docs.oracle.com/en/cloud/saas/cpq-cloud/)
- [CPQ ToolKit Guide](https://docs.oracle.com/en/cloud/saas/cpq-cloud/toolkit/)

## 👨‍💻 Autor

Creado por Bob - Sistema Universal de Gestión CPQ

---

**Última actualización:** 2026-05-22