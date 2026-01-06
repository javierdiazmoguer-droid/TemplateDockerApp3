CREATE SCHEMA IF NOT EXISTS `template_docker_app_dev` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
-- Ejecuta la creación de un esquema (equivalente a base de datos) solo si aún no existe, evitando errores al recrear el contenedor
-- El nombre del esquema identifica el entorno de desarrollo del proyecto Docker
-- Se establece la codificación utf8mb4 para soportar todo el rango Unicode
-- La cláusula COLLATE fija la ordenación general insensible a mayúsculas y acentos
-- El punto y coma marca el final de la instrucción dentro del fichero

USE `template_docker_app_dev`;
-- Cambia el contexto de trabajo del cliente al esquema recién creado
-- Todas las tablas o inserts posteriores se ejecutarán dentro de esta base de datos del contenedor
-- Permite que el entrypoint Docker importe este archivo sin necesidad de indicar la base por parámetro
