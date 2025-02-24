#!/usr/bin/env python3
import datetime

# Abre el archivo README.md y actualiza el contenido
with open("README.md", "r", encoding="utf-8") as file:
    content = file.read()

# Actualiza o agrega una sección con la fecha de última actualización
nueva_seccion = f"\n\n## Última actualización\nActualizado el {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n"

# Aquí se puede definir una lógica más compleja para modificar el contenido
if "## Última actualización" in content:
    # Si ya existe, reemplazar esa sección (simplificado)
    partes = content.split("## Última actualización")
    content = partes[0] + nueva_seccion
else:
    content += nueva_seccion

# Escribe el contenido actualizado en el README.md
with open("README.md", "w", encoding="utf-8") as file:
    file.write(content)
