---
title: "i2p"
date: 2021-07-01
img: 'i2p.svg'
icon: 'itoopie.svg'
tags: ['service']
short_desc: "A private and uncensorable web-layer similar to Tor."
---

Now you have a website, why not offer it in a private alternative such
as the Invisible Internet?

## Setting up I2P

There are 2 main I2P implementations, I2P and i2pd, we are using i2pd in
this guide because it\'s easier to use in servers.

### Installing I2P

i2pd is in most repos, in debian/ubuntu you can install it simply with

```sh
apt install i2pd
```

### Enabling I2P

We are going to create a user for i2pd, because i2pd finds the
configuration files in its home directory. And it\'s easier (and more
tidy) to have it in a separate user:

```sh
useradd -m i2p -s /bin/bash
su -l i2p
mkdir ~/.i2pd
cd ~/.i2pd
```

Now that you\'re in \~/.i2pd, you have to create a file named
\"tunnels.conf\". Which is the config file for every hidden service
you\'re offering over I2P, the content should be like this:

```systemd
[example]
type = http
host = 127.0.0.1
port = 8080
keys = example.dat
```

### Getting your I2P Hostname

Then, run `/usr/sbin/i2pd --daemon` to start i2pd and we can retreive
our I2P hostname.

This can be done in lynx or a command-line browser by going to
`http://127.0.0.1:7070/?page=i2p_tunnels` to get your I2P hostname.

You can also run these commands to find your hostname:

```sh
printf "%s.b32.i2p
" $(head -c 391 /home/i2p/.i2pd/example.dat |sha256sum|xxd -r -p | base32 |sed s/=//g | tr A-Z a-z)
```

## Adding the Nginx Config

From here, the steps are almost identical to setting up a normal website
configuration file. Follow the steps as if you were making a new website
on the webserver [tutorial](/basic/nginx) up until the server block of
code. Instead, paste this:

```nginx
server {
	listen 127.0.0.1:8080 ;
	root /var/www/{{<hl>}}example{{</hl>}} ;
	index index.html ;
}
```

#### Clarifications

####

Nginx will listen in port 8080, but i2pd will forward your port 8080 to
the i2p site port 80. This way you don\'t have to deal with server names
or anything like that

From here we are almost done, all we have to do is enable the site and
reload nginx which is also covered in [the webserver
tutorial](nginx.html#enable).

### Update regularly!

Make sure to update I2P on a regular basis by running:

```sh
apt update && apt install i2pd
```

**Contributor** - [qorg11](https://qorg11.net)
