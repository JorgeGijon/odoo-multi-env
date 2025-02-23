# Redis - Caché y Sesiones para Odoo

## 📌 Función
Redis se utiliza en este proyecto para mejorar el rendimiento de Odoo al almacenar en caché datos temporales y gestionar sesiones de usuario.

## 🛠 Configuración en `docker-compose.yml`
Redis está definido como un servicio dentro de `docker-compose.yml` y se configura con:
```yaml
services:
  redis:
    image: redis:latest
    container_name: ${INSTANCE:-prueba}-redis
    restart: unless-stopped
    command: redis-server --appendonly yes
    volumes:
      - ./data/redis:/data  # 🔹 Almacena datos de Redis de manera persistente
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      retries: 5
    networks:
      - odoo-network
```
Redis se ejecuta como un servicio independiente dentro de la red `odoo-network` y es accesible desde Odoo.

## 📌 Configuración en Odoo (`config/odoo.conf.tpl`)
Para que Odoo utilice Redis como caché y gestor de sesiones, se deben configurar las siguientes variables en `odoo.conf.tpl`:
```ini
[options]
cache_database = ${CACHE_DATABASE}
session_redis_host = ${SESSION_REDIS_HOST}
session_redis_port = ${SESSION_REDIS_PORT}
```
Las variables se asignan desde los archivos `.env` según el entorno de ejecución.

## 🛠 Variables de Entorno
| **Variable**           | **Descripción**                     | **Valor por Defecto** |
|------------------------|-------------------------------------|-----------------|
| `CACHE_DATABASE`       | Base de datos usada para caché     | `odoo_cache` |
| `SESSION_REDIS_HOST`   | Host del servidor Redis            | `prueba-redis` |
| `SESSION_REDIS_PORT`   | Puerto del servidor Redis          | `6379` |

## 🚀 Comandos Útiles

### 🔍 **Verificar el estado de Redis**
```bash
docker logs prueba-redis -f
```

### 🔄 **Reiniciar Redis**
```bash
docker restart prueba-redis
```

### ✅ **Probar la conexión a Redis desde Odoo**
Para asegurarnos de que Redis está funcionando y Odoo puede conectarse a él, podemos entrar al contenedor de Odoo y ejecutar:
```bash
docker exec -it prueba-odoo bash
redis-cli -h prueba-redis ping
```
Si Redis está operativo, la respuesta será:
```
PONG
```

### 📌 **Eliminar todos los datos de Redis (Usar con precaución)**
Si es necesario limpiar completamente la caché y las sesiones almacenadas en Redis, ejecutar:
```bash
docker exec -it prueba-redis redis-cli FLUSHALL
```

## 🔥 **Beneficios de Usar Redis con Odoo**
✔ Mejora el rendimiento al reducir las consultas a PostgreSQL.  
✔ Permite almacenar sesiones de usuario de forma más eficiente.  
✔ Soporta escalabilidad en entornos con múltiples instancias de Odoo.  

---

## 📌 Conclusión
Redis es un componente esencial para mejorar la velocidad y estabilidad de Odoo, evitando sobrecargar la base de datos con consultas repetitivas y gestionando sesiones de manera optimizada.
