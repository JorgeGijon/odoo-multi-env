#!/bin/bash

# 📌 Entrypoint para PGBackup con configuración dinámica
set -e
set -u
set -o pipefail

echo "🛢️ [INFO] Iniciando entrypoint de PGBackup..."

# 📌 **Detectar entorno (por variable de entorno o por nombre del contenedor)**
ODOO_ENV="${ODOO_ENV:-development}"  # Si no está definido, usa 'development' por defecto.

# 📌 **Asignar variables dinámicamente según el entorno detectado**
case "$ODOO_ENV" in
  "development")
    PGHOST="dev-postgres"
    PGPORT=5432
    PGUSER="odoo"
    PGPASSWORD="odoo_password"
    PGDATABASE="odoo_dev"
    BACKUP_INTERVAL=43200
    ;;
  "staging")
    PGHOST="stage-postgres"
    PGPORT=5432
    PGUSER="odoo"
    PGPASSWORD="staging_password"
    PGDATABASE="odoo_stage"
    BACKUP_INTERVAL=86400
    ;;
  "production")
    PGHOST="prod-postgres"
    PGPORT=5432
    PGUSER="odoo"
    PGPASSWORD="prod_password"
    PGDATABASE="odoo_prod"
    BACKUP_INTERVAL=86400
    ;;
  *)
    echo "❌ [ERROR] ODOO_ENV '$ODOO_ENV' no reconocido. Abortando."
    exit 1
    ;;
esac

echo "🟢 [INFO] Variables de entorno cargadas para $ODOO_ENV:"
echo "    🔹 PGHOST: $PGHOST"
echo "    🔹 PGPORT: $PGPORT"
echo "    🔹 PGUSER: $PGUSER"
echo "    🔹 PGPASSWORD: ${PGPASSWORD:+********}"  # 🔒 Ocultar en logs
echo "    🔹 PGDATABASE: $PGDATABASE"
echo "    🔹 BACKUP_INTERVAL: $BACKUP_INTERVAL"

# 📌 **Esperar a que PostgreSQL esté listo**
echo "🔄 [INFO] Verificando conexión con PostgreSQL en: $PGHOST:$PGPORT..."
until pg_isready -h "$PGHOST" -p "$PGPORT" -U "$PGUSER"; do
  echo "🔄 [INFO] PostgreSQL aún no está listo, esperando 5 segundos..."
  sleep 5
done
echo "✅ [INFO] PostgreSQL está disponible."

# 🚀 **Ejecutar Backup**
while true; do
  echo "🛢️ [INFO] Ejecutando backup de PostgreSQL..."
  PGPASSWORD="$PGPASSWORD" pg_dump -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" -F c -f "/backups/backup_$(date +%Y%m%d%H%M%S).dump"
  echo "✅ [INFO] Backup completado. Próximo en $BACKUP_INTERVAL segundos..."
  sleep "$BACKUP_INTERVAL"
done
