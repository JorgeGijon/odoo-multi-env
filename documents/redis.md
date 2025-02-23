# 🔴 **Guía Completa de Redis en Odoo Multi-Entorno**

## 🚀 **Introducción**
Redis es un sistema de almacenamiento en memoria que se usa en **Odoo Multi-Entorno** para la **gestión de caché** y **almacenamiento de sesiones**.

Se implementa en **todos los entornos** para mejorar el rendimiento, pero tiene un uso más crítico en **Staging y Producción**, donde maneja sesiones de usuario y reduce la carga en PostgreSQL.

Este documento explica su configuración, flujo de trabajo y mejores prácticas.

---

## 🔄 **Flujo de Trabajo de Redis en el Proyecto**

1. **Arranque del Contenedor de Redis:**
   - Se inicia Redis con los valores de configuración definidos en el `.env`.
   - Se ejecuta con persistencia opcional para evitar pérdida de datos en cortes inesperados.

2. **Conexión desde Odoo:**
   - Odoo usa Redis para almacenar sesiones de usuario y mejorar la respuesta del sistema.
   - En Staging y Producción, se configuran caché y sesiones en Redis automáticamente.

3. **Optimización del Rendimiento:**
   - Se configura `maxmemory-policy allkeys-lru` para optimizar la memoria eliminando claves antiguas cuando se llena.
   - Se habilita `appendonly yes` en Producción para garantizar persistencia de datos en caso de reinicio.

4. **Supervisión y Mantenimiento:**
   - Se pueden visualizar métricas de Redis en tiempo real.
   - Se gestionan claves almacenadas para optimizar el rendimiento.

---

## ⚙️ **Configuración de Redis**

### 🔹 **Configuración en `.env` por Entorno**
```ini
# 🔴 Configuración de Redis
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=super_secure_redis_password
REDIS_MAXMEMORY=1gb
REDIS_MAXMEMORY_POLICY=allkeys-lru
REDIS_APPENDONLY=yes
```

### 🔹 **Configuración en `docker-compose.yml`**
```yaml
services:
  redis:
    image: redis:latest
    container_name: ${INSTANCE}-redis
    restart: unless-stopped
    command: redis-server --appendonly ${REDIS_APPENDONLY}
    volumes:
      - ./data/redis:/data
    environment:
      - REDIS_PASSWORD=${REDIS_PASSWORD}
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      retries: 5
    networks:
      - odoo-network
```

---

## ✅ **Ventajas del Uso de Redis**

✔️ **Mejora el rendimiento de Odoo** reduciendo la carga en PostgreSQL.  
✔️ **Manejo eficiente de sesiones de usuario**, especialmente en entornos con alta concurrencia.  
✔️ **Evita bloqueos en la base de datos** al reducir operaciones de lectura/escritura.  
✔️ **Configuración flexible** según el entorno (Dev, Stage, Prod).  
✔️ **Soporte para persistencia de datos** con `appendonly yes`.  

---

## ❌ **Limitaciones y Consideraciones**

⚠️ **El almacenamiento en memoria tiene un límite** → Redis descarta datos si excede el `maxmemory`.  
⚠️ **No es un reemplazo de PostgreSQL** → Se usa solo para caché y sesiones.  
⚠️ **Los datos en Redis pueden perderse en reinicios sin persistencia** → Se recomienda `appendonly yes` en Producción.  
⚠️ **Debe estar correctamente configurado para evitar fugas de memoria** → Se recomienda monitoreo.  

---

## 🔄 **Mantenimiento y Administración de Redis**

🔹 **Verificar si Redis está activo:**
```sh
docker-compose logs -f redis
```

🔹 **Acceder a Redis CLI:**
```sh
docker exec -it ${INSTANCE}-redis redis-cli
```

🔹 **Listar claves almacenadas en Redis:**
```sh
KEYS *
```

🔹 **Ver estadísticas de Redis:**
```sh
INFO
```

🔹 **Eliminar todas las claves almacenadas en Redis (⚠️ solo en Dev/Staging):**
```sh
FLUSHALL
```

🔹 **Reiniciar Redis manualmente:**
```sh
docker-compose restart redis
```

---

## 🚀 **Conclusión**
Redis es un componente clave en la infraestructura de Odoo Multi-Entorno, mejorando la velocidad y escalabilidad del sistema. Se recomienda configurar adecuadamente su memoria y monitorear su uso en entornos de Producción.

---

📌 **Autor:** JorgeGR 🚀 | Contribuciones bienvenidas mediante PRs.

