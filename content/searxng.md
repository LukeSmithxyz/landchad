---
title: "SearXNG"
date: 2022-05-16
icon: 'searxng.svg'
tags: ['service']
short_desc: 'Polls dozens of search engines to give you private and complete search results.'
---

SearXNG is a free internet metasearch engine which aggregates results
from more than 70 search services. This guide sets up a working instance
that can be accessed using a domain over HTTPS. Features include:

-  Self-hosted
-  No user tracking
-  No user profiling
-  About 70 supported search engines
-  Easy integration with any search engine
-  Cookies are not used by default
-  Secure, encrypted connections (HTTPS/SSL)

## Installation

Install the required packages.

```sh
apt install git nginx -y
```

Open http and https ports.

```sh
iptables -I INPUT 6 -m state --state NEW -p tcp --dport 80 -j ACCEPT
iptables -I INPUT 6 -m state --state NEW -p tcp --dport 443 -j ACCEPT
netfilter-persistent save
ufw allow 80
ufw allow 443
```

Clone the SearXNG Repository.

```sh
git clone https://github.com/searxng/searxng searxng
cd searxng
```

Installing SearXNG, Filtron and Morty.

```sh
./utils/searx.sh install all
./utils/filtron.sh install all
./utils/morty.sh install all
```

Check that both filtron and morty are running.

```sh
systemctl status filtron
systemctl status morty
```

## Configure Nginx

Create a new file `/etc/nginx/sites-available/searxng.conf` and add the
following:

```nginx
server {

    # Listens on http
    listen 80;
    listen [::]:80;

    # Your server name
    server_name searx.example.org;

    # If you want to log user activity, comment these
    access_log /dev/null;
    error_log  /dev/null;

    # Searx reverse proxy
    location / {
            proxy_pass         http://127.0.0.1:4004/;

            proxy_set_header   Host             $host;
            proxy_set_header   Connection       $http_connection;
            proxy_set_header   X-Real-IP        $remote_addr;
            proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
            proxy_set_header   X-Scheme         $scheme;
            proxy_set_header   X-Script-Name    /searx;
    }

    location /searx/static {
            alias /usr/local/searx/searx-src/searx/static;
    }

    # Morty reverse proxy
    location /morty {
            proxy_pass         http://127.0.0.1:3000/;

            proxy_set_header   Host             $host;
            proxy_set_header   Connection       $http_connection;
            proxy_set_header   X-Real-IP        $remote_addr;
            proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
            proxy_set_header   X-Scheme         $scheme;
    }
}
```


Now create a symbolic link to enable this site.

```sh
ln -s /etc/nginx/sites-available/searxng.conf /etc/nginx/sites-enabled/searxng.conf
```

Restart Nginx and SearXNG.

```sh
systemctl restart nginx
service uwsgi restart searx
```

## Configure HTTPS with Certbot

Install certbot.

```sh
apt install python3-certbot-nginx
```

Install a Let\'s Encrypt SSL certificate to Nginx and optionally let it
configure HTTPS for you. [Detailed instructions and additional information](/basic/certbot).

```sh
certbot --nginx
```

SearXNG should now be available from your domain.

## Configuration

You can change settings by editing `/etc/searxng/settings.yml`.

## Contribution

Author: goshawk22 -- [website](https://goshawk22.uk)
