# Odoo - Plataforma ERP

## 📌 Función
Odoo es el contenedor principal del sistema ERP en este proyecto.  
Se ejecuta junto con PostgreSQL para la base de datos y Redis para mejorar el rendimiento mediante caché y sesiones.

## 🛠 Configuración en `docker-compose.yml`
Odoo está definido como un servicio dentro de `docker-compose.yml`:

```yaml
services:
  odoo:
    build:
      context: .
      dockerfile: Dockerfile.odoo
    env_file:
      - .env
    volumes:
      - ./entrypoint_odoo.sh:/entrypoint.sh:ro
      - ./config/odoo.conf.tpl:/config/odoo.conf.tpl:ro
      - ./addons:/mnt/custom-addons  # 🔹 Módulos personalizados
      - ./odoo-src:/usr/lib/python3/dist-packages/odoo  # 🔹 Código fuente de Odoo
      - ./data:/var/lib/odoo  # 🔹 Datos persistentes
    entrypoint: ["/entrypoint.sh"]
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
```

## 📌 Configuración en `config/odoo.conf.tpl`
El archivo `odoo.conf.tpl` define la configuración de Odoo, que se genera dinámicamente en el **entrypoint**.

```ini
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
```

## 🛠 Variables de Entorno
| **Variable**          | **Descripción**                     | **Valor por Defecto** |
|----------------------|---------------------------------|-----------------|
| `ODOO_PORT`         | Puerto HTTP de Odoo              | `8069` |
| `DB_HOST`           | Host de la base de datos         | `prueba-postgres` |
| `DB_NAME`           | Nombre de la base de datos       | `odoo` |
| `DB_USER`           | Usuario de la base de datos      | `odoo` |
| `DB_PASSWORD`       | Contraseña de la base de datos   | `odoo_password` |
| `CACHE_DATABASE`    | Base de datos para caché         | `odoo_cache` |
| `SESSION_REDIS_HOST`| Host del servidor Redis         | `prueba-redis` |
| `SESSION_REDIS_PORT`| Puerto del servidor Redis       | `6379` |

## 🚀 Comandos Útiles

### 🔍 **Ver logs de Odoo**
```bash
docker logs prueba-odoo -f
```

### 🔄 **Reiniciar Odoo**
```bash
docker restart prueba-odoo
```

### ✅ **Verificar si Odoo está en ejecución**
```bash
curl -I http://localhost:8069
```
Si Odoo está funcionando, la respuesta incluirá **HTTP/1.1 200 OK**.

### 🔧 **Acceder a la consola de Odoo dentro del contenedor**
```bash
docker exec -it prueba-odoo bash
```

## 🔥 **Beneficios de Usar Odoo con Docker**
✔ Permite desarrollar en entornos aislados y reproducibles.  
✔ Facilita la administración y actualización del ERP.  
✔ Se integra con PostgreSQL y Redis para mayor eficiencia.  

---

## 📌 Conclusión
Odoo es el núcleo del sistema, gestionando todas las operaciones del ERP de manera eficiente y optimizada dentro del entorno Docker.
