#!/bin/bash
set -e  # ⛔ Si hay un error en cualquier línea del script, el proceso se detiene inmediatamente.
set -u  # 🔒 Tratar variables no definidas como error.
set -o pipefail  # 🚀 Detectar fallos en comandos en tuberías (|).

echo "🟢 [INFO] Iniciando entrypoint de Redis..."

# 📌 **Asignar valores predeterminados si las variables no están definidas**
REDIS_PORT="${REDIS_PORT:-6379}"
REDIS_PASSWORD="${REDIS_PASSWORD:-}"  # Vacío por defecto, solo se usa si se define
REDIS_MAXMEMORY="${REDIS_MAXMEMORY:-256mb}"
REDIS_MAXMEMORY_POLICY="${REDIS_MAXMEMORY_POLICY:-noeviction}"
REDIS_APPENDONLY="${REDIS_APPENDONLY:-no}"

echo "🟢 [INFO] Variables de configuración:"
echo "    🔹 REDIS_PORT: $REDIS_PORT"
echo "    🔹 REDIS_PASSWORD: ${REDIS_PASSWORD:+********}"  # 🔒 Ocultar en logs
echo "    🔹 REDIS_MAXMEMORY: $REDIS_MAXMEMORY"
echo "    🔹 REDIS_MAXMEMORY_POLICY: $REDIS_MAXMEMORY_POLICY"
echo "    🔹 REDIS_APPENDONLY: $REDIS_APPENDONLY"

# 📂 **Verificar si el directorio de configuración de Redis existe**
REDIS_CONF_DIR="/etc/redis"
REDIS_CONF_FILE="$REDIS_CONF_DIR/redis.conf"

if [[ ! -d "$REDIS_CONF_DIR" ]]; then
  echo "⚠️ [WARN] El directorio $REDIS_CONF_DIR no existe. Creándolo..."
  mkdir -p "$REDIS_CONF_DIR"
fi

# 📜 **Generar archivo de configuración de Redis**
echo "🔄 [INFO] Generando configuración en: $REDIS_CONF_FILE"
cat <<EOF > "$REDIS_CONF_FILE"
# Archivo de configuración de Redis generado automáticamente
bind 0.0.0.0
port $REDIS_PORT
maxmemory $REDIS_MAXMEMORY
maxmemory-policy $REDIS_MAXMEMORY_POLICY
appendonly $REDIS_APPENDONLY
EOF

# 🔐 **Configurar contraseña si está definida**
if [[ -n "$REDIS_PASSWORD" ]]; then
  echo "🔐 [INFO] Configurando autenticación de Redis..."
  echo "requirepass $REDIS_PASSWORD" >> "$REDIS_CONF_FILE"
  echo "✅ [INFO] Contraseña de Redis configurada."
else
  echo "⚠️ [WARN] Redis se ejecutará SIN contraseña. Se recomienda configurar `REDIS_PASSWORD` en producción."
fi

echo "✅ [INFO] Configuración finalizada en: $REDIS_CONF_FILE"

# 🚀 **Iniciar Redis con la configuración generada**
echo "🚀 [INFO] Iniciando servidor Redis..."
exec redis-server "$REDIS_CONF_FILE"
