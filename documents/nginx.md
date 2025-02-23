# Nginx - Proxy Inverso para Odoo

## 📌 Función
Nginx actúa como un **proxy inverso** para mejorar la seguridad y el rendimiento de Odoo.  
Proporciona funcionalidades como:
✔ Balanceo de carga.  
✔ Cifrado SSL con Let's Encrypt.  
✔ Redirección de tráfico seguro.

## 🛠 Configuración en `docker-compose.override.prod.yml`
En entornos **Staging** y **Producción**, Nginx gestiona las conexiones externas a Odoo.

```yaml
services:
  nginx:
    image: nginx:latest
    container_name: ${INSTANCE:-prueba}-nginx
    restart: unless-stopped
    volumes:
      - ./nginx/conf.d:/etc/nginx/conf.d:ro  # 🔹 Configuración de Nginx
      - ./nginx/ssl:/etc/nginx/ssl  # 🔹 Certificados SSL
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      - odoo
    networks:
      - odoo-network
```

## 📌 Configuración de Nginx para Odoo (`nginx/conf.d/odoo.conf`)
El siguiente archivo configura el proxy inverso para Odoo.

```nginx
server {
    listen 80;
    server_name odoo.example.com;

    location / {
        proxy_pass http://odoo:8069;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

## 🛠 Variables de Entorno
| **Variable**        | **Descripción**                  | **Valor por Defecto** |
|--------------------|--------------------------------|----------------|
| `INSTANCE`        | Nombre del contenedor         | `prueba` |
| `NGINX_PORT_HTTP` | Puerto HTTP                   | `80` |
| `NGINX_PORT_HTTPS`| Puerto HTTPS                  | `443` |

## 🚀 Comandos Útiles

### 🔍 **Ver logs de Nginx**
```bash
docker logs prueba-nginx -f
```

### 🔄 **Reiniciar Nginx**
```bash
docker restart prueba-nginx
```

### ✅ **Probar la conexión a Odoo a través de Nginx**
```bash
curl -I http://localhost
```
Si Nginx está funcionando correctamente, debería responder con un código **200 OK**.

## 🔥 **Beneficios de Usar Nginx**
✔ Protege Odoo de accesos directos a su puerto.  
✔ Permite configurar HTTPS con Let's Encrypt.  
✔ Mejora el rendimiento al manejar múltiples solicitudes simultáneamente.  

---

## 📌 Conclusión
Nginx es un componente clave para entornos de producción, asegurando que Odoo esté accesible de manera segura y eficiente.
