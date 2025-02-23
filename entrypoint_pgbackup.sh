#!/bin/bash
set -e

echo "🚀 Iniciando copias de seguridad de PostgreSQL..."

while true; do
  TIMESTAMP=$(date +%Y%m%d_%H%M%S)
  PGPASSWORD=$PGPASSWORD pg_dump -h $PGHOST -U $PGUSER -F c -b -v -f /backups/backup_$TIMESTAMP.dump $PGDATABASE
  echo "✅ Backup realizado: backup_$TIMESTAMP.dump"
  sleep $BACKUP_INTERVAL
done
