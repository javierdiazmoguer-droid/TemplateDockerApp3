Param(
    [string]$EnvFile = ".\env\dev.apachephp.env",
    # Archivo de entorno que contiene todas las variables necesarias para la construcción
    # Por defecto apunta a env/dev.apachephp.env

    [string]$Dockerfile = "docker/http/apache+php/apache-php.dev.dockerfile",
    # Dockerfile a usar para construir la imagen
    # Puede sobrescribirse al llamar al script

    [string]$Tag = "apachephp:dev"
    # Nombre/etiqueta que se asignará a la imagen Docker resultante
)

if (-not (Test-Path $EnvFile)) {
    Write-Error "Env file '$EnvFile' not found."
    exit 1
}
# Verifica si el archivo de entorno existe; si no, muestra error y termina el script

$lines = Get-Content $EnvFile -ErrorAction Stop
# Lee todas las líneas del archivo de entorno
# -ErrorAction Stop asegura que el script se detenga si hay problema leyendo el archivo

$buildArgs = @()
# Inicializa un array vacío donde se almacenarán los argumentos --build-arg para docker build

foreach ($line in $lines) {
    $line = $line.Trim()
    if (-not $line -or $line.StartsWith('#')) { continue }
    # Ignora líneas vacías o comentarios

    if ($line -notmatch '=') { continue }
    # Ignora líneas que no contengan el signo '='

    $parts = $line -split '=', 2
    $k = $parts[0].Trim()
    $v = $parts[1].Trim()
    # Divide la línea en clave y valor, eliminando espacios alrededor

    if ($v.StartsWith('"') -and $v.EndsWith('"')) { $v = $v.Substring(1, $v.Length - 2) }
    if ($v.StartsWith("'") -and $v.EndsWith("'")) { $v = $v.Substring(1, $v.Length - 2) }
    # Quita comillas simples o dobles si están presentes alrededor del valor

    $buildArgs += '--build-arg'
    $buildArgs += "$k=$v"
    # Añade al array de argumentos para docker build en formato --build-arg KEY=VALUE
}

$argsSTR = @('build', '--no-cache', '-f', $Dockerfile, '-t', $Tag) + $buildArgs + '.'
# Construye el array final de argumentos para ejecutar el comando:
# docker build --no-cache -f <Dockerfile> -t <Tag> --build-arg KEY=VALUE ... .

Write-Host "Ejecutando: docker $($argsSTR -join ' ')" & docker @argsSTR
# Muestra el comando Docker completo en la consola y lo ejecuta

$code = $LASTEXITCODE
if ($code -ne 0) {
    Write-Error "docker build falló con código $code"
    exit $code
}
# Verifica el código de salida del build
# Si es distinto de 0, muestra error y termina el script con el mismo código de error
