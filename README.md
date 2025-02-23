# Odoo Multi-Entorno con DebugPy, Redis y PGBackup

Este proyecto gestiona **Odoo en entornos Desarrollo, Staging y Producción** con Docker y Git.

---

## 📌 **Estructura del Proyecto**

```
E:\WEBS\ODOO\Proyectos\odoo-instances\odoo-multi-env│── .gitignore
│── README.md
│── docker-compose.yml
│── docker-compose.override.dev.yml
│── docker-compose.override.stage.yml
│── docker-compose.override.prod.yml
│── .env.dev
│── .env.stage
│── .env.prod
│── Dockerfile.odoo
│── Dockerfile.pgbackup
│── entrypoint_odoo.sh
│── entrypoint_pgbackup.sh
│── entrypoint_redis.sh
│── config/
│   ├── nginx.conf  # 🔹 Archivo de configuración de Nginx
│── addons/         # 🔹 Módulos personalizados
│── odoo-src/       # 🔹 Código fuente de Odoo (montado como volumen)
│── data/           # 💾 Almacena configuraciones y datos
│   ├── config/     # 📜 Aquí se generarán dinámicamente `odoo_dev.conf`, `odoo_prod.conf`, etc
│── backups/
│── documentacion/  # 📚 Carpeta de documentación
│   ├── odoo.md
│   ├── redis.md
│   ├── postgres.md
│   ├── pgbackup.md
│   ├── debugpy.md
│   ├── nginx.md
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