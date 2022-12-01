---
title: "Yarr"
date: 2022-07-01
icon: 'yarr.svg'
tags: ['service']
short_desc: 'A self-hosted, web-based feed aggregator'
---

[Yarr](https://github.com/nkanaev/yarr) (yet another rss reader) is a web-based feed aggregator which can be used both as a desktop application and a personal self-hosted server.

It is written in Go with the frontend in Vue.js. The storage is backed by SQLite.

## Installing Yarr

Firstly, we have to download yarr binary from github on our system

```sh
wget https://github.com/nkanaev/yarr/releases/download/v2.3/yarr-v2.3-linux64.zip
```

Unzip the archive

```sh
unzip -x yarr-v2.3-linux64.zip
```

Move the binary to your bin folder

```sh
mv yarr /usr/local/bin/yarr
```

## Configuration

Now we need to create a `auth.conf` file that include user and password to create a local yarr account.
I personnaly store this file in a directory called yarr in `~/.config` folder, but you can place the file wherever you want.

```sh
mkdir ~/.config/yarr
echo 'landchad:password' > ~/.config/yarr/auth.conf
```

## Creating a service

Create a new file /etc/systemd/system/yarr.service and add the following:

```systemd
[Unit]
Description=Yarr

[Service]
Environment=HOME=/home/landchad
ExecStart=/usr/bin/env yarr -addr 0.0.0.0:7070 -auth-file=/home/landchad/.config/yarr/auth.conf -db=/home/landchad/.config/yarr/feed.sql -log-file=/home/landchad/.config/yarr/access.log
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

After creating the config, load, start and enable the service with the following commands.

```sh
systemctl daemon-reload
systemctl enable --now yarr
```

## Nginx configuration
Create an Nginx configuration file for Yarr, say /etc/nginx/sites-available/yarr and add the content below:

```nginx
server {
	listen 80 ;
	listen [::]:80 ;

	server_name rss.example.org ;

	location / {
		proxy_pass http://localhost:7070/;
	}
}
```

Now let's enable the Nginx Yarr site and reload Nginx to make it active.

```sh
ln -s /etc/nginx/sites-available/yarr /etc/nginx/sites-enabled
systemctl reload nginx
```

### Encryption

You can encrypt your yarr subdomain as well. Let's do that with certbot:

```sh
certbot --nginx -d rss.example.org
```

Now you can go to rss.example.org, login and start to add your feeds!

## Contribution
Author: Jppaled -- [jppaled.xyz](https://jppaled.xyz) \-- XMR: `86bVp8bcx1F3y3NsfuTRs6D7FfnDyLomV7dLJmus2YMiY9Aat6W5m8JGwuvH39HKrq3immS7noKq8HeW4gb4BFbyLoz5WSZ`{.crypto}
