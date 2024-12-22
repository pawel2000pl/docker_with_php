#!/bin/bash

REMOTE_HOST=`/sbin/ip route | awk '/default/ { print $3 }'`

if [ "$DEBUG" == "TRUE" ]
then
    apt install -y php8.2-xdebug bindfs
    echo "xdebug.mode=debug" >> /etc/php/8.2/fpm/conf.d/20-xdebug.ini
    echo "xdebug.client_host=$REMOTE_HOST" >> /etc/php/8.2/fpm/conf.d/20-xdebug.ini
    echo "xdebug.client_port=9003" >> /etc/php/8.2/fpm/conf.d/20-xdebug.ini
    mkdir -p /debug
fi
