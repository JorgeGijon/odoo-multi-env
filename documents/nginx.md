# 🌍 **Guía Completa de Nginx en Odoo Multi-Entorno**

## 🚀 **Introducción**
Nginx es utilizado en este proyecto como un **proxy inverso** para manejar las instancias de Odoo en **Staging** y **Producción**, proporcionando balanceo de carga, redirecciones y soporte para **SSL/TLS** en Producción.

Este documento explica cómo funciona la configuración de **Nginx en Odoo Multi-Entorno**, sus ventajas, limitaciones y mejores prácticas.

---

## 🔄 **Flujo de Trabajo de Nginx en el Proyecto**

1. **Recepción de tráfico HTTP/HTTPS:**
   - En Staging y Producción, Nginx recibe todas las solicitudes web dirigidas a Odoo.

2. **Redirección Automática:**
   - Redirige tráfico HTTP (`http://`) a HTTPS (`https://`) en Producción.
   - En Staging, mantiene HTTP para pruebas y validaciones.

3. **Balanceo y Proxy Reverso:**
   - Para **Staging**, el tráfico es dirigido a `stage-odoo:8069`.
   - Para **Producción**, el tráfico es dirigido a `prod-odoo:8069` con SSL habilitado.

4. **Gestión de Carga y Seguridad:**
   - Protege Odoo de accesos no autorizados.
   - Implementa limitaciones en tamaño de archivos (`client_max_body_size`).

---

## ⚙️ **Configuración de Nginx en `nginx.conf`**

```nginx
worker_processes auto;

# 🔧 Ajustes globales
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    sendfile on;
    keepalive_timeout 65;
    
    # 🔹 Configuración de logs
    access_log /var/log/nginx/access.log;

    # 🔒 Seguridad básica y limitación de buffer
    client_max_body_size 50M;
    proxy_buffering off;

    # 🔄 Mapeo de entornos (Stage y Prod)
    upstream odoo_stage {
        server stage-odoo:8069;
    }
    upstream odoo_prod {
        server prod-odoo:8069;
    }

    # 🌍 Configuración de servidor para Odoo Staging
    server {
        listen 80;
        server_name stage.miempresa.com;

        location / {
            proxy_pass http://odoo_stage;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Host $host;
            proxy_redirect off;
        }
    }

    # 🌍 Configuración de servidor para Odoo Producción con HTTPS
    server {
        listen 80;
        server_name prod.miempresa.com;
        return 301 https://$host$request_uri;  # 🔄 Redirección automática a HTTPS
    }

    server {
        listen 443 ssl;
        server_name prod.miempresa.com;

        ssl_certificate /etc/nginx/certs/fullchain.pem;
        ssl_certificate_key /etc/nginx/certs/privkey.pem;

        location / {
            proxy_pass http://odoo_prod;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Host $host;
            proxy_redirect off;
        }
    }
}
```

---

## ✅ **Ventajas del Uso de Nginx**

✔️ **Manejo eficiente del tráfico web** → Nginx se encarga de distribuir las solicitudes de manera óptima.  
✔️ **Redirección automática HTTP a HTTPS** → Seguridad mejorada en Producción.  
✔️ **Protección contra accesos no autorizados** → Implementa headers y seguridad básica.  
✔️ **Balanceo de carga en entornos escalables** → Si se agregan más instancias, Nginx puede balancear tráfico.  
✔️ **Compatibilidad con certificados SSL** → Permite encriptar tráfico en Producción.  

---

## ❌ **Limitaciones y Consideraciones**

⚠️ **No se usa en Desarrollo** → Solo está activo en Staging y Producción.  
⚠️ **Requiere configuración manual de SSL** → Los certificados deben ubicarse en `/etc/nginx/certs/`.  
⚠️ **Si Nginx falla, Odoo no es accesible en Producción** → Se recomienda monitoreo constante.  
⚠️ **Es necesario abrir puertos 80 y 443** → En firewalls y reglas de red del servidor.  

---

## 🔄 **Mantenimiento y Actualización**

🔹 **Reiniciar Nginx después de cambiar la configuración:**
```sh
docker-compose restart nginx
```

🔹 **Ver logs en tiempo real de Nginx:**
```sh
docker-compose logs -f nginx
```

🔹 **Actualizar certificados SSL (Let's Encrypt):**
```sh
sudo certbot renew
sudo systemctl reload nginx
```

🔹 **Reiniciar Odoo y Nginx en Producción:**
```sh
docker-compose restart odoo nginx
```

---

## 🚀 **Conclusión**
Nginx es una pieza clave en la infraestructura de Odoo en entornos **Staging y Producción**, ofreciendo seguridad, estabilidad y escalabilidad. Se recomienda monitorear su funcionamiento y mantener certificados SSL actualizados para garantizar un acceso seguro.

---

📌 **Autor:** JorgeGR 🚀 | Contribuciones bienvenidas mediante PRs.
