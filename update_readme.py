#!/usr/bin/env python3
import subprocess
import datetime
import re

def get_commit_count():
    """Obtiene el número total de commits en la rama actual."""
    result = subprocess.run(["git", "rev-list", "--count", "HEAD"], stdout=subprocess.PIPE, text=True)
    return result.stdout.strip()

def get_last_commit_date():
    """Obtiene la fecha del último commit (en formato YYYY-MM-DD)."""
    result = subprocess.run(["git", "log", "-1", "--format=%cd", "--date=short"], stdout=subprocess.PIPE, text=True)
    return result.stdout.strip()

def update_readme(content):
    """Actualiza o agrega una sección con información dinámica."""
    last_update = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    commit_count = get_commit_count()
    last_commit_date = get_last_commit_date()

    nueva_seccion = f"""
## Información Dinámica

- **Última actualización del README:** {last_update}
- **Número de commits en main:** {commit_count}
- **Fecha del último commit:** {last_commit_date}
"""

    # Si ya existe la sección, reemplazarla
    if "## Información Dinámica" in content:
        content = re.sub(r"## Información Dinámica(.|\n)*", nueva_seccion, content, flags=re.DOTALL)
    else:
        content += "\n" + nueva_seccion
    return content

def main():
    try:
        with open("README.md", "r", encoding="utf-8") as f:
            content = f.read()
    except FileNotFoundError:
        content = ""

    updated_content = update_readme(content)

    with open("README.md", "w", encoding="utf-8") as f:
        f.write(updated_content)

if __name__ == "__main__":
    main()
