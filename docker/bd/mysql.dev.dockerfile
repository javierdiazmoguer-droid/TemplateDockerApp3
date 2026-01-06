FROM alpine:latest
# Define la imagen base del contenedor; Alpine es una distribución Linux mínima y ligera ideal para virtualización

# Variables de entorno configurables
# Encabezado que introduce argumentos de construcción que podrán ser sobrescritos al hacer docker build

ARG DB_PORT=${DB_PORT} \
# Declara un argumento llamado DB_PORT tomando por defecto el valor de la variable externa del mismo nombre

    DB_USER=${DB_USER} \
# Declara argumento DB_USER que contendrá el nombre del usuario del servicio MariaDB dentro del contenedor

    DB_PASS=${DB_PASS} \
# Declara argumento DB_PASS para la contraseña del usuario de aplicación

    DB_ROOT_PASS=${DB_ROOT_PASS} \
# Declara argumento DB_ROOT_PASS destinado a la contraseña del usuario root del motor de base de datos

    DB_NAME=${DB_NAME} \
# Declara argumento DB_NAME con el nombre de la base de datos principal del proyecto

    DB_DATADIR=${DB_DATADIR} \
# Declara argumento DB_DATADIR que indicará la ruta del volumen donde se almacenarán los datos persistentes

    DB_LOG_DIR=${DB_LOG_DIR}
# Declara argumento DB_LOG_DIR para la carpeta donde MariaDB escribirá logs en el filesystem virtualizado


ENV DB_PORT=${DB_PORT} \
# Convierte el argumento DB_PORT en variable de entorno disponible en tiempo de ejecución del contenedor

    DB_DATADIR=${DB_DATADIR} \
# Establece la variable de entorno DB_DATADIR para que los scripts internos conozcan la ruta de datos

    DB_ROOT_PASS=${DB_ROOT_PASS} \
# Establece la variable de entorno con la contraseña de root accesible al entrypoint

    DB_NAME=${DB_NAME} \
# Establece la variable de entorno con el nombre de la base de datos

    DB_USER=${DB_USER} \
# Establece la variable de entorno con el usuario del servicio MariaDB

    DB_PASS=${DB_PASS} \
# Establece la variable de entorno con la contraseña del usuario de aplicación

    DB_LOG_DIR=${DB_LOG_DIR}
# Establece la variable de entorno con la ruta de logs usada por MariaDB


# Instalar mariadb y cliente
# Encabezado que introduce el bloque de aprovisionamiento de software dentro del contenedor

RUN apk update && \
# Ejecuta actualización del índice de paquetes del sistema Alpine dentro de la imagen virtual

    apk add --no-cache mariadb mariadb-client mariadb-server-utils && \
# Instala los paquetes necesarios del servidor MariaDB, cliente y utilidades sin almacenar caché

    addgroup -S ${DB_USER} && \
# Crea un grupo de sistema con el nombre del usuario para ejecutar el servicio de forma aislada

    adduser -S ${DB_USER} -G ${DB_USER} && \
# Crea un usuario de sistema asociado al grupo anterior para separar privilegios en virtualización

    mkdir -p ${DB_DATADIR} ${DB_LOG_DIR} /entrypointsql && \
# Crea de forma recursiva las carpetas de datos, logs y directorio interno para scripts SQL

    chown -R ${DB_USER}:${DB_USER} ${DB_DATADIR} ${DB_LOG_DIR} /entrypointsql && \
# Asigna la propiedad de dichas carpetas al usuario del servicio para evitar errores de permisos Docker

    chmod -R 755 ${DB_DATADIR} ${DB_LOG_DIR} /entrypointsql && \
# Otorga permisos de lectura y ejecución estándar dentro del contenedor

    rm -rf /var/cache/apk/* /tmp/* /var/tmp/* && \
# Limpia archivos temporales reduciendo tamaño de la imagen virtual final

    mariadb-install-db --user=${DB_USER} --datadir=${DB_DATADIR}
# Ejecuta inicialización del datadir creando tablas de sistema con usuario no root

    mariadb-install-db --user=${DB_USER} --datadir=${DB_DATDIR}
# — en contenido original esta línea estaba unificada arriba; aquí se explica nuevamente la inicialización


COPY ./docker/bd/scripts/docker-entrypoint.sh /entrypoint.sh
# Copia desde el host Docker el script principal de arranque al filesystem raíz del contenedor

COPY ./docker/bd/sql/*.sql /entrypointsql/
# Copia todos los archivos SQL de desarrollo para que el entrypoint los ejecute al iniciar

COPY ./docker/bd/conf/mysql.dev.cnf /etc/my.cnf
# Copia el archivo de configuración personalizado a la ruta estándar que leerá MariaDB


RUN chown -R ${DB_USER}:${DB_USER} /entrypoint* && chmod 755 /entrypoint.sh && ls -la /entrypoint*
# Asigna permisos al script copiado, lo marca ejecutable y lista su contenido para depuración en logs

RUN dos2unix /entrypoint.sh && chmod 755 /entrypoint.sh
# Convierte finales de línea Windows→Unix garantizando compatibilidad del script dentro del contenedor


#USER ${DB_USER}
# Línea comentada por el profesor que permitiría ejecutar todo como usuario no root

# Exponer puerto
# Encabezado para indicar el mapeo de red del contenedor

EXPOSE ${DB_PORT}
# Declara que el contenedor escuchará en el puerto definido, permitiendo a Docker publicarlo


# Entrypoint y comando por defecto
# Encabezado final para explicar la configuración de inicio automático del contenedor

ENTRYPOINT ["sh", "/entrypoint.sh" ]
# Define el comando que se ejecutará al hacer docker run, convirtiendo este contenedor en máquina virtual autónoma
