#!/bin/bash
set -e  # ⛔ Si hay un error en cualquier línea del script, el proceso se detiene inmediatamente.

echo "🟢 [INFO] Iniciando `entrypoint_pgbackup.sh` para copias de seguridad de PostgreSQL..."
echo "🟢 [INFO] Variables de entorno cargadas:"
echo "    🔹 PGHOST: $PGHOST"
echo "    🔹 PGDATABASE: $PGDATABASE"
echo "    🔹 PGUSER: $PGUSER"
echo "    🔹 PGBACKUP_DIR: $PGBACKUP_DIR"
echo "    🔹 BACKUP_INTERVAL: ${BACKUP_INTERVAL:-86400} segundos (valor por defecto: 24 horas)"
echo "    🔹 RETENTION_DAYS: ${RETENTION_DAYS:-7} días (valor por defecto: 7 días)"

# 📂 **CREAR DIRECTORIO DE BACKUPS SI NO EXISTE**
if [[ ! -d "$PGBACKUP_DIR" ]]; then
  echo "⚠️ [WARN] Directorio de backups $PGBACKUP_DIR no encontrado. Creándolo..."
  mkdir -p "$PGBACKUP_DIR"
  echo "✅ [INFO] Directorio creado: $PGBACKUP_DIR"
fi

# 🔍 **VERIFICAR CONEXIÓN CON POSTGRESQL ANTES DE EMPEZAR**
echo "⏳ [INFO] Verificando disponibilidad de PostgreSQL en: $PGHOST..."
until pg_isready -h "$PGHOST" -U "$PGUSER" > /dev/null 2>&1; do
  echo "🔄 [INFO] PostgreSQL aún no está listo, esperando 5 segundos..."
  sleep 5
done
echo "✅ [INFO] PostgreSQL está disponible. Comenzando ciclo de backups..."

# 🔁 **BUCLE INFINITO PARA EJECUTAR BACKUPS PERIÓDICAMENTE**
while true; do
  # 🕒 Obtener timestamp actual para el nombre del backup
  TIMESTAMP=$(date +%Y%m%d_%H%M%S)
  BACKUP_FILE="$PGBACKUP_DIR/backup_${TIMESTAMP}.dump"

  echo "🔄 [INFO] Iniciando backup de la base de datos: $PGDATABASE"
  echo "    📂 Archivo destino: $BACKUP_FILE"

  # 🛢️ **EJECUTAR BACKUP CON `pg_dump`**
  if PGPASSWORD=$PGPASSWORD pg_dump -h "$PGHOST" -U "$PGUSER" -F c -b -v -f "$BACKUP_FILE" "$PGDATABASE"; then
    echo "✅ [SUCCESS] Backup completado con éxito: $BACKUP_FILE"
  else
    echo "❌ [ERROR] Fallo al generar el backup. Revisar la conexión con PostgreSQL."
    exit 1
  fi

  # 🗑️ **LIMPIAR BACKUPS ANTIGUOS SEGÚN `RETENTION_DAYS`**
  echo "🧹 [INFO] Eliminando backups más antiguos que $RETENTION_DAYS días..."
  find "$PGBACKUP_DIR" -type f -name "backup_*.dump" -mtime +$RETENTION_DAYS -exec rm -f {} \;

  echo "✅ [INFO] Limpieza de backups antiguos completada."

  # ⏳ **ESPERAR `BACKUP_INTERVAL` SEGUNDOS ANTES DEL SIGUIENTE BACKUP**
  echo "⏳ [INFO] Esperando $BACKUP_INTERVAL segundos antes del próximo backup..."
  sleep "$BACKUP_INTERVAL"
done
