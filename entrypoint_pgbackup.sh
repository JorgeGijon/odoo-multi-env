#!/bin/bash
set -e  # ⛔ Detiene el script si hay un error

echo "🚀 Iniciando servicio de copias de seguridad de PostgreSQL..."

# 📅 Bucle infinito para ejecutar backups periódicamente
while true; do
  TIMESTAMP=$(date +%Y%m%d_%H%M%S)
  echo "🔄 Generando backup: backup_$TIMESTAMP.dump..."
  
  # 🛢️ Realizar el respaldo de la base de datos
  PGPASSWORD=$PGPASSWORD pg_dump -h $PGHOST -U $PGUSER -F c -b -v -f /backups/backup_$TIMESTAMP.dump $PGDATABASE
  
  echo "✅ Backup realizado: backup_$TIMESTAMP.dump"
  
  # ⏳ Esperar el tiempo configurado antes del siguiente backup
  sleep $BACKUP_INTERVAL
done
