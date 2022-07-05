# What is Docco?

Docco is a docker image that aims to provide an easy way to deploy projects to a custom domain with a docker-compose file by just using `git push`.

The project is heavily inspired by the Heroku CLI and Dokku which make it very convenient to deploy Docker images or projects with a Dockerfile but do not support docker compose.

# Getting started

## System Requirements

To start using Docco you just need a server with a domain and docker + docker compose installed.

## Installation

Add the following `docker-compose.yml` file to your server, configure the `DEFAULT_EMAIL` and the `authorized_keys` settings and start it via `docker compose up -d`.

### 1. Start Docco with Docker-Compose

```yaml
version: "3"
services:
  nginx-proxy:
    image: nginxproxy/nginx-proxy
    container_name: nginx-proxy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/tmp/docker.sock:ro
      - letsencrypt-certs:/etc/nginx/certs
      - letsencrypt-vhost-d:/etc/nginx/vhost.d
      - letsencrypt-html:/usr/share/nginx/html
  letsencrypt-proxy:
    image: nginxproxy/acme-companion
    container_name: letsencrypt-proxy
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - letsencrypt-certs:/etc/nginx/certs
      - letsencrypt-vhost-d:/etc/nginx/vhost.d
      - letsencrypt-html:/usr/share/nginx/html
      - acme:/etc/acme.sh
    environment:
      - DEFAULT_EMAIL=admin@server.com
      - NGINX_PROXY_CONTAINER=nginx-proxy
  docco:
    image: krebbl/docco
    ports:
      - "2222:22"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /root/.ssh/authorized_keys:/home/docco/.ssh/authorized_keys:ro
      - docco-git:/git
      - docco-apps:/root/apps

networks:
  default:
    external: true
    name: nginx-proxy

volumes:
  letsencrypt-certs:
  letsencrypt-vhost-d:
  letsencrypt-html:
  acme:
  docco-git:
  docco-apps:
```

This will start an NGINX server and a letsencrypt proxy that will serve your project via HTTPS and a custom domain.

When the container is up and running you can start using docco

### 2. Create your first app

On your locale machine you can now run the following commands to create your first app:

```
# List all docco commands
ssh docco@<IP>:<PORT> -p 2222

# Create your first app
ssh docco@<IP>:<PORT> -p 2222 apps create foobar

# Set the DOMAIN for your app "foobar"
ssh docco@<IP>:<PORT> -p 2222 config set foobar DOMAIN=foobar.apps.myserver.com
```

**Hint:** Make sure that your DNS entries for the server are set up correctly. The best way is to
use a wildcard DNS entry like "*.apps.myserver.com".

### 3. Deploy your app

Now you can push your project to your server:

```
# go to your project you want to deploy

# add origin to your local git directory
$ git remote add docco docco@<IP>:<PORT>/git/foobar

# push your code to docco
$ git push origin docco
```

Docco will then look for a `docker-compose.yml` file and start the containers under defined domain.

Go to **foobar.apps.myserver.com** and check out if everything is working.

### 4. Destroy your app

If you want to destroy/remove your app you can run:

```
ssh docco@<IP>:<PORT> -p 2222 apps destroy foobar
```



