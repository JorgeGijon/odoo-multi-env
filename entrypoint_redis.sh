#!/bin/bash

# 📌 Entrypoint para Redis con control de errores, autenticación y configuración dinámica
# Este script gestiona la configuración de Redis y su inicio seguro

set -e  # ⛔ Si ocurre un error, el script se detiene inmediatamente.
set -u  # 🔒 Tratar variables no definidas como error.
set -o pipefail  # 🚀 Detectar fallos en comandos en tuberías (|).

echo "🟢 [INFO] Iniciando entrypoint para el servicio de Redis..."
echo "🟢 [INFO] Variables de entorno cargadas:"
echo "    🔹 REDIS_PORT: ${REDIS_PORT:-6379} (Puerto por defecto: 6379)"
echo "    🔹 REDIS_PASSWORD: ${REDIS_PASSWORD:-NO CONFIGURADO}"
echo "    🔹 REDIS_MAXMEMORY: ${REDIS_MAXMEMORY:-256mb} (Límite por defecto: 256MB)"
echo "    🔹 REDIS_MAXMEMORY_POLICY: ${REDIS_MAXMEMORY_POLICY:-noeviction} (Política de eliminación: Sin eliminación)"
echo "    🔹 REDIS_APPENDONLY: ${REDIS_APPENDONLY:-no} (Persistencia AOF: Desactivada por defecto)"

# 📂 **DEFINIR ARCHIVO DE CONFIGURACIÓN DE REDIS**
REDIS_CONF="/etc/redis/redis.conf"

# 📂 **VERIFICAR SI EXISTE LA CONFIGURACIÓN PERSONALIZADA**
if [[ ! -f "$REDIS_CONF" ]]; then
  echo "⚠️ [WARN] Archivo de configuración de Redis no encontrado en $REDIS_CONF."
  echo "🔄 [INFO] Creando un nuevo archivo de configuración predeterminado..."
  cat <<EOF > "$REDIS_CONF"
# Archivo de configuración de Redis generado automáticamente
bind 0.0.0.0
port $REDIS_PORT
maxmemory $REDIS_MAXMEMORY
maxmemory-policy $REDIS_MAXMEMORY_POLICY
appendonly $REDIS_APPENDONLY
EOF
  echo "✅ [INFO] Archivo de configuración generado en: $REDIS_CONF"
else
  echo "✅ [INFO] Archivo de configuración encontrado en: $REDIS_CONF"
fi

# 🔹 **CONFIGURAR CONTRASEÑA SI ESTÁ DEFINIDA**
if [[ -n "${REDIS_PASSWORD:-}" ]]; then
  echo "🔐 [INFO] Configurando autenticación de Redis..."
  echo "requirepass $REDIS_PASSWORD" >> "$REDIS_CONF"
  echo "✅ [INFO] Contraseña de Redis configurada."
else
  echo "⚠️ [WARN] Redis se ejecutará **SIN contraseña**. Se recomienda configurar `REDIS_PASSWORD` en producción."
fi

# 🔍 **VERIFICAR QUE REDIS PUEDA ACCEDER AL PUERTO CONFIGURADO**
echo "⏳ [INFO] Verificando acceso al puerto Redis: $REDIS_PORT..."
if netstat -tulnp | grep -q ":$REDIS_PORT"; then
  echo "✅ [INFO] Puerto $REDIS_PORT está disponible."
else
  echo "❌ [ERROR] No se puede acceder al puerto $REDIS_PORT. Revisa si otro proceso lo está usando."
  exit 1
fi

# 🧹 **LIMPIEZA DE DATOS (OPCIONAL)**
if [[ "${REDIS_CLEAN_ON_START:-no}" == "yes" ]]; then
  echo "⚠️ [WARN] Eliminando datos previos de Redis..."
  rm -rf /data/*
  echo "✅ [INFO] Datos antiguos eliminados."
fi

# 🔁 **INICIAR SERVIDOR REDIS CON LA CONFIGURACIÓN GENERADA**
echo "🚀 [INFO] Iniciando servidor Redis con configuración en: $REDIS_CONF"
exec redis-server "$REDIS_CONF"
