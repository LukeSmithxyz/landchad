---
title: "Libarian"
date: 2022-10-29T17:35:42+02:00
icon: 'librarian.svg'
tags: ['service']
short_desc: "A selfhosted forntend for odysee.com"
---
## About Librarian

Libarian is a frontend for odysee.com, it is a lightweight application that does not spy on you and respects your privacy.
There are no ads, trackers, or any crypto shit.



The Odysee or LBRY tos has gotten an E rating on the site [tosdr.org](https://tosdr.org/en/service/2391).
The Terms of service states that it is allowed to sell your data to third parties,
And that they can use your data to marketing purposes. Aka manipulate you into watching more videos so they can gather more data on you and then sell that.
{{< img src="/pix/lbryRating.svg" alt="Odysee Rating" >}}
A loose-win situation and you are the one who loses.


Librarian mitigates this by not collecting or sending any data.

## Installing dependencies


first of all we have to download and install the latest version of go

DO NOT DOWNLOAD GO VIA APT

```sh
wget https://go.dev/dl/go1.17.4.linux-amd64.tar.gz
tar -C /usr/local -xzf go*.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
source ~/.profile
```
We have now installed go

Now we have to install the dependencies

```sh
apt install nodejs npm git wget
```
## Installing and building Librarian
Now we have to download the source code for librarian

```sh
git clone https://codeberg.org/librarian/librarian
cd librarian
go build .
```

Now we have to configure librarian

```sh
cp config.example.yml config.yml
vim config.toml
```
For most people the default config shuld be fine
### Running Librarian

To run librarian we have to create a systemd service

```sh
vim /etc/systemd/system/librarian.service
```
Then we have to paste the following

```ini
# Contents of /etc/systemd/system/librarian.service
[Unit]
Description=Librarian
After=network.target

[Service]
Type=simple
Restart=on-failure
ExecStart=/root/librarian/librarian

[Install]
WantedBy=multi-user.target
```
## NGINX
Now we have to set up a reverse proxy on nginx

```sh
vim /etc/nginx/conf.d/librarian.conf
```
Then paste the following
```nginx
server {
	listen 80;
	listen [::]:80;
	server_name {{<hl>}}lbry.example.com{{</hl>}} ;
	location / {
		proxy_pass http://127.0.0.1:3000;
	}
}
```
Now reload nginx

```sh
systemctl reload nginx
```

You sould now be able to see librarian at {{<hl>}} lbry.example.com {{</hl>}}

To get https run certbot

```sh
certbot --nginx
```

The website should be up and running now

## Automatic redirect to your instance
This feature is not optional, but if you are trying to quit odysee this is a must.

If you want to make the site redirect you when you click on a odysee link you have to add the following to tamper-/grease-/[violentmonkey (RECORMENDED)](https://addons.mozilla.org/en-US/firefox/addon/violentmonkey/)

```js
// ==UserScript==
// @name Odysee Redirector
// @namespace -
// @version 9.0.0
// @description Redirects you from proprietary web-services to ethical alternatives(front-end).
// @author LalleSX
// @include *odysee.com/*
// @run-at document-start
// @license GPL-3.0-or-later
// @grant none
// ==/UserScript==
var url = new URL(location.href),

librarian = '{{<hl>}}lbry.example.com{{</hl>}}';

if(location.host.indexOf('odysee.com') != -1){
    location.replace('https://' + librarian + location.pathname + location.search)
}
```
------------------------------------------------------------------------
Written by [LalleSX](https://github.com/LalleSX)

Donate to Luke Smith [Here](https://lukesmith.xyz/donate/)
