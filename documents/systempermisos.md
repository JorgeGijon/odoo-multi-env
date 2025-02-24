## 🔒 **Configuración de Permisos en Archivos y Directorios**

### 🔹 **En Ubuntu (Linux)**
```sh
mkdir -p data/config data/odoo data/filestore data/postgres data/redis addons
sudo chown -R 1000:1000 data addons
sudo chmod -R 777 data addons
```

### 🔹 **En Windows (PowerShell)**
```powershell
$folders = @("data\config", "data\odoo", "data\filestore", "data\postgres", "data\redis", "addons")
foreach ($folder in $folders) {
    if (!(Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force
    }
}

$folders | ForEach-Object {
    icacls $_ /grant "Todos":F /T /C /Q
}
Write-Host "✅ Permisos asignados correctamente."
```