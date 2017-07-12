#!/bin/bash

exec logger -p local0.error -t php-error -f /var/log/php/error.log
