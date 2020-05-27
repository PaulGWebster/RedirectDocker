# nginx redirection system for docker

This is a small system for making simple proxy pass redirections in docker

## Format

As an enviroment variable add: DOMAIN:TARGET_HTTP_HOST:TARGET_HTTP_PORT:TARGET_HTTPS_HOST:TARGET_HTTPS_PORT

An example of this is provided in the docker-compose.yml in the container, note that 'web' is being played
by netcat, to simply show the incoming requests. You should remove this once you have learned how the setup
works.

The image also contains ncat,nmap,socat, netcat, redir gcc and perl(+ssl +poe) so you can redirect what 
you like in difference to nginx as well :)

## Logging

This image will log to STDERR so in docker-compose it will show things such as:

```yaml
proxy_1 | access.log: 172.30.0.1 - - [26/May/2020:21:16:43 +0100] "GET / HTTP/1.0" 200 11393 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.136 Safari/537.36" "-"
```

Ontop of this it reserves the handler _log on the outside edge, so if you was to visit http://IP_OF_CONTAINER/_log you 
will get both the access.log and error.log as a file list.

## Redirect to HTTPS

If you was to use a line such as:

```yaml
NGINX_VHOST_MYSITE: "something.mydomain.com:127.0.0.1:80:container:80"
```

All requests will automatically be sent a redirect header (303 - other) to https, this is due to the default configuration of the nginx server in the container notable:

```yaml
    server {
        listen 127.0.0.1:80;
        location / {
            return 303 https://$host$request_uri;
        }
    }
```

The reason why 303 instaed of 301 is that 303 is not cached! which means in future if you wished to serve something over http, you will be able to without issue.

## HTTPS inbound connections

The nginx is expecting an additional header added by whatever upstream is passing to it, notable X-Server-Select, it expects 
that if the upstream webserver has accepted a HTTPS connection it will set this header to 'https' likewise if it accepted a 
plaintext non-ssl connection, it will be set to 'http'.

This setting if not present will presume to be HTTP.

An example of an upstream nginx setting this would be:

```yaml
    server {
        listen 80;
        server_name my.domain;

        ## Send header to tell the browser to prefer https to http traffic
        add_header Strict-Transport-Security max-age=31536000;

        # Add rest of your config below like document path and more ##
        location / {
            proxy_pass http://10.10.10.10:8080;
            proxy_set_header X-Server-Select http;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header Host $host;
        }
    }
```

Likewise for https:

```yaml
    server {
        #------- Start SSL config with http2 support ----#
        listen 443 ssl;
        server_name *;

        ssl_certificate     /path/to/pem/fullchain.pem;
        ssl_certificate_key /path/to/key/ssl.key;

        ## Improves TTFB by using a smaller SSL buffer than the nginx default
        ssl_buffer_size 8k;

        ## Enables OCSP stapling
        ssl_stapling on;

        ## Send header to tell the browser to prefer https to http traffic
        add_header Strict-Transport-Security max-age=31536000;

        # Add rest of your config below like document path and more ##
        location / {
            proxy_pass http://10.10.10.10:8080;
            proxy_set_header X-Server-Select https;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header Host $host;
        }
    }
```
