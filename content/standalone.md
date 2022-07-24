---
title: "Certbot on Standalone Domains and Subdomains"
date: 2021-07-02
tags: ['server']
---

The command `certbot --nginx` will take an unencrypted website on an
Nginx configuration file, get a certificate for it and change the
configuration to use that certificate and thus HTTPS.

Sometimes, however, you are given an Nginx configuration template that
already has encryption/HTTPS, so running the automated `certbot --nginx`
is not possible, as it will simply give an error saying that the
certicate that Nginx is looking for doesn\'t already exist and thus the
Nginx config is broken.

So suppose you want to get a certificate for **pleroma.example.org**
because you are installing Pleroma and the configuration file
presupposes a certificate. In this case you would want to run this:

```sh
systemctl stop nginx
certbot certonly --standalone -d pleroma.example.org
systemctl start nginx
```

What we do here is temporarily turn off Nginx, then run a `certonly`
subcommand that generates a certificate for the domain without changing
or caring about the Nginx configuration. Then we reactivate Nginx, thus
turning back on our webserver.

The reason we deactivate Nginx is that it uses the ports that Certbot
will want to bind to, and thus we must temporarily turn Nginx off to let
Certbot use those ports. (What it actually does is spin up a dummy
webserver that doesn\'t need to think about the Nginx configuration.)

This is just a little note of something that might confuse people, but
the three commands above should suffice. If your site is still managed
by Nginx, it should still be able to renew with simple
`certbot renew --nginx` without a problem.
