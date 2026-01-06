# Define parameters with default values
param(
    [string]$envFile = ".\env\dev.mysql.env"
    # Archivo de entorno que contiene todas las variables necesarias para ejecutar el contenedor de base de datos
)

$envVars = @{}
# Inicializa un hash table para almacenar las variables del archivo .env

if (-not (Test-Path $envFile)) {
    Write-Error "Env file '$envFile' not found."
    exit 1
}
# Verifica que el archivo de entorno exista; si no, termina el script con error

# Leer el archivo .env y almacenar clave-valor en $envVars
Get-Content $envFile | ForEach-Object {
    if ($_ -match '^\s*([^=]+)=(.*)$') {
        $envVars[$matches[1]] = $matches[2]
    }
}

# Configurar variables locales a partir del hash table
$containerName = $envVars['DB_CONTAINER_NAME']
#$dbName = $envVars['DB_NAME']
#$dbUSer = $envVars['DB_USER']
#$dbPass = $envVars['DB_PASS']
#$dbRootPass = $envVars['DB_ROOT_PASS']
$dbDataDir = $envVars['DB_DATADIR']
$dbLogDir = $envVars['DB_LOG_DIR']
$port = $envVars['DB_PORT'] 
$imageName = $envVars['DB_IMAGE_NAME']
$networkName = $envVars['DB_NETWORK_NAME']
$ip = $envVars["DB_IP"]
# Variables necesarias para ejecutar el contenedor:
# - nombre del contenedor
# - directorios de datos y logs dentro del contenedor
# - puerto expuesto
# - nombre de la imagen
# - red y IP dentro de la red Docker
# Las líneas comentadas (#) son variables que podrían usarse para inicialización de la base de datos, pero no se usan aquí

# Eliminar contenedor si existe
if (docker ps -a --filter "name=^${containerName}$" --format "{{.Names}}" | Select-Object -First 1) {
    Write-Host "Eliminando contenedor existente: $containerName"
    docker stop $containerName 2>$null
    docker rm $containerName 2>$null
}
# Evita conflictos deteniendo y eliminando contenedores con el mismo nombre

# Construir el comando docker run
$dockerCmd = @(
    "docker run -d",
    "--name $containerName",
    "-p ${port}:${port}",
    "-v .\mysql_data:$dbDataDir",
    "-v .\logs\mysql:$dbLogDir",
    "--env-file $envFile",
    "--hostname $containerName",
    "--network $networkName",
    "--ip $ip"
    $imageName
) -join ' '
# -d: Ejecuta en segundo plano
# -v: monta los volúmenes locales ./mysql_data y ./logs/mysql en las rutas internas del contenedor
# --env-file: carga variables de entorno dentro del contenedor
# --network y --ip: asigna IP fija dentro de la red Docker
# Expone el puerto de la base de datos para conexión externa

Write-Host "Ejecutando: $dockerCmd"
Invoke-Expression $dockerCmd
# Muestra y ejecuta el comando docker run construido dinámicamente
# Inicia el contenedor MySQL/MariaDB con todos los parámetros configurados
