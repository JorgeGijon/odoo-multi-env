# DebugPy - Depuración Remota para Odoo

## 📌 Función
DebugPy permite depurar Odoo de forma remota utilizando **VS Code** o **PyCharm**, lo que facilita el análisis y solución de errores en el código.

## 🛠 Configuración en `docker-compose.override.dev.yml`
DebugPy solo está habilitado en el entorno de desarrollo (`dev`). Se configura con el siguiente servicio dentro de `docker-compose.override.dev.yml`:
```yaml
services:
  odoo:
    env_file:
      - .env.dev
    ports:
      - "8069:8069"
      - "5678:5678"  # 🔹 Puerto de DebugPy
    environment:
      - ODOO_ENV=development
      - DEBUGPY_PORT=5678
    command: ["python3", "-m", "debugpy", "--listen", "0.0.0.0:5678", "--wait-for-client", "/usr/bin/odoo"]
```

## 📌 Configuración en `.env.dev`
El puerto de depuración se define en el archivo `.env.dev` para facilitar la configuración:
```ini
DEBUGPY_PORT=5678
```

## 🛠 Variables de Entorno
| **Variable**  | **Descripción**               | **Valor por Defecto** |
|--------------|-----------------------------|-----------------|
| `DEBUGPY_PORT` | Puerto donde se ejecuta DebugPy | `5678` |

## 🚀 Cómo Usar DebugPy con **VS Code**
Para depurar Odoo con VS Code:

### 1️⃣ **Agregar la configuración en `.vscode/launch.json`**
En el directorio raíz del proyecto, crear o modificar `.vscode/launch.json` con el siguiente contenido:
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Attach to DebugPy",
            "type": "python",
            "request": "attach",
            "connect": {
                "host": "localhost",
                "port": 5678
            },
            "pathMappings": [
                {
                    "localRoot": "${workspaceFolder}/odoo-src",
                    "remoteRoot": "/usr/lib/python3/dist-packages/odoo"
                }
            ]
        }
    ]
}
```

### 2️⃣ **Ejecutar Odoo en modo depuración**
```bash
docker-compose -f docker-compose.yml -f docker-compose.override.dev.yml up -d
```

### 3️⃣ **Iniciar la depuración en VS Code**
- Abrir **VS Code**.
- Ir a la pestaña **Ejecutar y Depurar** (`Ctrl + Shift + D`).
- Seleccionar la configuración **"Attach to DebugPy"**.
- Iniciar la depuración (`F5`).

Ahora se pueden establecer **puntos de interrupción** en el código y analizar su ejecución en tiempo real.

## 🚀 Cómo Usar DebugPy con **PyCharm**
Para depurar Odoo con PyCharm:

### 1️⃣ **Configurar un nuevo depurador remoto**
- Ir a `Run -> Edit Configurations`.
- Hacer clic en `+` y seleccionar `Python Remote Debug`.
- Configurar:
  - **Host**: `localhost`
  - **Port**: `5678`
  - **Path Mapping**:
    - `Local Path`: `{ruta_local}/odoo-src`
    - `Remote Path`: `/usr/lib/python3/dist-packages/odoo`
- Guardar y ejecutar la configuración.

### 2️⃣ **Ejecutar Odoo en modo depuración**
```bash
docker-compose -f docker-compose.yml -f docker-compose.override.dev.yml up -d
```

### 3️⃣ **Iniciar la depuración en PyCharm**
- Hacer clic en `Debug`.
- Agregar puntos de interrupción y analizar la ejecución del código.

## 🔥 **Beneficios de Usar DebugPy**
✔ Permite depurar Odoo sin necesidad de modificar la imagen del contenedor.  
✔ Se integra con VS Code y PyCharm sin configuración adicional.  
✔ Facilita la detección de errores en desarrollo.  

---

## 📌 Conclusión
DebugPy es una herramienta clave para depurar código en entornos de desarrollo de Odoo sin necesidad de reiniciar o reconstruir los contenedores.
