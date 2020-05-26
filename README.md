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

```
proxy_1 | access.log: 172.30.0.1 - - [26/May/2020:21:16:43 +0100] "GET / HTTP/1.0" 200 11393 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.136 Safari/537.36" "-"
```

Ontop of this it reserves the handler _log on the outside edge, so if you was to visit http://IP_OF_CONTAINER/_log you 
will get both the access.log and error.log as a file list.

## Redirect to HTTPS

If you was to use a line such as:

    NGINX_VHOST_MYSITE: "something.mydomain.com:127.0.0.1:80:container:80"

All requests will automatically be sent a redirect header (303 - other) to https, this is due to the default configuration of the nginx server in the container notable:

    server {
        listen 127.0.0.1:80;
        location / {
            return 303 https://$host$request_uri;
        }
    }
    
The reason why 303 instaed of 301 is that 303 is not cached! which means in future if you wished to serve something over http, you will be able to without issue.
