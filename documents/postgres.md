# PostgreSQL - Base de Datos para Odoo

## 📌 Función
PostgreSQL es la base de datos relacional utilizada por Odoo para almacenar toda la información del ERP.  
Se ejecuta como un servicio en Docker y es accedido por Odoo a través de la red del contenedor.

## 🛠 Configuración en `docker-compose.yml`
PostgreSQL está configurado en `docker-compose.yml` como un servicio independiente:

```yaml
services:
  postgres:
    image: postgres:16
    container_name: ${INSTANCE:-prueba}-postgres
    restart: unless-stopped
    environment:
      - POSTGRES_USER=odoo
      - POSTGRES_PASSWORD=odoo_password
      - POSTGRES_DB=odoo
    volumes:
      - ./data/postgres:/var/lib/postgresql/data  # 🔹 Almacena los datos de PostgreSQL
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "odoo"]
      interval: 10s
      retries: 5
    networks:
      - odoo-network
```

## 📌 Configuración en `.env`
El archivo `.env` define las credenciales de la base de datos para cada entorno:

```ini
DB_HOST=prueba-postgres
DB_NAME=odoo
DB_USER=odoo
DB_PASSWORD=odoo_password
```

## 🛠 Variables de Entorno
| **Variable**       | **Descripción**                      | **Valor por Defecto** |
|-------------------|----------------------------------|----------------|
| `POSTGRES_USER`   | Usuario de PostgreSQL           | `odoo` |
| `POSTGRES_PASSWORD` | Contraseña del usuario         | `odoo_password` |
| `POSTGRES_DB`     | Nombre de la base de datos      | `odoo` |
| `DB_HOST`         | Host de PostgreSQL              | `prueba-postgres` |

## 🚀 Comandos Útiles

### 🔍 **Verificar si PostgreSQL está funcionando**
```bash
docker logs prueba-postgres -f
```

### 🔄 **Reiniciar PostgreSQL**
```bash
docker restart prueba-postgres
```

### ✅ **Acceder a la consola de PostgreSQL dentro del contenedor**
```bash
docker exec -it prueba-postgres psql -U odoo -d odoo
```

### 🔎 **Listar bases de datos**
```sql
\l
```

### 🔎 **Listar tablas dentro de la base de datos**
```sql
\dt
```

### 🔧 **Restaurar un backup de PostgreSQL**
```bash
docker exec -i prueba-postgres pg_restore -h prueba-postgres -U odoo -d odoo < backups/backup_nombre.dump
```

## 🔥 **Beneficios de Usar PostgreSQL con Docker**
✔ Se ejecuta de manera aislada en un contenedor seguro.  
✔ Permite persistencia de datos con volúmenes.  
✔ Integración directa con Odoo para un rendimiento óptimo.  

---

## 📌 Conclusión
PostgreSQL es un componente crítico para Odoo, proporcionando un almacenamiento seguro y eficiente para los datos del ERP.
