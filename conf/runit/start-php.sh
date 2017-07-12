#!/bin/bash

export SITE_USER=$(grep '/app' /etc/passwd | cut -d':' -f 1)

erb /app/.conf/php.conf.erb > /etc/php5/fpm/pool.d/www.conf

chown -R $SITE_USER.$SITE_USER /var/log/php

exec /usr/sbin/php5-fpm --nodaemonize
