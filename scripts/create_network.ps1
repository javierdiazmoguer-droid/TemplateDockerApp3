# CrearRedDocker.ps1
# Script para crear una red en Docker usando PowerShell

<#
.SYNOPSIS
    Crea una red en Docker con configuración personalizable.
.EXAMPLE
    .\create_network.ps1
    .\create_network.ps1 -NetworkName "MyNetwork" -Driver "bridge"
    .\create_network.ps1 -NetworkName "MyNetwork" -Subnet "192.168.0.0/16" -Gateway "192.168.0.1"
#>
# Bloque de comentarios avanzado de PowerShell
# Proporciona documentación interna que puede ser consultada con Get-Help

param(
    [string]$NetworkName = "MoodleNet",   
    # Nombre de la red Docker a crear (valor por defecto: MoodleNet)

    [string]$Driver = "bridge",               
    # Tipo de driver de red Docker (bridge, host, overlay, etc.)

    [string]$Subnet = "172.25.0.0/16",        
    # Subred opcional para la red Docker, si se desea fijar rango de IPs

    [string]$Gateway = "172.25.0.1"           
    # Gateway opcional para la red Docker
)

Write-Host "Creando red Docker: $NetworkName con driver $Driver..." -ForegroundColor Cyan
# Muestra un mensaje informativo en cian indicando que se está creando la red

# Construir comando dinámico
$command = "docker network create --driver $Driver"
# Inicializa el comando docker network create con el driver seleccionado

if ($Subnet -and $Gateway) {
    $command += " --subnet=$Subnet --gateway=$Gateway"
}
# Si se proporcionan Subnet y Gateway, se añaden al comando para crear una red con IP fija

$command += " $NetworkName"
# Agrega el nombre de la red al comando final

# Ejecutar comando
Invoke-Expression $command
# Ejecuta el comando Docker construido dinámicamente

# Verificar creación
Write-Host "Redes disponibles:" -ForegroundColor Green
# Mensaje en verde indicando que a continuación se listarán las redes Docker

docker network ls
# Lista todas las redes Docker disponibles para confirmar que la nueva red fue creada
