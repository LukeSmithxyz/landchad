---
title: "Setting Up a www to non-www Redirect using NginX"
date: 2021-07-28
draft: true
---

# Setting Up a www to non-www Redirect using NginX

You may have noticed that after completing '[Setting Up an NginX Webserver](/basic/nginx/)', connecting to your site with **http://www.** or **https://www.** fails. If **www.landchad.net** was included in the `server_name` line, **landchad.net** would have been mirrored at two URLs, producing sub-optimal SEO. The optimal way by which we can include www URLs is to setup whats called a '301 redirect', which essentially does the following:

```http://www.landchad.net --becomes-> http://landchad.net

https://www.landchad.net --becomes-> https://landchad.net
```

In addition to the '[Setting Up an NginX Webserver](/basic/nginx/)' tutorial, this tutorial assumes that you have already followed the steps in the '[Certbot and HTTPS](/basic/certbot/)' tutorial. In the latter tutorial, the following occured:

- a non-www HTTPS/SSL certificate was generated
- HTTP traffic was made to redirect to HTTPS

For www to non-www redirection, we now need to do the following:

- generate an HTTPS/SSL certificate for www
- redirect www to non-www

## Why do I need an HTTPS/SSL certificate for www.mydomain if I'm redirecting requests to a non-www URL?

Web browsers will display a security error/message if you attempt to connect to a site with HTTPS that has no corresponding HTTPS/SSL certificate. In the above example, the web server has had no chance to redirect you; in the order of processes, HTTPS/SSL certificate checks come first. So even if www is redirected to non-www, **https://www.** will produce a security error/message according to the logic above.

## Installation

### Step 1: Expanding your current HTTPS/SSL certificate to include www.yourdomain

Here we will use Certbot to expand our HTTPS/SSL certificate created during '[Certbot and HTTPS](/basic/certbot/)'. Run the following command. Make sure to include `certonly` otherwise Certbot will search for a non-existent server block to insert its code into. (We will create a "catch-all" server block later using regex).

```certbot certonly --nginx --expand -d landchad.net,www.landchad.net
```

### Step 2: Creating an NginX configuration file with redirection rules

To keep things simple, we will place the rules for www to non-www redirection in new NginX configuration file.

First, however, make note of the `ssl_certificate` and `ssl_certificate_key` paths in your current NginX configuration:

```nano /etc/nginx/sites-available/landchad
```

For example, **landchad.net**'s is: `ssl_certificate /etc/letsencrypt/live/landchad.net/fullchain.pem` and `ssl_certificate_key /etc/letsencrypt/live/landchad.net/privkey.pem`.

Next, create the new NginX configuration file and populate it with the following (replacing the paths here with your own). (We have chose to use `default`):

```nano /etc/nginx/sites-available/default
```

```ssl_certificate /etc/letsencrypt/live/landchad.net/fullchain.pem ;
ssl_certificate_key /etc/letsencrypt/live/landchad.net/privkey.pem ;

server {
	listen 80 ;
	server_name ~^(www\.)?(?<domain>.+)$ ;
	return 301 https://$domain$request_uri ;
}

server {
	listen 443 ssl ;
	server_name ~^(www\.)?(?<domain>.+)$ ;
	return 301 $scheme://$domain$request_uri ;
}
```

#### Explanation of those settings

The first two lines specify the path of the HTTPS/SSL certificate. By specifying the HTTPS/SSL certificate here, we are making the domains it contains accessible to every server block that follows.

The `server_name` line includes regex which will match any connection using www. By using regex, we avoid needed to write a redirect rule for every URL containing www.

### Enable the redirection

Next, make a link to it in the `sites-enabled` directory:

```ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled
```

Now we can just `reload` or `restart` to make NginX service the new configuration:

```systemctl reload nginx
```

Author: [tomhonour](https://github.com/tomhonour)
