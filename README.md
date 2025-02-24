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
---

## 🚀 **Despliegue AUTOMÁTICO con GIT y deploy **

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

## 📦 **Despliegue MANUAL con Docker Compose**

Si prefieres ejecutar los contenedores sin `deploy.sh`, puedes hacerlo manualmente:

### 🔹 **Desplegar en Desarrollo**
```sh
docker-compose -f docker-compose.yml -f docker-compose.override.dev.yml --env-file .env.dev up -d --remove-orphans
```

### 🔹 **Desplegar en Staging**
```sh
docker-compose -f docker-compose.yml -f docker-compose.override.stage.yml --env-file .env.stage up -d --remove-orphans
```

### 🔹 **Desplegar en Producción**
```sh
docker-compose -f docker-compose.yml -f docker-compose.override.prod.yml --env-file .env.prod up -d --remove-orphans
```

---

## 🔧 **Comandos Útiles para Mantenimiento**

### 🔹 **Ver logs en tiempo real**
```sh
docker-compose logs -f odoo
```

### 🔹 **Reiniciar un servicio específico**
```sh
docker-compose restart odoo
```

### 🔹 **Detener todos los contenedores**
```sh
docker-compose down
```

### 🔹 **Eliminar todos los contenedores, volúmenes y redes asociadas**
```sh
docker-compose down -v
```

### 🔹 **Actualizar el código y reiniciar Odoo**
```sh
git pull
./deploy.sh
```

---
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
---

## 🔧 **Workflow** (.github/workflows/update-readme.yml)
```powershell
name: Actualizar README automáticamente

# El workflow se activará en cada push a la rama main y también se puede programar (cron)
on:
  push:
    branches:
      - main
  schedule:
    - cron: '0 0 * * *'  # Se ejecuta diariamente a medianoche (ajusta según necesites)

jobs:
  update-readme:
    runs-on: ubuntu-latest

    steps:
      - name: Clonar el repositorio
        uses: actions/checkout@v3

      - name: Ejecutar script de actualización del README
        run: |
          python update_readme.py

      - name: Configurar Git
        run: |
          git config --local user.email "tu-email@ejemplo.com"
          git config --local user.name "Tu Nombre"

      - name: Commit de cambios en README
        run: |
          git add README.md
          # Si hay cambios, se realiza el commit
          if ! git diff --cached --quiet; then
            git commit -m "Auto-actualización del README [skip ci]"
            git push
          else
            echo "No hay cambios en el README"
          fi
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```
Descripción del Workflow

    Activación del Workflow:
    Se ejecuta en cada push a la rama main y también se programa para que se ejecute diariamente (esto se puede ajustar o quitar según tus necesidades).

    Checkout del Repositorio:
    Se utiliza la acción actions/checkout@v3 para obtener el contenido del repositorio.

    Ejecutar el Script de Actualización:
    Se ejecuta el script update_readme.py (debes crearlo en la raíz o en la ubicación que prefieras). Este script debe contener la lógica para generar o modificar el contenido del README según lo que necesites actualizar automáticamente.

    Configurar Git:
    Se configuran el nombre y correo para que Git pueda crear el commit de forma automática.

    Commit y Push Automático:
    Se añade el archivo README.md y, si hay cambios (se comprueba con git diff --cached --quiet), se realiza el commit con el mensaje "Auto-actualización del README [skip ci]" y se realiza un push. La variable GITHUB_TOKEN (disponible por defecto en los repositorios de GitHub Actions) se utiliza para la autenticación.

Ejemplo del Script update_readme.py

Este es un ejemplo muy básico para ilustrar la idea. Puedes modificarlo para que actualice información dinámica (por ejemplo, fecha, resultados de tests, métricas, etc.):
```powershell
#!/usr/bin/env python3
import datetime

# Abre el archivo README.md y actualiza el contenido
with open("README.md", "r", encoding="utf-8") as file:
    content = file.read()

# Actualiza o agrega una sección con la fecha de última actualización
nueva_seccion = f"\n\n## Última actualización\nActualizado el {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n"

# Aquí se puede definir una lógica más compleja para modificar el contenido
if "## Última actualización" in content:
    # Si ya existe, reemplazar esa sección (simplificado)
    partes = content.split("## Última actualización")
    content = partes[0] + nueva_seccion
else:
    content += nueva_seccion

# Escribe el contenido actualizado en el README.md
with open("README.md", "w", encoding="utf-8") as file:
    file.write(content)
---

📌 **Autor:** JorgeGR 🚀 | Contribuciones bienvenidas mediante PRs.