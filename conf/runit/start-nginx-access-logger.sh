#!/bin/bash

exec logger -p local0.info -t nginx-access -f /var/log/nginx/access.log
