#!/bin/bash

erb /app/.conf/nginx.conf.erb > /etc/nginx/sites-available/default

exec /usr/sbin/nginx
