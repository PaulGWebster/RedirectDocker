# nginx redirection system for docker

This is a small system for making simple proxy pass redirections in docker

## Format

As an enviroment variable add: DOMAIN:TARGET_HTTP_HOST:TARGET_HTTP_PORT:TARGET_HTTPS_HOST:TARGET_HTTPS_PORT

An example of this is provided in the docker-compose.yml in the container, note that 'web' is being played
by netcat, to simply show the incoming requests. You should remove this once you have learned how the setup
works.

The image also contains ncat,nmap,socat, netcat, redir gcc and perl(+ssl +poe) so you can redirect what 
you like in difference to nginx as well :)

## Redirect to HTTPS

If you was to use a line such as:

    NGINX_VHOST_MYSITE: "something.mydomain.com:127.0.0.1:80:container:80"

All requests will automatically be sent a redirected to https, the container runs a server on 127.0.0.1:80, 
that simply redirects back to https, notable:

    server {
        listen 127.0.0.1:80;
        location / {
            return 303 https://$host$request_uri;
        }
    }
