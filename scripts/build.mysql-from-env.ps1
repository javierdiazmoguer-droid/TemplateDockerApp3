# Define parameters with default values
param(
    [string]$envFile = ".\env\dev.mysql.env"
    # Archivo de entorno que contiene todas las variables necesarias para la construcción
    # Por defecto apunta a env/dev.mysql.env
)

$envVars = @{}
# Inicializa un hash table para almacenar las variables del archivo .env

if (-not (Test-Path $envFile)) {
    Write-Error "Env file '$envFile' not found."
    exit 1
}
# Verifica que el archivo de entorno exista; si no, muestra error y termina el script

Get-Content $envFile | ForEach-Object {
    if ($_ -match '^\s*([^=]+)=(.*)$') {
        $envVars[$matches[1]] = $matches[2]
    }
}
# Lee cada línea del archivo .env
# - Ignora líneas que no tengan el formato clave=valor
# - Almacena cada clave y valor en el hash table $envVars para usarlo más adelante

$Dockerfile = $envVars['DB_DOCKERFILE']
# Toma la ruta del Dockerfile a usar para construir la imagen de la base de datos

$Tag = $envVars['DB_IMAGE_NAME']
# Toma el nombre/etiqueta que se asignará a la imagen Docker resultante

$buildArgsSTR = @(
    "--build-arg DB_USER=" + $envVars['DB_USER'],
    "--build-arg DB_PASS=" + $envVars['DB_PASS'],
    "--build-arg DB_ROOT_PASS=" + $envVars['DB_ROOT_PASS'],
    "--build-arg DB_DATADIR=" + $envVars['DB_DATADIR'],
    "--build-arg DB_PORT=" + $envVars['DB_PORT'],
    "--build-arg DB_NAME=" + $envVars['DB_NAME'],
    "--build-arg DB_LOG_DIR=" + $envVars['DB_LOG_DIR']
) -join ' '
# Construye la cadena de argumentos para docker build en formato --build-arg KEY=VALUE
# Cada variable del .env se pasa como argumento de construcción

$cmddockerSTR = @('docker build', '--no-cache', '-f', $Dockerfile, '-t', $Tag, $buildArgsSTR, '.') -join ' '
# Construye el comando Docker completo como string:
# docker build --no-cache -f <Dockerfile> -t <Tag> --build-arg ... .

Write-Host "Ejecutando: docker $cmddockerSTR" 
# Muestra el comando Docker que se ejecutará

Invoke-Expression $cmddockerSTR
# Ejecuta el comando Docker construido como expresión de PowerShell

$code = $LASTEXITCODE
if ($code -ne 0) {
    Write-Error "docker build falló con código $code"
    exit $code
}
# Verifica el código de salida del comando Docker
# Si es distinto de 0, muestra error y termina el script con el mismo código
