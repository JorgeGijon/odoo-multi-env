#!/bin/bash

# 📌 Entrypoint para copias de seguridad automáticas de PostgreSQL
# 🛠️ Este script se encarga de generar backups periódicos de la base de datos de Odoo

set -e  # ⛔ Si hay un error, el script se detiene inmediatamente.
set -u  # 🔒 Tratar variables no definidas como error.
set -o pipefail  # 🚀 Detectar fallos en comandos en tuberías (|).

echo "🛢️ [INFO] Iniciando entrypoint de PGBackup..."

# 📌 **Detectar entorno**
ODOO_ENV="${ODOO_ENV:-development}"  # Si no está definido, usar 'development'

# 📌 **Asignar variables según el entorno**
case "$ODOO_ENV" in
  "development")
    PGHOST="dev-postgres"
    PGPORT=5432
    PGUSER="odoo"
    PGPASSWORD="odoo_password"
    PGDATABASE="odoo_dev"
    BACKUP_INTERVAL=43200  # ⏳ Cada 12 horas en desarrollo
    ;;
  "staging")
    PGHOST="stage-postgres"
    PGPORT=5432
    PGUSER="odoo"
    PGPASSWORD="staging_password"
    PGDATABASE="odoo_stage"
    BACKUP_INTERVAL=86400  # ⏳ Cada 24 horas en staging
    ;;
  "production")
    PGHOST="prod-postgres"
    PGPORT=5432
    PGUSER="odoo"
    PGPASSWORD="prod_password"
    PGDATABASE="odoo_prod"
    BACKUP_INTERVAL=86400  # ⏳ Cada 24 horas en producción
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

# 📌 **Crear carpeta de backups si no existe**
BACKUP_DIR="/backups"
mkdir -p "$BACKUP_DIR"
chmod -R 777 "$BACKUP_DIR"

# 📌 **Loop infinito para hacer backups según el intervalo configurado**
while true; do
  TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
  BACKUP_FILE="$BACKUP_DIR/${PGDATABASE}_backup_$TIMESTAMP.sql.gz"

  echo "🛢️ [INFO] Iniciando backup de PostgreSQL: $BACKUP_FILE"
  PGPASSWORD="$PGPASSWORD" pg_dump -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" "$PGDATABASE" | gzip > "$BACKUP_FILE"

  if [[ $? -eq 0 ]]; then
    echo "✅ [INFO] Backup exitoso: $BACKUP_FILE"
  else
    echo "❌ [ERROR] Fallo al crear el backup de PostgreSQL."
  fi

  echo "⏳ [INFO] Esperando $BACKUP_INTERVAL segundos para el próximo backup..."
  sleep "$BACKUP_INTERVAL"
done
