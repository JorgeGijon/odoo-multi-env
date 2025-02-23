# 🛢️ **Guía Completa de PGBackup en Odoo Multi-Entorno**

## 🚀 **Introducción**
PGBackup es el servicio encargado de realizar copias de seguridad automáticas de la base de datos **PostgreSQL** en todos los entornos de Odoo Multi-Entorno (**Desarrollo, Staging y Producción**).

El sistema de backups permite mantener copias de los datos para evitar pérdidas y facilitar restauraciones en caso de fallos.

Este documento explica su flujo de trabajo, configuración y mantenimiento.

---

## 🔄 **Flujo de Trabajo de PGBackup**

1. **Detección del entorno:**
   - En Desarrollo, los backups se ejecutan cada **12 horas**.
   - En Staging y Producción, los backups se ejecutan **cada 24 horas**.

2. **Ejecución del Script de Backup:**
   - `entrypoint_pgbackup.sh` verifica que PostgreSQL esté en ejecución.
   - Se crea un archivo de backup en `/backups/` con formato `backup-YYYYMMDD-HHMM.sql`.
   - El backup se almacena de forma comprimida para optimizar el espacio.

3. **Almacenamiento y Retención:**
   - Los backups más antiguos se eliminan automáticamente después de **7 días** en Producción y Staging.
   - En Desarrollo, solo se conservan **3 días** para evitar consumo excesivo de almacenamiento.

4. **Posibilidad de Restauración Manual:**
   - Si es necesario restaurar, se puede usar `psql` para importar el backup a PostgreSQL.

---

## ⚙️ **Configuración de PGBackup**

### 🔹 **Configuración en `.env`**
Cada entorno define su intervalo de backups y configuración en su archivo `.env`:
```ini
# 🛢️ Configuración de PGBackup
BACKUP_INTERVAL=86400  # Tiempo en segundos entre backups (24 horas en Prod y Stage, 12h en Dev)
PGHOST=postgres
PGUSER=odoo
PGPASSWORD=odoo_secure_password
PGDATABASE=odoo_db
```

### 🔹 **Configuración en `entrypoint_pgbackup.sh`**
El script de backup ejecuta `pg_dump` y almacena los backups en `/backups/`:
```bash
#!/bin/bash
set -e  # Detener script en caso de error

BACKUP_FILE="/backups/backup-$(date +%Y%m%d-%H%M).sql.gz"

echo "🛢️ [INFO] Iniciando backup de PostgreSQL..."
pg_dump -h "$PGHOST" -U "$PGUSER" "$PGDATABASE" | gzip > "$BACKUP_FILE"
echo "✅ [INFO] Backup completado: $BACKUP_FILE"
```

---

## ✅ **Ventajas del Uso de PGBackup**

✔️ **Automatización total de backups** sin intervención manual.
✔️ **Protección ante pérdida de datos** con backups regulares.
✔️ **Gestión eficiente del almacenamiento** con eliminación de backups antiguos.
✔️ **Compatibilidad con todas las versiones de PostgreSQL**.
✔️ **Restauración rápida y sencilla en caso de fallos**.

---

## ❌ **Limitaciones y Consideraciones**

⚠️ **El almacenamiento de backups debe gestionarse adecuadamente** para evitar llenar el disco.  
⚠️ **No sustituye una solución de backup externa** → Se recomienda almacenar backups en un servidor remoto.  
⚠️ **Requiere permisos en PostgreSQL** → El usuario debe tener permisos para `pg_dump`.  
⚠️ **El tiempo de backup puede aumentar con bases de datos grandes** → Se recomienda optimizar la base de datos periódicamente.  

---

## 🔄 **Mantenimiento y Restauración de Backups**

🔹 **Ver lista de backups almacenados:**
```sh
ls -lh /backups/
```

🔹 **Restaurar un backup específico:**
```sh
gunzip -c /backups/backup-YYYYMMDD-HHMM.sql.gz | psql -h "$PGHOST" -U "$PGUSER" "$PGDATABASE"
```

🔹 **Eliminar backups antiguos manualmente:**
```sh
find /backups/ -type f -name "*.sql.gz" -mtime +7 -exec rm {} \;
```

🔹 **Forzar la ejecución de un backup manualmente:**
```sh
./entrypoint_pgbackup.sh
```

---

## 🚀 **Conclusión**
PGBackup es una solución automatizada y eficiente para garantizar la seguridad de los datos en PostgreSQL. Se recomienda mantener copias en servidores remotos y realizar pruebas periódicas de restauración para validar la integridad de los backups.

---

📌 **Autor:** JorgeGR 🚀 | Contribuciones bienvenidas mediante PRs.

