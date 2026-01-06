param(
    [Parameter(Mandatory=$true)]
    [string]$SubmoduleName,
    # Parámetro obligatorio que define el nombre del submódulo a agregar
    # Se usa solo para mensajes de log o control interno

    [Parameter(Mandatory=$true)]
    [string]$GitHubUrl,
    # Parámetro obligatorio que contiene la URL del repositorio GitHub del submódulo

    [Parameter(Mandatory=$true)]
    [string]$DestinationPath
    # Parámetro obligatorio que indica la ruta local donde se agregará el submódulo dentro del proyecto
)

try {
    # Bloque try/catch para capturar errores de ejecución del script

    Write-Host "Adding submodule: $SubmoduleName"
    # Muestra en consola el nombre del submódulo que se va a agregar

    Write-Host "From: $GitHubUrl"
    # Muestra en consola la URL de origen del submódulo

    Write-Host "To: $DestinationPath"
    # Muestra en consola la ruta local de destino

    git submodule add $GitHubUrl $DestinationPath
    # Comando Git que agrega el repositorio remoto como submódulo en la ruta especificada
    # Crea automáticamente la carpeta destino y registra el submódulo en .gitmodules

    if ($LASTEXITCODE -eq 0) {
        # Verifica si el comando anterior se ejecutó correctamente
        Write-Host "Submodule added successfully!" -ForegroundColor Green
        # Mensaje en verde indicando éxito
    } else {
        Write-Host "Error adding submodule" -ForegroundColor Red
        # Mensaje en rojo indicando fallo
        exit 1
        # Sale del script con código de error 1
    }
}
catch {
    # Captura cualquier excepción no controlada durante la ejecución
    Write-Host "Exception: $_" -ForegroundColor Red
    # Muestra la excepción en rojo para identificar problemas
    exit 1
    # Sale del script con código de error 1
}
