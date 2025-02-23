#!/bin/bash

# 📌 Entrypoint para Odoo 18 con control de errores, seguridad y configuración dinámica
# Este script gestiona la configuración de Odoo, espera a PostgreSQL y ejecuta Odoo de manera segura.

set -e  # ⛔ Si ocurre un error, el script se detiene inmediatamente.
set -u  # 🔒 Tratar variables no definidas como error.
set -o pipefail  # 🚀 Detectar fallos en comandos en tuberías (|).

echo "🟢 [INFO] Iniciando entrypoint de Odoo..."
echo "🟢 [INFO] Entorno detectado: ${ODOO_ENV:-undefined}"

# 🌍 **DETECTAR EL ENTORNO SEGÚN `ODOO_ENV`**
# Se revisa la variable `ODOO_ENV` para determinar el entorno activo.
case "${ODOO_ENV:-}" in
  "production")
    CONFIG_FILE="/config/odoo_prod.conf"  # 📂 Configuración para Producción
    echo "🟢 [INFO] Modo PRODUCCIÓN detectado. Usando configuración: $CONFIG_FILE"
    ;;
  "staging")
    CONFIG_FILE="/config/odoo_stage.conf"  # 📂 Configuración para Staging
    echo "🟡 [INFO] Modo STAGING detectado. Usando configuración: $CONFIG_FILE"
    ;;
  "development")
    CONFIG_FILE="/config/odoo_dev.conf"  # 📂 Configuración para Desarrollo
    echo "🔵 [INFO] Modo DESARROLLO detectado. Usando configuración: $CONFIG_FILE"
    ;;
  *)
    echo "❌ [ERROR] ODOO_ENV no es válido o no está definido. Abortando."
    exit 1
    ;;
esac

# 📜 **GENERAR ARCHIVO DE CONFIGURACIÓN PARA ODOO**
echo "🔄 [INFO] Generando configuración de Odoo en: $CONFIG_FILE"
cat <<EOF > "$CONFIG_FILE"
[options]
db_host = ${DB_HOST:-postgres}
db_name = ${DB_NAME:-odoo}
db_user = ${DB_USER:-odoo}
db_password = ${DB_PASSWORD:-odoo_password}
http_port = ${ODOO_PORT:-8069}
EOF
echo "✅ [INFO] Configuración base generada."

# 🔹 **CONFIGURACIÓN ADICIONAL DE REDIS (OPCIONAL)**
if [[ -n "${SESSION_REDIS_HOST:-}" && -n "${SESSION_REDIS_PORT:-}" ]]; then
  echo "🔴 [INFO] Redis detectado. Configurando caché y sesiones..."
  cat <<EOF >> "$CONFIG_FILE"
cache_database = ${CACHE_DATABASE:-0}
session_redis_host = ${SESSION_REDIS_HOST}
session_redis_port = ${SESSION_REDIS_PORT}
EOF
  echo "✅ [INFO] Redis configurado correctamente en Odoo."
else
  echo "⚠️ [WARN] Redis NO está configurado. Odoo usará almacenamiento de sesiones en la BD."
fi

# 🔹 **CONFIGURACIÓN ESPECIAL PARA PRODUCCIÓN**
if [[ "$ODOO_ENV" == "production" ]]; then
  echo "⚙️ [INFO] Configuración especial para PRODUCCIÓN..."
  cat <<EOF >> "$CONFIG_FILE"
workers = 4
log_level = info
EOF
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
echo "⏳ [INFO] Verificando disponibilidad de PostgreSQL en: ${DB_HOST:-postgres}..."
until pg_isready -h "${DB_HOST:-postgres}" -U "${DB_USER:-odoo}" > /dev/null 2>&1; do
  echo "🔄 [INFO] PostgreSQL aún no está listo, esperando 5 segundos..."
  sleep 5
done
echo "✅ [INFO] PostgreSQL está disponible. Continuando..."

# 🔹 **VERIFICAR PERMISOS EN DIRECTORIOS CRÍTICOS**
if [[ ! -w /var/lib/odoo ]]; then
  echo "❌ [ERROR] Odoo no tiene permisos de escritura en /var/lib/odoo. Abortando."
  exit 1
fi
if [[ ! -w /mnt/custom-addons ]]; then
  echo "❌ [ERROR] No se puede escribir en /mnt/custom-addons. Verifica permisos."
  exit 1
fi

# 🐍 **EJECUTAR DEBUGPY SI ESTÁ EN MODO DESARROLLO**
if [[ "$ODOO_ENV" == "development" ]]; then
  echo "🐍 [INFO] DebugPy habilitado en el puerto ${DEBUGPY_PORT:-5678}"
  exec python3 -m debugpy --listen 0.0.0.0:${DEBUGPY_PORT:-5678} --wait-for-client /usr/bin/odoo --config "$CONFIG_FILE"
else
  echo "🚀 [INFO] Iniciando Odoo normalmente con la configuración: $CONFIG_FILE"
  exec odoo --config "$CONFIG_FILE"
fi
