[options]
db_host = ${DB_HOST}
db_name = ${DB_NAME}
db_user = ${DB_USER}
db_password = ${DB_PASSWORD}
http_port = ${ODOO_PORT}

; Configuración de caché con Redis
cache_database = ${CACHE_DATABASE}
session_redis_host = ${SESSION_REDIS_HOST}
session_redis_port = ${SESSION_REDIS_PORT}

; Configuración de depuración (solo para desarrollo)
% if ODOO_ENV == "development":
log_level = debug
% endif
