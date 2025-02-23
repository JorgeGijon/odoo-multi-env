# PGBackup - Copias de Seguridad Automáticas de PostgreSQL

## 📌 Función
PGBackup es un servicio diseñado para realizar **copias de seguridad automáticas** de la base de datos PostgreSQL utilizada por Odoo.  
Estas copias permiten restaurar datos en caso de fallos o pérdidas de información.

## 🛠 Configuración en `docker-compose.yml`
PGBackup está configurado en `docker-compose.yml` para ejecutarse de manera automática y guardar los backups en el volumen asignado.

```yaml
services:
  pgbackup:
    build:
      context: .
      dockerfile: Dockerfile.pgbackup
    volumes:
      - ./backups:/backups  # 🔹 Directorio donde se almacenan los backups
    environment:
      - PGHOST=prueba-postgres
      - PGUSER=odoo
      - PGPASSWORD=odoo_password
      - PGDATABASE=odoo
      - BACKUP_INTERVAL=86400  # 🔹 Intervalo de tiempo entre backups (en segundos)
    depends_on:
      postgres:
        condition: service_healthy
```

## 📌 Configuración del `entrypoint_pgbackup.sh`
El `entrypoint_pgbackup.sh` gestiona la ejecución de backups periódicos.

```bash
#!/bin/bash
set -e

echo "🚀 Iniciando copias de seguridad de PostgreSQL..."

while true; do
  TIMESTAMP=$(date +%Y%m%d_%H%M%S)
  PGPASSWORD=$PGPASSWORD pg_dump -h $PGHOST -U $PGUSER -F c -b -v -f /backups/backup_$TIMESTAMP.dump $PGDATABASE
  echo "✅ Backup realizado: backup_$TIMESTAMP.dump"
  sleep $BACKUP_INTERVAL
done
```

## 🛠 Variables de Entorno
| **Variable**       | **Descripción**                          | **Valor por Defecto** |
|-------------------|--------------------------------------|----------------|
| `PGHOST`         | Host de PostgreSQL                   | `prueba-postgres` |
| `PGUSER`         | Usuario de PostgreSQL                | `odoo` |
| `PGPASSWORD`     | Contraseña de PostgreSQL             | `odoo_password` |
| `PGDATABASE`     | Base de datos a respaldar            | `odoo` |
| `BACKUP_INTERVAL`| Intervalo entre backups (en segundos) | `86400` (1 día) |

## 🚀 Comandos Útiles

### 🔍 **Verificar el estado del backup**
```bash
docker logs prueba-pgbackup -f
```

### 🔄 **Forzar un backup manual**
```bash
docker exec prueba-pgbackup /entrypoint_pgbackup.sh
```

### ✅ **Restaurar un backup**
Para restaurar una copia de seguridad, ejecutar:
```bash
docker exec -i prueba-postgres pg_restore -h prueba-postgres -U odoo -d odoo < backups/backup_nombre.dump
```

## 🔥 **Beneficios de Usar PGBackup**
✔ Automatiza las copias de seguridad de PostgreSQL.  
✔ Protege la base de datos ante fallos o pérdidas de datos.  
✔ Permite restauraciones rápidas en caso de emergencia.  

---

## 📌 Conclusión
PGBackup es una solución eficiente para garantizar la seguridad de los datos en Odoo, permitiendo restaurar la base de datos fácilmente en caso de necesidad.
