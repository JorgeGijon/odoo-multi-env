# 🚀 Odoo Multi-Env - Despliegue Flexible con Docker

## 📌 **Descripción del Proyecto**
Este repositorio proporciona un entorno altamente flexible y seguro para desplegar Odoo en múltiples entornos (**Desarrollo**, **Staging** y **Producción**) utilizando **Docker** y **Docker Compose**. Incluye una configuración optimizada con **PostgreSQL**, **Redis** para caché/sesiones y un sistema automatizado de **backups**.

Además, permite la integración con **Git** para gestionar versiones y despliegues desde un repositorio remoto.

---

## 📂 **Estructura del Proyecto**

```
/odoo-multi-env
│── config/                       # 📂 Configuración de Odoo y Nginx
│   ├── nginx.conf                # 🔹 Configuración de Nginx para manejar Stage y Prod
│── data/                         # 📂 Datos persistentes de Odoo, PostgreSQL y Redis
│   ├── config/                   # 🔹 Archivos de configuración dinámicos
│   ├── odoo_dev/                 # 🔹 Datos de Odoo en desarrollo
│   ├── odoo_stage/               # 🔹 Datos de Odoo en Stage
│   ├── odoo_prod/                # 🔹 Datos de Odoo en Producción
│   ├── filestore/                # 🔹 Archivos adjuntos de Odoo
│   ├── postgres/                 # 🔹 Datos de PostgreSQL (compartido en Stage y Prod)
│   ├── redis/                    # 🔹 Datos de Redis
│── addons/                       # 📂 Módulos personalizados de Odoo
│── deploy.sh                     # 🚀 Script que detecta la IP y ejecuta el entorno correcto
│── docker-compose.yml               # 📦 Configuración base de Docker (común para todos los entornos)
│── docker-compose.override.dev.yml  # ⚙️ Configuración extra para Desarrollo (Windows)
│── docker-compose.override.prod.yml # ⚙️ Configuración extra para Stage y Producción (Ubuntu)
│── entrypoint_odoo.sh            # 🚀 Script de inicio para Odoo
│── entrypoint_pgbackup.sh        # 🛢️ Script de backups automáticos de PostgreSQL
│── entrypoint_redis.sh           # 🔴 Script de inicio de Redis
│── .env.dev                      # ⚙️ Configuración del entorno Desarrollo
│── .env.stage                    # ⚙️ Configuración del entorno Stage
│── .env.prod                     # ⚙️ Configuración del entorno Producción
│── README.md                     # 📜 Documentación del proyecto
│── documents/                    # 📂 Guías de uso de cada servicio
│   ├── odoo.md                     # 🔹 Guía de Odoo
│   ├── postgres.md                 # 🔹 Guía de PostgreSQL
│   ├── redis.md                    # 🔹 Guía de Redis
│   ├── pgbackup.md                 # 🔹 Guía de copias de seguridad
│   ├── debugpy.md                  # 🔹 Guía de DebugPy para depuración en Dev
│   ├── nginx.md                    # 🔹 Guía de Nginx (proxy inverso)
```

---

## 📦 **Contenedores Incluidos**

| **Contenedor**  | **Función** | **Uso en Entorno** | **Documentación** |
|----------------|------------|--------------------|----------------|
| **Odoo** | Plataforma ERP principal | Dev, Staging, Prod | [Guía](./documents/odoo.md) |
| **PostgreSQL** | Base de datos | Dev, Staging, Prod | [Guía](./documents/postgres.md) |
| **Redis** | Caché y sesiones | Dev, Staging, Prod | [Guía](./documents/redis.md) |
| **PGBackup** | Copias automáticas de PostgreSQL | Dev, Staging, Prod | [Guía](./documents/pgbackup.md) |
| **DebugPy** | Depuración remota | Dev | [Guía](./documents/debugpy.md) |
| **Nginx (Opcional)** | Proxy inverso con HTTPS | Staging, Prod | [Guía](./documents/nginx.md) |

---

## 🚀 **Despliegue del Proyecto**

### 🔹 **1. Clonar el repositorio**
```sh
git clone https://github.com/tu-usuario/odoo-multi-env.git
cd odoo-multi-env
```

### 🔹 **2. Configurar variables de entorno**
Edita los archivos `.env.dev`, `.env.stage` o `.env.prod` según el entorno en el que vayas a desplegar.

### 🔹 **3. Ejecutar el despliegue automático**
```sh
chmod +x deploy.sh
./deploy.sh
```
Este script detectará automáticamente el entorno y lanzará el `docker-compose` correcto.

### 🔹 **4. Acceder a Odoo**
- **Desarrollo:** `http://localhost:8069`
- **Staging:** `http://stage.miempresa.com`
- **Producción:** `https://prod.miempresa.com`

---

## 🔒 **Configuración de Permisos en Archivos y Directorios**

### 🔹 **En Ubuntu (Linux)**
```sh
mkdir -p data/config data/odoo data/filestore data/postgres data/redis addons
sudo chown -R 1000:1000 data addons
sudo chmod -R 777 data addons
```

### 🔹 **En Windows (PowerShell)**
```powershell
$folders = @("data\config", "data\odoo", "data\filestore", "data\postgres", "data\redis", "addons")
foreach ($folder in $folders) {
    if (!(Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force
    }
}

$folders | ForEach-Object {
    icacls $_ /grant "Todos":F /T /C /Q
}
Write-Host "✅ Permisos asignados correctamente."
```

