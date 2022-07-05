
Docco is a docker image that aims to provide an easy way to deploy docker-compose files on a remote machine in combination with a virtual host name and options to configure the containers.

# Usage

Add the following `docker-compose.yml` file on your server, configure the `DEFAULT_EMAIL` and the `authorized_keys` settings and start it via `docker compose up -d`.


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

#networks:
#  default:
#    external: true

volumes:
  letsencrypt-certs:
  letsencrypt-vhost-d:
  letsencrypt-html:
  acme:
  docco-git:
  docco-apps:
```

When the container is up and running you can start using docco:

To list all docco commands run:

`ssh docco@<IP>:<PORT> -p 2222`

Now you first need to create an app by running:

`ssh docco@<IP>:<PORT> -p 2222 apps create foobar`.

This will create a remote git repository where you can push your project.

But before this we want to set a DOMAIN for the project. Therefor we run:

`ssh docco@<IP>:<PORT> -p 2222 config set foobar DOMAIN=foobar.apps.myserver.com`.

Hint: Make sure that your DNS entries for the server are set up correctly. The best is to use a wildcard DNS entry like "*.apps.myserver.com".

Now you can push your project to your server:

```
# add origin to your local git directory
$ git remote add docco docco@<IP>:<PORT>/git/foobar
$ git push origin docco
```

Docco will then look for a docker-compose file and start the containers under defined domain.



