#!/bin/bash
set -e  # ⛔ Si hay un error en cualquier línea del script, el proceso se detiene inmediatamente.

echo "🟢 [INFO] Iniciando `entrypoint_odoo.sh` para Odoo..."
echo "🟢 [INFO] Entorno detectado: ${ODOO_ENV}"

# 🌍 **DETECTAR EL ENTORNO SEGÚN `ODOO_ENV`**
# Se revisa la variable `ODOO_ENV` para determinar en qué entorno se ejecuta Odoo.
case "$ODOO_ENV" in
  "production")
    CONFIG_FILE="/config/odoo_prod.conf"  # 📂 Archivo de configuración para Producción
    echo "🟢 [INFO] Modo PRODUCCIÓN detectado. Se usará: $CONFIG_FILE"
    ;;
  "staging")
    CONFIG_FILE="/config/odoo_stage.conf"  # 📂 Archivo de configuración para Staging
    echo "🟡 [INFO] Modo STAGING detectado. Se usará: $CONFIG_FILE"
    ;;
  "development")
    CONFIG_FILE="/config/odoo_dev.conf"  # 📂 Archivo de configuración para Desarrollo
    echo "🔵 [INFO] Modo DESARROLLO detectado. Se usará: $CONFIG_FILE"
    ;;
  *)
    echo "❌ [ERROR] No se ha definido un entorno válido en ODOO_ENV. Abortando."
    exit 1
    ;;
esac

# 📜 **GENERAR ARCHIVO DE CONFIGURACIÓN PARA ODOO**
echo "🔄 [INFO] Generando configuración de Odoo en: $CONFIG_FILE"
cat <<EOF > "$CONFIG_FILE"
[options]
db_host = $DB_HOST
db_name = $DB_NAME
db_user = $DB_USER
db_password = $DB_PASSWORD
http_port = $ODOO_PORT
EOF

echo "✅ [INFO] Configuración base generada."

# 🔹 **CONFIGURACIÓN ADICIONAL DE REDIS (OPCIONAL)**
if [[ -n "$SESSION_REDIS_HOST" && -n "$SESSION_REDIS_PORT" ]]; then
  echo "🔴 [INFO] Redis detectado. Configurando caché y sesiones..."
  echo "cache_database = $CACHE_DATABASE" >> "$CONFIG_FILE"
  echo "session_redis_host = $SESSION_REDIS_HOST" >> "$CONFIG_FILE"
  echo "session_redis_port = $SESSION_REDIS_PORT" >> "$CONFIG_FILE"
  echo "✅ [INFO] Redis configurado correctamente en Odoo."
else
  echo "⚠️ [WARN] Redis NO está configurado. Odoo usará almacenamiento de sesiones en la BD."
fi

# 🔹 **CONFIGURACIÓN ESPECIAL PARA PRODUCCIÓN**
if [[ "$ODOO_ENV" == "production" ]]; then
  echo "⚙️ [INFO] Configuración especial para PRODUCCIÓN..."
  echo "workers = 4" >> "$CONFIG_FILE"
  echo "log_level = info" >> "$CONFIG_FILE"
  echo "✅ [INFO] Optimización de Producción aplicada (workers y logging)."
elif [[ "$ODOO_ENV" == "development" ]]; then
  echo "🛠️ [INFO] Modo Desarrollo: Activando logs detallados."
  echo "log_level = debug" >> "$CONFIG_FILE"
fi

echo "✅ [INFO] Configuración finalizada en: $CONFIG_FILE"
echo "------------------------------------------"

# 🔍 **VERIFICAR SI EL ARCHIVO DE CONFIGURACIÓN SE CREÓ CORRECTAMENTE**
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "❌ [ERROR] Archivo de configuración NO se generó correctamente. Abortando."
  exit 1
else
  echo "✅ [INFO] Archivo de configuración generado correctamente."
fi

# 🛢️ **ESPERAR A QUE POSTGRESQL ESTÉ DISPONIBLE**
echo "⏳ [INFO] Verificando disponibilidad de PostgreSQL en: $DB_HOST..."
until pg_isready -h "$DB_HOST" -U "$DB_USER" > /dev/null 2>&1; do
  echo "🔄 [INFO] PostgreSQL aún no está listo, esperando 5 segundos..."
  sleep 5
done
echo "✅ [INFO] PostgreSQL está disponible. Continuando..."

# 🚀 **EJECUTAR ODOO CON LA CONFIGURACIÓN GENERADA**
echo "🚀 [INFO] Iniciando Odoo con la configuración: $CONFIG_FILE"
exec odoo --config "$CONFIG_FILE" --database "$DB_NAME" --db_host "$DB_HOST" --db_user "$DB_USER" --db_password "$DB_PASSWORD"
