#!/bin/sh # Define el intérprete que ejecutará el script dentro del contenedor; se usa shell POSIX ligero

# Inicializar datadir si está vacío
# Encabezado que explica la intención: crear el directorio de datos solo cuando el volumen Docker aún no contiene MySQL

if [ ! -d "${DB_DATADIR}/mysql" ]; then # Comprueba si NO existe la carpeta interna mysql dentro del datadir indicado por variable de entorno
    echo "Inicializando base de datos..." # Muestra mensaje informativo en los logs de Docker para seguir el proceso
    mariadb-install-db --user=${DB_USER} --datadir=${DB_DATADIR} # Ejecuta la herramienta oficial que crea las tablas de sistema con el usuario y ruta configurados
fi # Cierre del bloque condicional de inicialización

# Arrancar MariaDB en segundo plano
# Encabezado para indicar que a continuación se inicia el servicio del motor de base de datos

echo "Arrancando MariaDB..." # Escribe en logs del contenedor que el demonio va a levantarse
mariadbd-safe --user=${DB_USER} --datadir=${DB_DATADIR} & # Inicia MariaDB con parámetros de seguridad como proceso en background para poder seguir ejecutando el script
PID=$! # Guarda el identificador del proceso recién creado para controlarlo más tarde

# Esperar a que el servidor esté listo
# Comentario que introduce una pausa necesaria antes de conectarse como cliente

sleep 10 # Detiene la ejecución 10 segundos permitiendo que el puerto 3306 del contenedor quede disponible

/usr/bin/mariadb -u root <<EOF # Lanza el cliente mariadb autenticado como root y abre un bloque heredoc para enviar varias instrucciones SQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}'; # Cambia la contraseña del usuario root local usando la variable definida en Docker
CREATE DATABASE ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; # Crea la base de datos principal del proyecto con codificación moderna utf8mb4
CREATE USER '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}'; # Genera un usuario nuevo accesible desde cualquier host de la red Docker
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%'; # Concede permisos totales sobre la base creada al usuario de aplicación
FLUSH PRIVILEGES; # Fuerza a MariaDB a recargar la tabla de permisos para que los cambios tengan efecto inmediato
EOF # Finaliza el bloque de comandos SQL enviados al servidor

# Ejecutar todos los scripts SQL en /entrysql
# Encabezado que indica la fase de carga de datos personalizados incluidos por el profesor

if [ -d "/entrypointsql" ]; then # Verifica si existe el directorio que Docker puede montar con scripts adicionales
    for f in /entrypointsql/*.sql; do # Inicia un bucle que recorrerá cada fichero con extensión .sql en esa ruta
        if [ -f "$f" ]; then # Comprueba que el elemento del bucle es realmente un archivo regular
            echo "Ejecutando $f..." # Escribe en logs qué script concreto se va a importar
            /usr/bin/mariadb -u root -p"${DB_ROOT_PASS}" < "$f" # Ejecuta el cliente mariadb como root usando contraseña y redirige el contenido del fichero al servidor
        fi # Cierre de la comprobación de archivo
    done # Cierre del bucle de ejecución múltiple
fi # Cierre del condicional de carpeta de scripts

# Mantener el proceso principal
# Encabezado final para explicar que el contenedor no debe terminar tras inicializar

wait $PID # Bloquea el script hasta que finalice el proceso mariadb iniciado en background, manteniendo vivo el contenedor Docker

