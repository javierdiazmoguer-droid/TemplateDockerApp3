Param(
    [string]$envFile = ".\env\dev.apachephp.env"
    # Archivo de entorno que contiene todas las variables necesarias para ejecutar el contenedor
)

# Inicializar hash table para almacenar variables de entorno
$envVars = @{}

if (-not (Test-Path $envFile)) {
    Write-Error "Archivo de entorno '$envFile' no encontrado."
    exit 1
}
# Verifica si el archivo de entorno existe; si no, termina el script con error

# Leer el archivo .env y almacenar clave-valor en $envVars
Get-Content $envFile | ForEach-Object {
    if ($_ -match '^\s*([^=]+)=(.*)$') {
        $envVars[$matches[1]] = $matches[2]
    }
}

# Configurar variables locales a partir del hash table
$imageName = $envVars['IMAGE_NAME']
$containerName = $envVars['CONTAINER_NAME'] 
$ip = $envVars['SERVER_IP']
$serverport = $envVars['SERVER_PORT']
$volumepath = $envVars['VOLUME_PATH']
$foldername = $envVars['FOLDER_NAME']
$datavolume = $envVars['DATA_VOLUME']
$datafolder = $envVars['DATA_FOLDER']

$phpinfovolumepath = $envVars['PHPINFO_VOLUME_PATH']
$phpinfofoldername = $envVars['PHPINFO_FOLDER_NAME']

$apachelogpath = $envVars['APACHE_LOG_PATH']
# Todas estas variables se usarán para construir el comando docker run y montar volúmenes

# Crear red Docker si no existe y si todos los parámetros están disponibles
if (
        $envVars['NETWORK_NAME'] -and `
        $envVars['NETWORK_SUBNET'] -and `
        $envVars['NETWORK_SUBNET_GATEWAY'] -and `
        $envVars['SERVER_IP'] -and `
        -not (docker network ls --filter "name=^${envVars['NETWORK_NAME]}$" --format "{{.Name}}")
    ) {
        $networkName = $envVars['NETWORK_NAME']
        $networksubnet = $envVars['NETWORK_SUBNET']
        $networksubnetgateway = $envVars['NETWORK_SUBNET_GATEWAY']
        $networkDriver = $envVars['NETWORK_DRIVER']
        
        Write-Host "Creando red: $networkName"
        docker network create $networkName --driver=$networkDriver --subnet=$networksubnet --gateway=$networksubnetgateway
} else {
        Write-Warning "La red Docker ya existe o no se proporcionaron todos los parámetros necesarios."
}
# Comprueba si la red Docker ya existe; si no, la crea con driver, subnet y gateway especificados

# Eliminar contenedor existente si ya existe
if (docker ps -a --filter "name=^${containerName}$" --format "{{.Names}}" | Select-Object -First 1) {
    Write-Host "Eliminando contenedor existente: $containerName"
    docker stop $containerName 2>$null
    docker rm $containerName 2>$null
}
# Evita conflictos deteniendo y eliminando contenedores con el mismo nombre

# Limpiar contenido de la carpeta de logs de Apache si existe
if (Test-Path $apachelogpath) {
    Write-Host "Limpiando contenido de: $apachelogpath"
    Remove-Item "$apachelogpath\*" -Force -Recurse
}
# Garantiza que los logs antiguos no interfieran con la ejecución actual

# Bloque comentado para copiar archivo de configuración de la aplicación (opcional)
# $ConfigSrc = ".\docker\http\moodle\config-dist.php"
# $ConfigDest = ".\moodle_src\config.php"
# if (Test-Path $ConfigSrc) { Copy-Item ... } else { Write-Warning ... }

# Construir el comando docker run
$dockerCmd = @(
    "docker run -d",
    "--name ${containerName}",
    "-p ${serverport}:80",
    "-v ${phpinfovolumepath}:${phpinfofoldername}",
    "-v ${volumepath}:${foldername}",
    "-v ${datavolume}:${datafolder}",
    "-v ${apachelogpath}:/var/log/apache2",
    "--env-file $envFile",
    "--hostname $containerName",
    "--network $networkName",
    "--ip $ip"
    $imageName
) -join ' '
# -d: Ejecuta en segundo plano
# Montaje de volúmenes: código fuente, PHP info, datos, logs
# --env-file: carga variables de entorno dentro del contenedor
# --network y --ip: asigna IP fija dentro de la red Docker

Write-Host "Ejecutando: $dockerCmd"
Invoke-Expression $dockerCmd
# Muestra y ejecuta el comando docker run construido dinámicamente
# Inicia el contenedor Apache + PHP con todos los parámetros configurados
