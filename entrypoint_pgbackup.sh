#!/bin/bash

# 📌 Entrypoint para backup automático de PostgreSQL
# Este script ejecuta copias de seguridad periódicas y maneja errores

set -e  # ⛔ Si ocurre un error, el script se detiene inmediatamente.
set -u  # 🔒 Tratar variables no definidas como error.
set -o pipefail  # 🚀 Detectar fallos en comandos en tuberías (|).

echo "🟢 [INFO] Iniciando servicio de backup de PostgreSQL..."

# 🔹 Definir variables de entorno con valores predeterminados
BACKUP_INTERVAL=${BACKUP_INTERVAL:-86400}  # ⏳ Intervalo entre backups en segundos (24h por defecto)
BACKUP_DIR="/backups"
PGHOST=${PGHOST:-postgres}  # 📌 Servidor de PostgreSQL
PGUSER=${PGUSER:-odoo}  # 👤 Usuario de PostgreSQL
PGDATABASE=${PGDATABASE:-odoo}  # 🗄️ Base de datos a respaldar

# 📂 Asegurar que el directorio de backups existe
mkdir -p "$BACKUP_DIR"
chmod -R 777 "$BACKUP_DIR"
echo "🔹 Directorio de backups: $BACKUP_DIR"

# 🔍 **Verificar conexión con PostgreSQL antes de iniciar backups**
echo "⏳ [INFO] Verificando disponibilidad de PostgreSQL en: $PGHOST..."
until pg_isready -h "$PGHOST" -U "$PGUSER" > /dev/null 2>&1; do
  echo "🔄 [INFO] PostgreSQL aún no está listo, esperando 5 segundos..."
  sleep 5
done
echo "✅ [INFO] PostgreSQL está disponible. Procediendo con backups..."

# 🔄 Función para realizar backup
do_backup() {
  TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
  BACKUP_FILE="$BACKUP_DIR/backup_$TIMESTAMP.sql"
  echo "🔄 [INFO] Realizando backup en: $BACKUP_FILE"
  if pg_dumpall -h "$PGHOST" -U "$PGUSER" > "$BACKUP_FILE"; then
    ln -sf "$BACKUP_FILE" "$BACKUP_DIR/latest_backup.sql"
    echo "✅ [INFO] Backup completado con éxito: $BACKUP_FILE"
  else
    echo "❌ [ERROR] Error al realizar el backup."
    exit 1
  fi
}

# 🔁 Ejecutar backups en intervalos definidos
echo "⏳ [INFO] Iniciando ciclo de backups automáticos cada $BACKUP_INTERVAL segundos..."
while true; do
  do_backup
  echo "⏳ [INFO] Siguiente backup en $BACKUP_INTERVAL segundos..."
  sleep "$BACKUP_INTERVAL"
done
