#!/bin/bash

cp '/etc/php/8.2/fpm/pool.d/www.conf' '/etc/php/8.2/fpm/pool.d/www.conf.old'

XDEBUG_SESSION_START=`test "$DEBUG" == "TRUE" && echo 1 || echo 0`

PHP_CONF='/etc/php/8.2/fpm/pool.d/www.conf'
ENV_FILE='/root/.env'
TMP_PHP_CONF="/tmp/php.conf.tmp"

for VAR in $(printenv | awk -F= '{print $1}'); do
    VALUE=$(printenv "$VAR")
    cp "$PHP_CONF" "$TMP_PHP_CONF"
    grep -vP "env\[$VAR\]" "$TMP_PHP_CONF" > "$PHP_CONF"
    echo "env[$VAR]=\"$VALUE\"" >> "$PHP_CONF"
    echo "export $VAR=\"$VALUE\"" >> "$ENV_FILE"
done


if [ -e "/debug/private" ]
then
    USER_OWNER=`ls -la /debug | cut -f 3 -d " " | head -n 2 | tail -n 1`
    GROUP_OWNER=`ls -la /debug | cut -f 4 -d " " | head -n 2 | tail -n 1`
    rm -rf /var/www/*
    bindfs -u www-data -g www-data --create-for-user=$USER_OWNER --create-for-group=$GROUP_OWNER /debug /var/www
fi

service ssh start
service php8.2-fpm start
service nginx start

cleanup_function() {
    service ssh stop
    service php8.2-fpm stop
    service nginx stop
}

trap 'cleanup_function' SIGINT
trap 'cleanup_function' SIGTERM
tail -f /var/log/nginx/error.log || true
