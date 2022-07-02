---
title: "Run your own DNS over HTTPS server."
tags: ['service']
draft: true
---

Encrypted DNS can be a great tool for your online privacy if it\'s
hosted by a trustworthy entity, and who can you trust more with your
data than yourself?

## Installing Unbound.

First of all, we need to install our DNS server, Unbound. Unbound is a
validating, recursive and caching DNS server.

```sh
apt install -y unbound
```

### Now that Unbound is installed, we will configure it a bit.

Using your favorite editor, edit the file `/etc/unbound/unbound.conf`
and add the following values, if they don\'t exist already:

```
include-toplevel: "/etc/unbound/unbound.conf.d/*.conf"
server:
    log-queries: no
    log-replies: no
    aggressive-nsec: yes
    ratelimit: 150
    verbosity: 1
    ```

Now restart Unbound to activate your new configuration:

 ```sh
 systemctl restart unbound
 ```

To test to see if your DNS server is resolving, add
`nameserver 127.0.0.1` to your `/etc/resolv.conf`. If you are able to
resolve domains, Unbound is working.

## Installing DNSS.

Now we need to install a program to convert HTTP requests to DNS
queries. `dnss` accomplishes that goal very well.

To install DNSS, run the following command:

```sh
apt install -y dnss
```

### Configuring DNSS.

DNSS comes with a bad default configuration, disable it using the
following command:

```sh
systemctl disable --now dnss dnss.socket
```

Now, using your favorite text editor, create a new file in
`/etc/systemd/system` named `doh.service`. This will be the new DNSS
configuration file. Add the following values to the file:

```systemd
[Unit]
Description=DNSS DNS over HTTPS Proxy
[Service]
ExecStart=/usr/bin/dnss \
    -enable_https_to_dns \
    -https_server_addr 127.0.0.1:8080 \
    -insecure_http_server \
    -dns_upstream 127.0.0.1:53

Type=simple
Restart=always
User=dnss
Group=dnss

CapabilityBoundingSet=CAP_NET_BIND_SERVICE
ProtectSystem=full

[Install]
WantedBy=multi-user.target
```

Close the file and enable/start it using the command:

```sh
systemctl enable --now doh.service
```

## Setting up Nginx.

To set up Nginx with HTTPS, follow [these](/basic/nginx) [guides](/basic/certbot).

Once you\'ve gotten all of that set up, we\'ll reverse proxy our HTTPS
to DNS proxy. Open up your Nginx config file, and add the following
values:

```nginx
location /dns-query {
    proxy_pass http://127.0.0.1:8080/;
}
```

Now, your configuration should look something like this:

```nginx
server {
    listen 80;
    server_name landchad.net;
    return 301 https://$host$request_uri;
}
server {
    listen 443 ssl http2;
    server_name landchad.net;
    root /var/www/landchad;
    ssl_certificate /etc/letsencrypt/live/landchad.net/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/landchad.net/privkey.pem;
    location /dns-query {
        proxy_pass http://127.0.0.1:8080/;
    }
}
```

Finally, you can check your Nginx config using `nginx -t`, if the check
passes, restart Nginx using the command:

```sh
systemctl restart nginx
```

## Using your DNS over HTTPS server.

To use your new DNS over HTTPS server, go to your browser\'s settings
and navigate to the \"Network Settings\" area. You should be able to set
a custom secure DNS url. Once set, you can check to see if it\'s working
by attempting to resolve domains, and by testing your browser with
[whatismydnsserver.com](http://www.whatsmydnsserver.com/).

## Contributor

[Josiah.](https://ioens.is)
