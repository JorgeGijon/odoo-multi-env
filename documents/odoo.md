# 📌 **Guía Completa de Odoo en Multi-Entorno con Docker**

## 🚀 **Introducción**
Este documento explica el flujo de trabajo, la lógica y las ventajas e inconvenientes del despliegue de **Odoo Multi-Entorno** utilizando **Docker y Docker Compose**.

Este proyecto permite ejecutar Odoo en tres entornos diferentes:
- **Desarrollo (Dev)** → Para probar y depurar sin afectar entornos productivos.
- **Staging (Stage)** → Replica de Producción para pruebas antes de pasar a producción.
- **Producción (Prod)** → Entorno en vivo con alta disponibilidad.

Cada entorno se gestiona de manera independiente, pero comparte la misma base de código y módulos.

---

## 🔄 **Flujo de Trabajo del Proyecto**

1. **Selección del Entorno:**
   - `deploy.sh` detecta automáticamente si se ejecuta en un entorno **local (Desarrollo)** o en un **servidor (Stage/Prod)**.
   - Carga el archivo `.env` correspondiente (`.env.dev`, `.env.stage` o `.env.prod`).

2. **Arranque de Contenedores:**
   - Se ejecuta `docker-compose` con el archivo base `docker-compose.yml`.
   - Se añade la configuración específica del entorno con `docker-compose.override.<env>.yml`.
   - Se inician los contenedores de **Odoo**, **PostgreSQL**, **Redis**, y **Nginx (en Stage y Prod)**.

3. **Configuración de Odoo:**
   - El `entrypoint_odoo.sh` genera el archivo de configuración dinámico de Odoo.
   - Si está habilitado Redis, Odoo lo usa para la gestión de sesiones.
   - Se conecta a la base de datos PostgreSQL y verifica la estructura de datos.

4. **Gestión de Backups:**
   - `entrypoint_pgbackup.sh` ejecuta backups automáticos de PostgreSQL según la configuración de cada entorno.
   - Los backups se almacenan en el volumen de `backups/`.

5. **Acceso y Administración:**
   - **Desarrollo:** `http://localhost:8069`
   - **Staging:** `http://stage.miempresa.com`
   - **Producción:** `https://prod.miempresa.com`
   - Se accede con las credenciales definidas en la base de datos PostgreSQL.

---

## ⚙️ **Lógica del Proyecto**

### 🔹 **Separación de Configuraciones por Entorno**
Cada entorno tiene su propio archivo `.env`, lo que permite modificar parámetros sin afectar otros entornos.

| **Variable**     | **Desarrollo** | **Staging** | **Producción** |
|----------------|-------------|------------|-------------|
| `ODOO_ENV`     | `development` | `staging`  | `production`  |
| `ODOO_PORT`    | `8069`       | `8070`     | `8090`       |
| `PGHOST`       | `dev-db`     | `stage-db` | `prod-db`    |
| `REDIS_HOST`   | `dev-redis`  | `stage-redis` | `prod-redis` |


### 🔹 **Uso de Docker Compose Override**
Cada entorno tiene su propio `docker-compose.override.<env>.yml`, permitiendo ajustar:
- Puertos de Odoo y PostgreSQL.
- Número de workers en Producción.
- Configuración de Redis en Staging y Producción.


### 🔹 **Depuración con DebugPy en Desarrollo**
- Odoo en desarrollo se ejecuta con `debugpy` en el puerto `5678`.
- Se puede conectar un debugger remoto para depuración en tiempo real.

---

## ✅ **Ventajas del Proyecto**

✔️ **Aislamiento de Entornos** → Desarrollo, Staging y Producción no interfieren entre sí.
✔️ **Automatización de Despliegue** → `deploy.sh` selecciona el entorno automáticamente.
✔️ **Escalabilidad** → Se puede agregar más workers en Producción para mayor rendimiento.
✔️ **Gestión de Sesiones con Redis** → Mejora el rendimiento en Staging y Producción.
✔️ **Backups Automatizados** → PostgreSQL se respalda periódicamente sin intervención manual.
✔️ **Seguridad con Nginx** → SSL en Producción y protección de tráfico en Staging.
✔️ **Facilidad de Desarrollo** → Soporte para DebugPy y reinicio rápido de servicios.

---

## ❌ **Inconvenientes y Consideraciones**

⚠️ **Mayor complejidad en la configuración inicial** → Se deben configurar correctamente los archivos `.env` y `docker-compose.override.*.yml`.
⚠️ **Uso de recursos en Stage/Prod** → En servidores con pocos recursos, PostgreSQL y Odoo pueden requerir optimización.
⚠️ **Gestión de certificados SSL en Producción** → Se requiere configurar correctamente los certificados en `/etc/nginx/certs/`.
⚠️ **Necesidad de acceso a Internet para despliegue con GitHub Actions** → El servidor debe permitir `git pull` para actualizar.

---

## 🔧 **Mantenimiento y Actualización**

🔹 **Actualizar el código y reiniciar Odoo:**
```sh
git pull
./deploy.sh
```

🔹 **Ver logs de Odoo en tiempo real:**
```sh
docker-compose logs -f odoo
```

🔹 **Reiniciar solo el servicio de Odoo:**
```sh
docker-compose restart odoo
```

🔹 **Eliminar y regenerar contenedores:**
```sh
docker-compose down -v && ./deploy.sh
```

---

## 🚀 **Conclusión**
Este proyecto proporciona un entorno robusto para desarrollar, probar y desplegar **Odoo** de manera flexible y escalable. Gracias al uso de Docker y la automatización con GitHub Actions, se simplifica la gestión de versiones y el despliegue en servidores.

Se recomienda probar en Staging antes de pasar cambios a Producción y mantener copias de seguridad actualizadas para evitar pérdida de datos.

---

📌 **Autor:** [Tu Nombre] 🚀 | Contribuciones bienvenidas mediante PRs.

