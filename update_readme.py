#!/usr/bin/env python3
import subprocess
import datetime
import re

def get_commit_count():
    """Obtiene el número total de commits en la rama actual."""
    try:
        result = subprocess.run(
            ["git", "rev-list", "--count", "HEAD"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            check=True
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print("Error obteniendo el número de commits:", e.stderr)
        return "0"

def get_last_commit_date():
    """Obtiene la fecha del último commit (formato YYYY-MM-DD)."""
    try:
        result = subprocess.run(
            ["git", "log", "-1", "--format=%cd", "--date=short"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            check=True
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print("Error obteniendo la fecha del último commit:", e.stderr)
        return "N/A"

def update_readme(content):
    """Actualiza o agrega la sección de Información Dinámica en el README."""
    last_update = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    commit_count = get_commit_count()
    last_commit_date = get_last_commit_date()

    nueva_seccion = f"""
## Información Dinámica

- **Última actualización del README:** {last_update}
- **Número de commits en main:** {commit_count}
- **Fecha del último commit:** {last_commit_date}
"""

    # Si ya existe la sección, reemplázala usando una expresión regular.
    if "## Información Dinámica" in content:
        content = re.sub(r"## Información Dinámica\n(?:.*\n)*", nueva_seccion, content)
    else:
        content += "\n" + nueva_seccion

    return content

def main():
    try:
        with open("README.md", "r", encoding="utf-8") as f:
            content = f.read()
    except FileNotFoundError:
        print("README.md no existe. Se creará uno nuevo.")
        content = "# Proyecto Odoo Multi Env\n"

    updated_content = update_readme(content)

    with open("README.md", "w", encoding="utf-8") as f:
        f.write(updated_content)

    print("README.md actualizado exitosamente.")

if __name__ == "__main__":
    main()
