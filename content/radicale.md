---
title: "Radicale"
date: 2021-10-07
pix: 'radicale.svg'
icon: 'radicale.svg'
tags: ['service']
short_desc: 'A private calendar, contact and to-do list system.'
---

Radicale is an open source calDAV server. CalDAV is a widely supported
internet standard for calendars, todo-lists and contacts. Hosting your
own calDAV server allows sharing calendars between mutliple devices.

More information can be found on the projects offical website:
[radicale.org](https://radicale.org/3.0.html).

## Installing Radicale

Firstly, we have to install radicale on our system, luckily for us
radicale is packaged for the most used distros.

```sh
apt install radicale apache2-utils
```

Next we need to configure Radicale. We configure radicale to be
accessible from other machines, how Radicale handles users and where the
files should be stored. Open /etc/radicale/config with your favourite
editor and add this configuration.

```systemd
[server]
# Bind all addresses
hosts = 0.0.0.0:5232, [::]:5232

[auth]
type = htpasswd
htpasswd_filename = /etc/radicale/users
htpasswd_encryption = bcrypt

[storage]
filesystem_folder = /var/lib/radicale/collections
```

As you can see under \[auth\] we use htpasswd to manage the users.
Execute the following command to add a new user to Radicale.

```sh
htpasswd -B -c /etc/radicale/users username
```

As Radicale stands now it is fully functional and after starting it by
executing its binary, can be accessed under example.org:5232. But there
are two additional things we can do to make using and managing Radicale
way easier.

### Setting up a Nginx reverse proxy

Because the URL of your Radicale server is an URL you will have to
remember and enter it on any device you want to use your calendar on it
is advised to set up a reverse proxy.

```nginx
server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name cal.example.org;
    location / {
        proxy_pass http://localhost:5232/; # The / is important!
    }
    # You can also leave these two lines out and use certbot
    ssl_certificate /etc/ssl/nginx/cal.example.com/fullchain.pem;
    ssl_certificate_key /etc/ssl/nginx/cal.example.com/privkey.pem;
}
```

### Run as a service

Running Radicale as a service makes managing it much easier. Add this
config to /etc/systemd/system/radicale.service.

```systemd
[Unit]
Description=A simple CalDAV (calendar) and CardDAV (contact) server

[Service]
ExecStart=/usr/bin/env python3 -m radicale
Restart=on-failure

[Install]
WantedBy=default.target
```

After creating the config load, start and enable the service with the
following commands.

```sh
systemctl daemon-reload
systemctl enable --now radicale
```

## Contribution

Author: Jocomol -- [jocomol.ch](https://jocomol.ch) \-- XMR:
`41kLv68Nk4N3zvTRFYtHZfRRFMgXkxK2FcXDeCSa4yNwBGTBa1WQ8HtXL8cCAcoZ2iSLBCS6HQqdpRSf56ecMBgWTkn2ARt`{.crypto}
