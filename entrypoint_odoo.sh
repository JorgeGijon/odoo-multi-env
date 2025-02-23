#!/bin/bash

# 📌 Entrypoint para Odoo 18 con control de errores, seguridad y configuración dinámica
# Este script gestiona la configuración de Odoo, espera a PostgreSQL y ejecuta Odoo de manera segura

set -e  # ⛔ Si ocurre un error, el script se detiene inmediatamente.
set -u  # 🔒 Tratar variables no definidas como error.
set -o pipefail  # 🚀 Detectar fallos en comandos en tuberías (|).

echo "🟢 [INFO] Iniciando entrypoint de Odoo..."

echo "🟢 [INFO] Variables de entorno cargadas:"
echo "    🔹 ODOO_ENV: ${ODOO_ENV:-undefined}"
echo "    🔹 ODOO_PORT: ${ODOO_PORT:-8069}"
echo "    🔹 PGHOST: ${PGHOST:-postgres}"
echo "    🔹 PGPORT: ${PGPORT:-5432}"
echo "    🔹 PGUSER: ${PGUSER:-odoo}"
echo "    🔹 PGPASSWORD: ${PGPASSWORD:-NOT SET}"
echo "    🔹 PGDATABASE: ${PGDATABASE:-odoo}"
echo "    🔹 SESSION_REDIS_HOST: ${SESSION_REDIS_HOST:-NOT SET}"
echo "    🔹 SESSION_REDIS_PORT: ${SESSION_REDIS_PORT:-NOT SET}"

echo "🔄 [INFO] Verificando conexión con PostgreSQL en: $PGHOST:$PGPORT..."
until pg_isready -h "$PGHOST" -p "$PGPORT" -U "$PGUSER"; do
  echo "🔄 [INFO] PostgreSQL aún no está listo, esperando 5 segundos..."
  sleep 5
done
echo "✅ [INFO] PostgreSQL está disponible."

# 📜 **GENERAR ARCHIVO DE CONFIGURACIÓN PARA ODOO**
CONFIG_FILE="/config/odoo.conf"
cat <<EOF > "$CONFIG_FILE"
[options]
db_host = $PGHOST
db_port = $PGPORT
db_name = $PGDATABASE
db_user = $PGUSER
db_password = $PGPASSWORD
http_port = $ODOO_PORT
EOF

# 🔹 **Configurar Redis como backend de sesiones si está habilitado**
if [[ -n "${SESSION_REDIS_HOST:-}" && -n "${SESSION_REDIS_PORT:-}" ]]; then
  echo "🔴 [INFO] Redis detectado. Configurando caché y sesiones..."
  echo "cache_database = 0" >> "$CONFIG_FILE"
  echo "session_redis_host = $SESSION_REDIS_HOST" >> "$CONFIG_FILE"
  echo "session_redis_port = $SESSION_REDIS_PORT" >> "$CONFIG_FILE"
  echo "✅ [INFO] Redis configurado correctamente en Odoo."
else
  echo "⚠️ [WARN] Redis NO está configurado. Odoo usará almacenamiento de sesiones en la BD."
fi

echo "✅ [INFO] Configuración finalizada en: $CONFIG_FILE"

# 🚀 **EJECUTAR ODOO**
echo "🚀 [INFO] Iniciando Odoo con configuración: $CONFIG_FILE"
exec odoo --config "$CONFIG_FILE"
