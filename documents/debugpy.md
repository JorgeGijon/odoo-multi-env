# 🐍 **Guía Completa de DebugPy en Odoo Multi-Entorno**

## 🚀 **Introducción**
DebugPy es un depurador para Python que permite conectar un entorno de desarrollo a Odoo para depuración remota. En este proyecto, DebugPy está habilitado en el entorno **Desarrollo (Dev)** para facilitar la detección de errores y optimización del código sin afectar los entornos de **Staging** y **Producción**.

El depurador se ejecuta dentro del contenedor de Odoo y permite conectar herramientas como **Visual Studio Code (VSCode)** o **PyCharm** para depuración interactiva.

---

## 🔄 **Flujo de Trabajo de DebugPy**

1. **Arranque del contenedor de Odoo en modo DebugPy:**
   - En el entorno **Desarrollo**, Odoo inicia con `debugpy` escuchando en el puerto `5678`.
   - El contenedor se ejecuta en modo **espera**, lo que significa que Odoo no inicia hasta que un depurador se conecta.

2. **Conectar un depurador externo:**
   - Desde **VSCode o PyCharm**, se inicia una sesión de depuración remota apuntando al puerto `5678`.
   - Una vez conectado, Odoo se ejecuta y el depurador permite inspeccionar código en tiempo real.

3. **Depuración y edición en vivo:**
   - Se pueden establecer puntos de interrupción (breakpoints).
   - Se inspeccionan variables y el flujo de ejecución del código.
   - Se prueba código sin necesidad de reiniciar todo el entorno.

4. **Finalización de la depuración:**
   - Una vez corregidos los errores, Odoo puede ejecutarse normalmente sin DebugPy.

---

## ⚙️ **Lógica de Configuración de DebugPy**

### 🔹 **Configuración en `docker-compose.override.dev.yml`**
En el entorno de **Desarrollo**, DebugPy está habilitado en el contenedor de Odoo con la siguiente configuración:
```yaml
services:
  odoo:
    ports:
      - "8069:8069"
      - "5678:5678"  # DebugPy
    environment:
      - ODOO_ENV=development
      - DEBUGPY_PORT=5678
    command:
      - "python3"
      - "-m"
      - "debugpy"
      - "--listen"
      - "0.0.0.0:5678"
      - "--wait-for-client"
      - "/usr/bin/odoo"
```

### 🔹 **Configuración en `entrypoint_odoo.sh`**
El script de entrada de Odoo (`entrypoint_odoo.sh`) detecta si DebugPy está habilitado y ejecuta Odoo en modo depuración:
```bash
if [[ "$ODOO_ENV" == "development" ]]; then
  echo "🐍 [DEBUGPY] Habilitando DebugPy en el puerto $DEBUGPY_PORT"
  exec python3 -m debugpy --listen 0.0.0.0:$DEBUGPY_PORT --wait-for-client /usr/bin/odoo
else
  exec odoo
fi
```

---

## 🔧 **Cómo Conectar un Depurador**

### 🔹 **Conectar desde Visual Studio Code (VSCode)**
1. Instalar la extensión **Python** en VSCode.
2. Agregar la siguiente configuración en `.vscode/launch.json`:
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Adjuntar a DebugPy",
            "type": "python",
            "request": "attach",
            "connect": {
                "host": "localhost",
                "port": 5678
            },
            "pathMappings": [
                {
                    "localRoot": "${workspaceFolder}",
                    "remoteRoot": "/usr/bin/odoo"
                }
            ]
        }
    ]
}
```
3. Ejecutar VSCode y seleccionar `Run > Start Debugging` (F5).
4. Una vez conectado, Odoo arrancará y se podrá depurar en tiempo real.

### 🔹 **Conectar desde PyCharm**
1. Ir a `Run > Edit Configurations`.
2. Crear una nueva configuración de **Python Remote Debug**.
3. Configurar el **host** como `localhost` y el **puerto** como `5678`.
4. Iniciar la sesión de depuración y esperar a que Odoo se conecte.

---

## ✅ **Ventajas del Uso de DebugPy**

✔️ **Depuración en tiempo real** sin necesidad de reiniciar Odoo.
✔️ **Compatible con VSCode y PyCharm**.
✔️ **Modo de espera hasta que se conecte un depurador** → Odoo solo arranca cuando el depurador está activo.
✔️ **Permite inspeccionar variables y ejecución del código paso a paso**.
✔️ **Mejora la productividad y reduce el tiempo de desarrollo.**

---

## ❌ **Limitaciones y Consideraciones**

⚠️ **No debe activarse en Producción** → DebugPy introduce latencia y riesgos de seguridad.
⚠️ **Odoo no arrancará hasta que un depurador se conecte** → En desarrollo es útil, pero puede confundir si no se configura bien.
⚠️ **Requiere redirección de puertos** → Asegurar que el puerto `5678` esté expuesto en `docker-compose.override.dev.yml`.

---

## 🔄 **Mantenimiento y Desactivación de DebugPy**

🔹 **Reiniciar Odoo sin DebugPy:**
```sh
docker-compose restart odoo
```

🔹 **Deshabilitar DebugPy y ejecutar Odoo normalmente:**
```yaml
# Eliminar DebugPy del comando en docker-compose.override.dev.yml
command: ["odoo"]
```

🔹 **Eliminar DebugPy y reiniciar contenedores:**
```sh
docker-compose down -v && ./deploy.sh
```

---

## 🚀 **Conclusión**
DebugPy es una herramienta esencial para depurar Odoo en entornos de desarrollo, permitiendo un flujo de trabajo eficiente con VSCode y PyCharm.

Se recomienda su uso exclusivo en **Desarrollo**, asegurando que esté deshabilitado en entornos de **Staging y Producción**.

---

📌 **Autor:** JorgeGR 🚀 | Contribuciones bienvenidas mediante PRs.

