FROM alpine:latest

ARG MOODLE_SERVER_PORT=${MOODLE_SERVER_PORT}
ARG MOODLE_SERVER_NAME=${MOODLE_SERVER_NAME}

ENV MOODLE_SERVER_PORT=${MOODLE_SERVER_PORT}
ENV MOODLE_SERVER_NAME=${MOODLE_SERVER_NAME}

EXPOSE ${MOODLE_SERVER_PORT}
EXPOSE 9003

RUN apk update && apk upgrade && \
    apk --no-cache add apache2 apache2-utils apache2-proxy php php-apache2 \
    php-curl php-gd php-mbstring php-intl php-mysqli php-xml php-zip \
    php-ctype php-dom php-iconv php-simplexml php-openssl php-sodium php-tokenizer php-xdebug
RUN mkdir -p /var/www/${MOODLE_SERVER_PORT} \
    && chown -R apache:apache /var/www/${MOODLE_SERVER_PORT} \
    && chmod -R 755 /var/www/${MOODLE_SERVER_PORT}

COPY ./docker/http/apache+php/conf/httpd.conf /etc/apache2/httpd.conf
COPY ./docker/http/apache+php/conf.d/php-xdebug.ini /etc/php84/conf.d/php-xdebug.ini
COPY ./docker/http/apache+php/conf.d/*.conf /etc/apache2/conf.d/
ENTRYPOINT ["httpd", "-D", "FOREGROUND"]