# 🐘 **Guía Completa de PostgreSQL en Odoo Multi-Entorno**

## 🚀 **Introducción**
PostgreSQL es la base de datos utilizada en **Odoo Multi-Entorno** para gestionar la información de la plataforma.
Este documento explica su configuración, flujo de trabajo y mejores prácticas para garantizar un rendimiento óptimo y una administración segura.

El sistema soporta tres entornos diferentes:
- **Desarrollo (Dev)** → Base de datos local con menos restricciones para pruebas y depuración.
- **Staging (Stage)** → Réplica de Producción utilizada para validación antes del despliegue final.
- **Producción (Prod)** → Entorno en vivo con configuraciones optimizadas y backups automatizados.

---

## 🔄 **Flujo de Trabajo de PostgreSQL en el Proyecto**

1. **Arranque del Contenedor de PostgreSQL:**
   - Se inicia con los valores configurados en los archivos `.env` correspondientes.
   - Usa volúmenes persistentes para evitar pérdida de datos en reinicios.

2. **Conexión desde Odoo:**
   - Odoo se conecta a PostgreSQL usando las credenciales definidas en cada entorno.
   - Se crean las bases de datos automáticamente si no existen.

3. **Almacenamiento de Datos:**
   - Los datos de PostgreSQL se almacenan en `/data/postgres/`.
   - Se usa un almacenamiento persistente para evitar pérdida de datos.

4. **Backups Automáticos con PGBackup:**
   - Se ejecutan copias de seguridad periódicas en `/backups/`.
   - Se eliminan los backups antiguos para optimizar el almacenamiento.

---

## ⚙️ **Configuración de PostgreSQL**

### 🔹 **Configuración en `.env` por Entorno**
```ini
# 📌 Configuración de PostgreSQL
PGHOST=postgres
PGPORT=5432
PGUSER=odoo
PGPASSWORD=odoo_secure_password
PGDATABASE=odoo_db
```

### 🔹 **Configuración en `docker-compose.yml`**
```yaml
services:
  postgres:
    image: postgres:16
    container_name: ${INSTANCE}-postgres
    restart: unless-stopped
    environment:
      - POSTGRES_USER=$PGUSER
      - POSTGRES_PASSWORD=$PGPASSWORD
      - POSTGRES_DB=$PGDATABASE
    volumes:
      - ./data/postgres:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "$PGUSER"]
      interval: 10s
      retries: 5
    networks:
      - odoo-network
```

---

## ✅ **Ventajas del Uso de PostgreSQL**

✔️ **Base de datos robusta y escalable** con alto rendimiento.  
✔️ **Volúmenes persistentes** para evitar pérdida de datos en reinicios.  
✔️ **Backups automáticos con PGBackup** para seguridad de datos.  
✔️ **Configuración optimizada por entorno** (Dev, Stage, Prod).  
✔️ **Compatibilidad total con Odoo** y sus módulos.  

---

## ❌ **Limitaciones y Consideraciones**

⚠️ **El tamaño de la base de datos debe ser monitoreado** → PostgreSQL puede crecer rápidamente si no se purgan datos antiguos.  
⚠️ **Los backups deben almacenarse externamente** → Se recomienda copiar los backups a un servidor externo periódicamente.  
⚠️ **El rendimiento puede verse afectado si hay poca RAM** → En Producción, se recomienda asignar suficiente memoria al contenedor.  
⚠️ **Requiere permisos correctos en volúmenes** → PostgreSQL necesita acceso a `/var/lib/postgresql/data`.

---

## 🔄 **Mantenimiento y Administración de PostgreSQL**

🔹 **Verificar si PostgreSQL está activo:**
```sh
docker-compose logs -f postgres
```

🔹 **Acceder a la base de datos desde la línea de comandos:**
```sh
docker exec -it ${INSTANCE}-postgres psql -U $PGUSER -d $PGDATABASE
```

🔹 **Listar bases de datos disponibles:**
```sql
\l
```

🔹 **Eliminar una base de datos:**
```sql
DROP DATABASE odoo_db;
```

🔹 **Forzar un backup manual:**
```sh
./entrypoint_pgbackup.sh
```

🔹 **Restaurar un backup:**
```sh
gunzip -c /backups/backup-YYYYMMDD-HHMM.sql.gz | psql -h "$PGHOST" -U "$PGUSER" "$PGDATABASE"
```

---

## 🚀 **Conclusión**
PostgreSQL es una pieza clave en la infraestructura de Odoo Multi-Entorno, ofreciendo escalabilidad, seguridad y compatibilidad total con la plataforma. Se recomienda realizar monitoreo continuo y mantener una estrategia de backups efectiva para evitar pérdida de datos.

---

📌 **Autor:** JorgeGR 🚀 | Contribuciones bienvenidas mediante PRs.

