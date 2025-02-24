#!/bin/bash

# 📌 Entrypoint para Odoo con configuración dinámica y control de errores
# Este script configura Odoo en función del entorno y espera a PostgreSQL antes de iniciar.

set -e  # ⛔ Si ocurre un error, el script se detiene inmediatamente.
set -u  # 🔒 Tratar variables no definidas como error.
set -o pipefail  # 🚀 Detectar fallos en comandos en tuberías (|).

echo "🟢 [INFO] Iniciando entrypoint de Odoo..."

# 📌 **Detectar entorno (por variable de entorno o por nombre del contenedor)**
ODOO_ENV="${ODOO_ENV:-development}"  # Si no está definido, usa 'development' por defecto.

# 📌 **Asignar variables dinámicamente según el entorno detectado**
case "$ODOO_ENV" in
  "development")
    INSTANCE="dev"
    ODOO_PORT=8069
    DEBUGPY_PORT=5678
    PGHOST="dev-postgres"
    PGPORT=5432
    PGUSER="odoo"
    PGPASSWORD="odoo_password"
    PGDATABASE="odoo_dev"
    REDIS_HOST="dev-redis"
    REDIS_PORT=6380
    BACKUP_INTERVAL=43200
    ;;
  "staging")
    INSTANCE="stage"
    ODOO_PORT=8070
    PGHOST="stage-postgres"
    PGPORT=5432
    PGUSER="odoo"
    PGPASSWORD="staging_password"
    PGDATABASE="odoo_stage"
    REDIS_HOST="stage-redis"
    REDIS_PORT=6379
    BACKUP_INTERVAL=86400
    ;;
  "production")
    INSTANCE="prod"
    ODOO_PORT=8090
    PGHOST="prod-postgres"
    PGPORT=5432
    PGUSER="odoo"
    PGPASSWORD="prod_password"
    PGDATABASE="odoo_prod"
    REDIS_HOST="prod-redis"
    REDIS_PORT=6379
    BACKUP_INTERVAL=86400
    ;;
  *)
    echo "❌ [ERROR] ODOO_ENV '$ODOO_ENV' no reconocido. Abortando."
    exit 1
    ;;
esac

echo "🟢 [INFO] Variables de entorno cargadas para $ODOO_ENV:"
echo "    🔹 INSTANCE: $INSTANCE"
echo "    🔹 ODOO_PORT: $ODOO_PORT"
echo "    🔹 PGHOST: $PGHOST"
echo "    🔹 PGPORT: $PGPORT"
echo "    🔹 PGUSER: $PGUSER"
echo "    🔹 PGPASSWORD: ${PGPASSWORD:+********}"  # 🔒 Ocultar en logs
echo "    🔹 PGDATABASE: $PGDATABASE"
echo "    🔹 REDIS_HOST: $REDIS_HOST"
echo "    🔹 REDIS_PORT: $REDIS_PORT"
echo "    🔹 BACKUP_INTERVAL: $BACKUP_INTERVAL"

# 📌 **Esperar a que PostgreSQL esté listo**
echo "🔄 [INFO] Verificando conexión con PostgreSQL en: $PGHOST:$PGPORT..."
until pg_isready -h "$PGHOST" -p "$PGPORT" -U "$PGUSER"; do
  echo "🔄 [INFO] PostgreSQL aún no está listo, esperando 5 segundos..."
  sleep 5
done
echo "✅ [INFO] PostgreSQL está disponible."

# 📜 **Generar Configuración Dinámica de Odoo**
CONFIG_FILE="/config/odoo.conf"
echo "🔄 [INFO] Generando configuración en: $CONFIG_FILE"
cat <<EOF > "$CONFIG_FILE"
[options]
db_host = $PGHOST
db_port = $PGPORT
db_name = $PGDATABASE
db_user = $PGUSER
db_password = $PGPASSWORD
http_port = $ODOO_PORT
EOF

# 📌 **Configurar Redis si está habilitado**
if [[ -n "$REDIS_HOST" && -n "$REDIS_PORT" ]]; then
  echo "🔴 [INFO] Redis detectado. Configurando caché y sesiones..."
  echo "cache_database = 0" >> "$CONFIG_FILE"
  echo "session_redis_host = $REDIS_HOST" >> "$CONFIG_FILE"
  echo "session_redis_port = $REDIS_PORT" >> "$CONFIG_FILE"
  echo "✅ [INFO] Redis configurado correctamente en Odoo."
else
  echo "⚠️ [WARN] Redis NO está configurado. Odoo usará almacenamiento de sesiones en la BD."
fi

echo "✅ [INFO] Configuración finalizada en: $CONFIG_FILE"

# 🚀 **Ejecutar Odoo**
echo "🚀 [INFO] Iniciando Odoo con configuración: $CONFIG_FILE"
exec odoo --config "$CONFIG_FILE"
