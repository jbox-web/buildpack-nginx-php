#!/bin/bash

erb /app/.conf/rsyslog.conf.erb > /etc/rsyslog.conf

rm -f /var/run/rsyslogd.pid

exec /usr/sbin/rsyslogd -n
