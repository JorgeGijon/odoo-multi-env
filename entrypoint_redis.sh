#!/bin/bash
set -e

echo "🟢 [INFO] Iniciando Redis con la configuración personalizada..."

# 📂 Verificar si el archivo de configuración existe
REDIS_CONF="/etc/redis/redis.conf"

if [[ ! -f "$REDIS_CONF" ]]; then
  echo "⚠️ [WARN] Archivo de configuración de Redis no encontrado. Creando uno nuevo..."
  cat <<EOF > "$REDIS_CONF"
bind 0.0.0.0
port ${REDIS_PORT:-6379}
maxmemory ${REDIS_MAXMEMORY:-256mb}
maxmemory-policy ${REDIS_MAXMEMORY_POLICY:-noeviction}
appendonly ${REDIS_APPENDONLY:-no}
EOF
  echo "✅ [INFO] Archivo de configuración de Redis generado: $REDIS_CONF"
else
  echo "✅ [INFO] Archivo de configuración de Redis encontrado en: $REDIS_CONF"
fi

# 🔹 **Configurar autenticación si está definida**
if [[ -n "$REDIS_PASSWORD" ]]; then
  echo "🔐 [INFO] Configurando autenticación de Redis..."
  echo "requirepass $REDIS_PASSWORD" >> "$REDIS_CONF"
  echo "✅ [INFO] Contraseña de Redis configurada."
else
  echo "⚠️ [WARN] Redis se ejecutará SIN contraseña. Se recomienda configurar `REDIS_PASSWORD` en producción."
fi

# 🚀 **Ejecutar el servidor Redis**
exec redis-server "$REDIS_CONF"
