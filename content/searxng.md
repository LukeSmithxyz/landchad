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
apt install git nginx nginx-extras -y
```

Open http and https ports.

```sh
iptables -I INPUT -m state --state NEW -p tcp --dport 80 -j ACCEPT
iptables -I INPUT -m state --state NEW -p tcp --dport 443 -j ACCEPT
netfilter-persistent save
ufw allow 80
ufw allow 443
```

First we will create a user for SearX.

```
useradd -mr -d "/usr/local/searxng" -c 'Privacy-respecting metasearch engine' -s /bin/bash searxng
```
Although the auto-install script below we create this user itself, we can go ahead and make it to give the cloned repository the correct permissions.

Now we clone the SearXNG Repository into the `searx` user's home.

```sh
git clone https://github.com/searxng/searxng /usr/local/searxng/searxng-src
cd /usr/local/searxng/searxng-src
```

Installing SearXNG.

```sh
./utils/searxng.sh install all
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
    server_name searx.{{<hl>}}example.org{{</hl>}} ;

    # If you want to log user activity, comment these
    access_log /dev/null;
    error_log  /dev/null;

    # X-Frame-Options (XFO) header set to DENY
    add_header X-Frame-Options "DENY";

    # HTTP Strict Transport Security (HSTS) header
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";

    # Content Security Policy (CSP)
    add_header Content-Security-Policy "default-src 'self';";

    location / {
        uwsgi_pass unix:///usr/local/searxng/run/socket;

        include uwsgi_params;

        uwsgi_param    HTTP_HOST             $host;
        uwsgi_param    HTTP_CONNECTION       $http_connection;

        # see flaskfix.py
        uwsgi_param    HTTP_X_SCHEME         $scheme;
        uwsgi_param    HTTP_X_SCRIPT_NAME    /searxng;

        # see limiter.py
        uwsgi_param    HTTP_X_REAL_IP        $remote_addr;
        uwsgi_param    HTTP_X_FORWARDED_FOR  $proxy_add_x_forwarded_for;

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
service uwsgi restart searxng
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
