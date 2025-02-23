#!/bin/bash

# 📌 Script de despliegue `deploy.sh`
# Este script detecta el entorno y ejecuta el `docker-compose` adecuado.

set -e  # ⛔ Si hay un error, el script se detiene inmediatamente.
set -u  # 🔒 Tratar variables no definidas como error.
set -o pipefail  # 🚀 Detectar fallos en comandos en tuberías (|).

echo "🟢 [INFO] Iniciando script de despliegue..."

# 🌍 **DETECTAR TIPO DE ENTORNO**
IP_ADDRESS=$(hostname -I | awk '{print $1}')  # 🏠 Detectar la IP local
PUBLIC_IP="$(curl -s ifconfig.me || echo '0.0.0.0')"  # 🌎 Detectar IP pública (fallo seguro)

if [[ "$IP_ADDRESS" =~ ^192\\.168\\. || "$IP_ADDRESS" =~ ^10\\. ]]; then
  ENV_FILE=".env.dev"
  COMPOSE_FILE="docker-compose.override.dev.yml"
  echo "🔵 [INFO] Entorno detectado: Desarrollo (IP Local: $IP_ADDRESS)"
elif [[ "$PUBLIC_IP" != "0.0.0.0" ]]; then
  ENV_FILE=".env.prod"
  COMPOSE_FILE="docker-compose.override.prod.yml"
  echo "🔴 [INFO] Entorno detectado: Producción (IP Pública: $PUBLIC_IP)"
else
  ENV_FILE=".env.stage"
  COMPOSE_FILE="docker-compose.override.stage.yml"
  echo "🟡 [INFO] Entorno detectado: Staging (Sin IP pública detectada)"
fi

# 📂 **VERIFICAR QUE LOS ARCHIVOS EXISTEN**
if [[ ! -f "$ENV_FILE" ]]; then
  echo "❌ [ERROR] Archivo de entorno $ENV_FILE no encontrado. Abortando."
  exit 1
fi
if [[ ! -f "$COMPOSE_FILE" ]]; then
  echo "❌ [ERROR] Archivo docker-compose $COMPOSE_FILE no encontrado. Abortando."
  exit 1
fi

echo "✅ [INFO] Ejecutando Docker con configuración: $COMPOSE_FILE"
docker-compose -f docker-compose.yml -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d --remove-orphans

echo "🚀 [INFO] Despliegue completado con éxito."
