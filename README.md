# nginx redirection system for docker

This is a small system for making simple proxy pass redirections in docker

## Format

As an enviroment variable add: DOMAIN:TARGET_HTTP_HOST:TARGET_HTTP_PORT:TARGET_HTTPS_HOST:TARGET_HTTPS_PORT

An example of this is provided in the docker-compose.yml in the container, note that 'web' is being played
by netcat, to simply show the incoming requests. You should remove this once you have learned how the setup
works.
