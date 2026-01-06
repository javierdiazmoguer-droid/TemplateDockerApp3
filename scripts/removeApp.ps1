# Elimina TODOS los submódulos de un repositorio Git
# Ignacio: este script limpia .gitmodules, .git/config, .git/modules y el working tree

Write-Host "Detectando submódulos..." -ForegroundColor Cyan
# Mensaje informativo indicando que se va a detectar submódulos en el repositorio

# 1. Obtener lista de submódulos desde .gitmodules
$gitmodules = ".gitmodules"
# Define la ruta del archivo .gitmodules que contiene los submódulos

if (!(Test-Path $gitmodules)) {
    Write-Host "No existe .gitmodules. No hay submódulos que eliminar." -ForegroundColor Yellow
    exit
}
# Si no existe .gitmodules, termina el script porque no hay submódulos que eliminar

# Leer rutas de submódulos
$submodules = Select-String -Path $gitmodules -Pattern "path = " | ForEach-Object {
    ($_ -split "path = ")[1].Trim()
}
# Busca en .gitmodules todas las líneas con "path = "
# Extrae solo la ruta del submódulo y elimina espacios sobrantes

if ($submodules.Count -eq 0) {
    Write-Host "No se encontraron submódulos en .gitmodules." -ForegroundColor Yellow
    exit
}
# Si no se detectan submódulos, termina el script

Write-Host "Submódulos detectados:" -ForegroundColor Green
$submodules | ForEach-Object { Write-Host " - $_" }
# Lista todos los submódulos detectados en verde

# 2. Eliminar cada submódulo
foreach ($sub in $submodules) {

    Write-Host "`nEliminando submódulo: $sub" -ForegroundColor Cyan
    # Mensaje indicando cuál submódulo se va a eliminar

    # Deinit
    git submodule deinit -f $sub | Out-Null
    # Desinicializa el submódulo para que Git deje de rastrearlo
    # Out-Null evita que se muestre salida innecesaria

    # Eliminar del índice
    git rm -f $sub | Out-Null
    # Elimina el submódulo del índice Git, marcándolo como eliminado

    # Eliminar carpeta física
    if (Test-Path $sub) {
        Remove-Item -Recurse -Force $sub
        Write-Host "Carpeta eliminada: $sub"
    }
    # Borra la carpeta del submódulo en el sistema de archivos

    # Eliminar carpeta interna en .git/modules
    $modulePath = ".git/modules/$sub"
    if (Test-Path $modulePath) {
        Remove-Item -Recurse -Force $modulePath
        Write-Host "Carpeta interna eliminada: $modulePath"
    }
    # Borra la carpeta interna que Git crea para mantener información de submódulos
}

# 3. Eliminar archivo .gitmodules
Remove-Item -Force ".gitmodules"
Write-Host "`nArchivo .gitmodules eliminado." -ForegroundColor Green
# Elimina el archivo que lista los submódulos y muestra confirmación

# 4. Commit final
git add -A
git commit -m "Remove all submodules" | Out-Null
# Añade todos los cambios al índice y realiza un commit que refleja la eliminación
# Out-Null evita mostrar el resultado del commit en consola

Write-Host "`n✅ Todos los submódulos han sido eliminados completamente." -ForegroundColor Green
# Mensaje final confirmando que la limpieza de submódulos se completó correctamente
