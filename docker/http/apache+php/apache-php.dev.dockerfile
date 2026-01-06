FROM alpine:latest
# Imagen base ligera Alpine Linux para mantener la imagen final pequeña y eficiente en Docker

# Argumentos de construcción
ARG SERVER_PORT=${SERVER_PORT}
# Puerto en el que Apache escuchará solicitudes HTTP, se puede sobrescribir al construir

ARG SERVER_NAME=${SERVER_NAME}
# Nombre del servidor virtual usado en Apache (por ejemplo moodle.localhost)

ARG FOLDER_NAME=${FOLDER_NAME}
# Carpeta dentro del contenedor donde se alojará el código fuente de la aplicación

# Variables de entorno disponibles en tiempo de ejecución del contenedor
ENV FOLDER_NAME=${FOLDER_NAME}
ENV SERVER_PORT=${SERVER_PORT}
ENV SERVER_NAME=${SERVER_NAME}
# Permiten que scripts internos o configuraciones Apache accedan a estos valores

# Exponer puertos
EXPOSE ${SERVER_PORT}
# Puerto HTTP del contenedor
EXPOSE 9003
# Puerto de Xdebug para comunicación con IDE externo

# Instalación de Apache, PHP y extensiones necesarias
RUN apk update && apk upgrade && \
    apk --no-cache add apache2 apache2-utils apache2-proxy php php-apache2 \
    php-curl php-gd php-mbstring php-intl php-mysqli php-xml php-zip \
    php-ctype php-dom php-iconv php-simplexml php-openssl php-sodium php-tokenizer php-xdebug
# Se actualiza índice de paquetes y se instalan:
# - apache2 y utilidades básicas
# - PHP + módulo para Apache
# - Extensiones PHP comunes necesarias para Moodle (gd, mbstring, intl, mysqli, xml, zip, etc.)
# - Xdebug para depuración dentro del contenedor
# --no-cache evita almacenamiento de caché de apk, reduciendo el tamaño de la imagen

# Preparación del directorio de la aplicación
RUN mkdir -p ${FOLDER_NAME} \
    && chown -R apache:apache ${FOLDER_NAME} \
    && chmod -R 755 ${FOLDER_NAME} \
    && mkdir -p /etc/php84/conf.d
# - Crea la carpeta de la aplicación
# - Cambia propietario a apache para ejecutar el servidor con usuario seguro
# - Otorga permisos de lectura y ejecución
# - Crea carpeta para configuraciones adicionales de PHP 8.4 (como xdebug.ini)

# Copia de archivos de configuración al contenedor
COPY ./docker/http/apache+php/apache/httpd.conf /etc/apache2/httpd.conf
# Copia el archivo principal de configuración de Apache

COPY ./docker/http/apache+php/apache/conf.d/*.conf /etc/apache2/conf.d/
# Copia los VirtualHosts, módulos adicionales y configuraciones específicas

COPY ./docker/http/apache+php/php/php.ini /etc/php84/
# Copia la configuración principal de PHP

COPY ./docker/http/apache+php/php/conf.d/*.ini /etc/php84/conf.d/
# Copia configuraciones adicionales de PHP, incluyendo Xdebug

# Comando por defecto al iniciar el contenedor
ENTRYPOINT ["httpd", "-D", "FOREGROUND"]
# Inicia Apache en primer plano, manteniendo el contenedor activo
