# Odoo Multi-Entorno con DebugPy, Redis y PGBackup

Este proyecto gestiona **Odoo en entornos Desarrollo, Staging y Producción** con Docker y Git.

---

## 📌 **Estructura del Proyecto**

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
│── addons/                        # 📂 Módulos personalizados de Odoo
│── deploy.sh                      # 🚀 Script que detecta la IP y ejecuta el entorno correcto
│── docker-compose.yml              # 📦 Configuración base de Docker (común para todos los entornos)
│── docker-compose.override.dev.yml  # ⚙️ Configuración extra para Desarrollo (Windows)
│── docker-compose.override.prod.yml # ⚙️ Configuración extra para Stage y Producción (Ubuntu)
│── entrypoint_odoo.sh              # 🚀 Script de inicio para Odoo
│── entrypoint_pgbackup.sh          # 🛢️ Script de backups automáticos de PostgreSQL
│── entrypoint_redis.sh             # 🔴 Script de inicio de Redis
│── .env.dev                        # ⚙️ Configuración del entorno Desarrollo
│── .env.stage                      # ⚙️ Configuración del entorno Stage
│── .env.prod                       # ⚙️ Configuración del entorno Producción
│── README.md                       # 📜 Documentación del proyecto
│── documents/                      # 📂 Guías de uso de cada servicio
│   ├── odoo.md                      # 🔹 Guía de Odoo
│   ├── postgres.md                   # 🔹 Guía de PostgreSQL
│   ├── redis.md                      # 🔹 Guía de Redis
│   ├── pgbackup.md                   # 🔹 Guía de copias de seguridad
│   ├── debugpy.md                    # 🔹 Guía de DebugPy para depuración en Dev
│   ├── nginx.md                      # 🔹 Guía de Nginx (proxy inverso)

```

---

## 🚀 **Características**
✔ **DebugPy en Desarrollo**  
✔ **Redis para Caché y Sesiones**  
✔ **PGBackup para copias de seguridad automáticas**  
✔ **Compatibilidad con múltiples proyectos compartiendo contenedores**  
✔ **Documentación completa en [documentacion/](./documentacion/)**  

---

## 📂 **Contenedores Incluidos**

| **Contenedor**  | **Función** | **Uso en Entorno** | **Documentación** |
|----------------|------------|--------------------|----------------|
| **Odoo** | Plataforma ERP principal | Dev, Staging, Prod | [Guía](./documents/odoo.md) |
| **PostgreSQL** | Base de datos | Dev, Staging, Prod | [Guía](./documents/postgres.md) |
| **Redis** | Caché y sesiones | Dev, Staging, Prod | [Guía](./documents/redis.md) |
| **PGBackup** | Copias automáticas de PostgreSQL | Dev, Staging, Prod | [Guía](./documents/pgbackup.md) |
| **DebugPy** | Depuración remota | Dev | [Guía](./documents/debugpy.md) |
| **Nginx (Opcional)** | Proxy inverso con HTTPS | Staging, Prod | [Guía](./documents/nginx.md) |

---

## 🛠 **Comandos Rápidos**

### **1️⃣ Inicializar el Proyecto**
```bash
git clone https://github.com/tu-usuario/odoo-multi-env.git
cd odoo-multi-env
```

### **2️⃣ Ejecutar en Diferentes Entornos**

🔹 **Desarrollo**  
```bash
docker-compose -f docker-compose.yml -f docker-compose.override.dev.yml up -d
```

🔹 **Staging**  
```bash
docker-compose -f docker-compose.yml -f docker-compose.override.stage.yml up -d
```

🔹 **Producción**  
```bash
docker-compose -f docker-compose.yml -f docker-compose.override.prod.yml up -d
```

### **3️⃣ Desplegar Producción con Git**
```bash
git pull origin main
docker-compose -f docker-compose.yml -f docker-compose.override.prod.yml up -d --build
```

---

## 📚 **Documentación**

Cada contenedor tiene su propia documentación detallada en la carpeta [`documentacion/`](./documentacion/).

✅ **Proyecto listo para desarrollo y producción! 🚀**


permisos correctos en PowerShell (Windows en español)

Ejecuta esto en PowerShell como Administrador dentro de la carpeta del proyecto:
```bash
# 📂 Crear directorios si no existen
$folders = @("data\config", "data\odoo", "data\filestore", "data\postgres", "data\redis", "addons")
foreach ($folder in $folders) {
    if (!(Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force
    }
}

# 🛠️ Otorgar permisos de escritura a TODOS los usuarios en español
$folders | ForEach-Object {
    icacls $_ /grant "Todos":F /T /C /Q
}

Write-Host "✅ Permisos asignados correctamente."
```