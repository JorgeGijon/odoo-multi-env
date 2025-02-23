#!/bin/bash
set -e  # ⛔ Finaliza el script si ocurre un error

# 🌍 Detectar el entorno desde la variable de entorno ODOO_ENV
case "$ODOO_ENV" in
  "production")
    CONFIG_FILE="/config/odoo_prod.conf"
    echo -e "\n🚀🌍 \033[1;32m Modo PRODUCCIÓN detectado \033[0m 🚀🌍"
    ;;
  "staging")
    CONFIG_FILE="/config/odoo_stage.conf"
    echo -e "\n🛠🌍 \033[1;33m Modo STAGING detectado \033[0m 🛠🌍"
    ;;
  "development")
    CONFIG_FILE="/config/odoo_dev.conf"
    echo -e "\n🛠💻 \033[1;34m Modo DESARROLLO detectado \033[0m 🛠💻"
    ;;
  *)
    echo "❌ ERROR: No se ha definido un entorno válido en ODOO_ENV."
    exit 1
    ;;
esac

# 📜 Generar archivo de configuración dinámicamente
echo "🔄 Generando configuración de Odoo en: $CONFIG_FILE"
cat <<EOF > "$CONFIG_FILE"
[options]
db_host = $DB_HOST
db_name = $DB_NAME
db_user = $DB_USER
db_password = $DB_PASSWORD
http_port = $ODOO_PORT
EOF

# 🔹 Si Redis está habilitado, añadir configuración de caché y sesiones
if [[ -n "$SESSION_REDIS_HOST" && -n "$SESSION_REDIS_PORT" ]]; then
  echo "cache_database = $CACHE_DATABASE" >> "$CONFIG_FILE"
  echo "session_redis_host = $SESSION_REDIS_HOST" >> "$CONFIG_FILE"
  echo "session_redis_port = $SESSION_REDIS_PORT" >> "$CONFIG_FILE"
fi

# 🔹 Configuración especial para Producción (workers y logging)
if [[ "$ODOO_ENV" == "production" ]]; then
  echo "workers = 4" >> "$CONFIG_FILE"
  echo "log_level = info" >> "$CONFIG_FILE"
elif [[ "$ODOO_ENV" == "development" ]]; then
  echo "log_level = debug" >> "$CONFIG_FILE"
fi

echo "✅ Configuración generada correctamente."

# 🛢️ Esperar a que PostgreSQL esté disponible antes de iniciar Odoo
echo "⏳ Esperando a PostgreSQL en $DB_HOST..."
until pg_isready -h "$DB_HOST" -U "$DB_USER" > /dev/null 2>&1; do
  echo "🔄 PostgreSQL aún no está listo, reintentando..."
  sleep 5
done
echo "✅ PostgreSQL disponible, iniciando Odoo..."

# 🚀 Iniciar Odoo con la configuración generada
exec odoo --config "$CONFIG_FILE" --database "$DB_NAME" --db_host "$DB_HOST" --db_user "$DB_USER" --db_password "$DB_PASSWORD"
