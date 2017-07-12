#!/bin/bash

exec logger -p local0.error -t nginx-error -f /var/log/nginx/error.log
