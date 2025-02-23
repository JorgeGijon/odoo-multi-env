#!/bin/bash
set -e

# 📌 Cargar variables de entorno desde el `.env` correspondiente
if [ -f "/config/.env" ]; then
  export $(grep -v '^#' /config/.env | xargs)
fi

# 🔄 Generar `odoo.conf` expandiendo variables
if [ -f "/config/odoo.conf.tpl" ]; then
  envsubst < /config/odoo.conf.tpl > /config/odoo.conf
fi

# 🚀 Iniciar Odoo con la configuración generada
exec odoo --config /config/odoo.conf
