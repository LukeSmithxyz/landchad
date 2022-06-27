---
title: "Redirecting www to non-www using NginX"
date: 2021-07-27
draft: true
---

This tutorial shows you how to redirect URLs beginning with www to "non-www" URLs (such as **http://landchad.net** or **https://landchad.net**). This tutorial assumes that you have already followed the steps in the 'Certbot and HTTPS' tutorial. In that tutorial, the following happened:

- a "non-www" SSL certificate was generated
- http traffic was made to redirect to https

For www to "non-www" redirection, we now need to do the following:

- generate an SSL certificate for www
- redirect www to non-www

## Why do I need an SSL certificate for www if I'm already redirecting traffic to a non-www URL?
Certification is checked before redirection in web browsers and so this SSL certificate is required for anyone who visits your site by using https://www.

## Step 1: Expand your current certificate to include www

Certbot will be used to expand your current certificate to include your domain with www. In the next command, it is important that we include `certonly` because otherwise Certbot will search for a non-existant server block to insert its code into. (We will create a "catch-all" server block using regex later).

```certbot certonly --nginx --expand -d landchad.net,www.landchad.net
```

## Create a redirection conf

To keep things simple, we will create a new nginx configuration file which will store www to non-www redirection rules.

First, make note of the `ssl_certificate` and `ssl_certificate_key` paths in your current nginx conf:

```nano /etc/nginx/sites-available/landchad
```

For example: `ssl_certificate /etc/letsencrypt/live/landchad.net/fullchain.pem` and `ssl_certificate_key /etc/letsencrypt/live/landchad.net/privkey.pem`.

Next, create the new conf and populate it with the following (replacing the paths here with your own):

```nano /etc/nginx/sites-available/default
```

```ssl_certificate /etc/letsencrypt/live/landchad.net/fullchain.pem ;
ssl_certificate_key /etc/letsencrypt/live/landchad.net/privkey.pem ;

server {
	listen 80 ;
	server_name ~^(www\.)?(?<domain>.+)$ ;
	return 301 $scheme://$domain$request_uri ;
}

server {
	listen 443 ssl ;
	server_name ~^(www\.)?(?<domain>.+)$ ;
	return 301 $scheme://$domain$request_uri ;
}
```

Next, make a link to it in the `sites-enabled` directory:

```ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled
```

Now we can just `reload` or `restart` to make nginx service the new configuration:

```systemctl reload nginx
```
