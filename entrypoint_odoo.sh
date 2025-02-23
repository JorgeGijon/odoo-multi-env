#!/bin/bash
set -e  # ⛔ Finaliza el script si ocurre un error

# 🌍 Obtener la IP pública del servidor
PUBLIC_IP=$(curl -s ifconfig.me || curl -s ipinfo.io/ip)

# 🌐 Definir la IP de Producción
PRODUCTION_IP="51.195.139.208"

# 🔍 Detectar entorno (Producción vs Desarrollo)
if [[ "$PUBLIC_IP" == "$PRODUCTION_IP" ]]; then
  ENV_MODE="production"
  echo -e "\n🚀🌍 \033[1;32m Modo PRODUCCIÓN detectado \033[0m 🚀🌍"
  ODOO_CONFIG="/config/odoo_prod.conf"
else
  ENV_MODE="development"
  echo -e "\n🛠💻 \033[1;34m Modo DESARROLLO detectado \033[0m 🛠💻"
  ODOO_CONFIG="/config/odoo_dev.conf"
fi

# 🗄️ Asegurar que el directorio de almacenamiento existe y tiene permisos adecuados
mkdir -p /var/lib/odoo/filestore
chown -R odoo:odoo /var/lib/odoo/filestore || echo "⚠ No se pudo cambiar la propiedad de /var/lib/odoo/filestore."
chmod -R 777 /var/lib/odoo/filestore || echo "⚠ No se pudo cambiar los permisos de /var/lib/odoo/filestore."
echo "✅ Permisos del filestore verificados."

# 🛢️ Esperar a que PostgreSQL esté disponible antes de iniciar Odoo
echo "⏳ Esperando a PostgreSQL en $DB_HOST..."
until pg_isready -h "$DB_HOST" -U "$DB_USER" > /dev/null 2>&1; do
  echo "🔄 PostgreSQL aún no está listo, reintentando..."
  sleep 5
done
echo "✅ PostgreSQL disponible, iniciando Odoo..."

# 🚀 Iniciar Odoo con la configuración adecuada
exec odoo --config "$ODOO_CONFIG" --database "$DB_NAME" --db_host "$DB_HOST" --db_user "$DB_USER" --db_password "$DB_PASSWORD"
