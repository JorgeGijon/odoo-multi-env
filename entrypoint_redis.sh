#!/bin/bash

# 📌 Entrypoint para Redis con configuración dinámica y control de errores
# 🏗️ Se adapta al entorno de Odoo (Development, Staging, Production)

set -e  # ⛔ Si ocurre un error, el script se detiene inmediatamente.
set -u  # 🔒 Tratar variables no definidas como error.
set -o pipefail  # 🚀 Detectar fallos en comandos en tuberías (|).

echo "🔴 [INFO] Iniciando entrypoint de Redis..."

# 📌 **Detectar entorno (`ODOO_ENV`)**
ODOO_ENV="${ODOO_ENV:-development}"  # Si no está definido, usa 'development' por defecto.

# 📌 **Asignar variables según el entorno**
case "$ODOO_ENV" in
  "development")
    INSTANCE="dev"
    REDIS_PORT=6380
    REDIS_PASSWORD=""
    REDIS_MAXMEMORY="256mb"
    REDIS_MAXMEMORY_POLICY="noeviction"
    REDIS_APPENDONLY="no"
    ;;
  "staging")
    INSTANCE="stage"
    REDIS_PORT=6379
    REDIS_PASSWORD=""
    REDIS_MAXMEMORY="512mb"
    REDIS_MAXMEMORY_POLICY="allkeys-lru"
    REDIS_APPENDONLY="yes"
    ;;
  "production")
    INSTANCE="prod"
    REDIS_PORT=6379
    REDIS_PASSWORD="secure_prod_password"
    REDIS_MAXMEMORY="1gb"
    REDIS_MAXMEMORY_POLICY="allkeys-lru"
    REDIS_APPENDONLY="yes"
    ;;
  *)
    echo "❌ [ERROR] ODOO_ENV '$ODOO_ENV' no reconocido. Abortando."
    exit 1
    ;;
esac

echo "🔴 [INFO] Variables de entorno cargadas para $ODOO_ENV:"
echo "    🔹 INSTANCE: $INSTANCE"
echo "    🔹 REDIS_PORT: $REDIS_PORT"
echo "    🔹 REDIS_PASSWORD: ${REDIS_PASSWORD:+********}"  # 🔒 Oculta contraseña en logs
echo "    🔹 REDIS_MAXMEMORY: $REDIS_MAXMEMORY"
echo "    🔹 REDIS_MAXMEMORY_POLICY: $REDIS_MAXMEMORY_POLICY"
echo "    🔹 REDIS_APPENDONLY: $REDIS_APPENDONLY"

# 📌 **Ruta del archivo de configuración de Redis**
REDIS_CONF="/etc/redis/redis.conf"

# 📌 **Generar configuración de Redis**
echo "🔄 [INFO] Creando configuración en: $REDIS_CONF"
cat <<EOF > "$REDIS_CONF"
bind 0.0.0.0
port $REDIS_PORT
maxmemory $REDIS_MAXMEMORY
maxmemory-policy $REDIS_MAXMEMORY_POLICY
appendonly $REDIS_APPENDONLY
EOF

# 📌 **Configurar contraseña de Redis si está definida**
if [[ -n "$REDIS_PASSWORD" ]]; then
  echo "🔐 [INFO] Configurando autenticación de Redis..."
  echo "requirepass $REDIS_PASSWORD" >> "$REDIS_CONF"
  echo "✅ [INFO] Contraseña de Redis configurada."
else
  echo "⚠️ [WARN] Redis se ejecutará **SIN contraseña** en este entorno."
fi

# 📌 **Verificar que el puerto no esté en uso**
echo "🔄 [INFO] Verificando acceso al puerto Redis: $REDIS_PORT..."
if netstat -tulnp | grep -q ":$REDIS_PORT"; then
  echo "✅ [INFO] Puerto $REDIS_PORT está disponible."
else
  echo "❌ [ERROR] No se puede acceder al puerto $REDIS_PORT. Verifica que otro servicio no lo esté usando."
  exit 1
fi

# 🚀 **Iniciar Redis con la configuración generada**
echo "🚀 [INFO] Iniciando servidor Redis con configuración en: $REDIS_CONF"
exec redis-server "$REDIS_CONF"
