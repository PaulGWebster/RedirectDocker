#!/bin/bash

echo "Creating VHOST files"             \
&& ./sbin/write_vhosts.pl               \
&& echo "Sleeping 5 seconds (antirace)" \
&& sleep 5                              \
&& echo "Running NGINX"                 \
&& nginx -c /etc/nginx/nginx.conf       \
&& echo "Starting attach.pl"            \
&& ./sbin/attach.pl