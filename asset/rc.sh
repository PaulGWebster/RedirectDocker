#!/bin/bash

echo "Creating VHOST files"         \
&& ./sbin/write_vhosts.pl           \
&& echo "Running NGINX"             \
&& nginx -c /etc/nginx/nginx.conf   \
&& echo "Starting attach.pl"        \
&& ./sbin/attach.pl