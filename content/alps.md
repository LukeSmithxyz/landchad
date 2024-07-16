---
title: "Alps"
tags: ['service']
icon: 'alps.webp'
short_desc: 'Alps is a simple and extensible webmail. It offers a web interface for IMAP, SMTP and other upstream servers.'
date: 2024-07-16
---


[Alps](https://git.sr.ht/~migadu/alps)
is a webmail client, a program that allows you to access your email
online like Gmail. It is useful to be able to access you email from a
web browser because it allows you to easily access your email from any
device with a web browser without much additional setup.

## Instructions

There is no Debian package so we are going to build it from source. You need to
have a newer Go compiler installed than what is in the Debian repos. You can
follow the [instructions
here](https://www.vultr.com/docs/install-the-latest-version-of-golang-on-Debian/)
to install Go.

Then, we can clone and build alps.

```sh
git clone https://git.sr.ht/~migadu/alps /opt/alps
cd /opt/alps
go build ./cmd/alps
mv alps /usr/local/bin/alps
```

Now, we are going to create a login key with this command.

```sh
go run github.com/fernet/fernet-go/cmd/fernet-keygen
```

Now, we need to create a systemd service to auto start it on boot.

```systemd
[Unit]
Description=Alps Webmail
After=network.target
Wants=network-online.target

[Service]
Restart=always
Type=simple
ExecStart=/usr/local/bin/alps -theme alps -addr 127.0.0.1:1323 -login-key yourloginkey imaps://mail.example.org:993 smtps://mail.example.org:465
WorkingDirectory=/opt/alps
Environment="GOPATH=/opt/alps/.gopath"
Environment="GOCACHE=/opt/alps/.gocache"

[Install]
WantedBy=multi-user.target
```

Put that in `/etc/systemd/system/alps.service` and fill in your login key and your mail domain.

Now, reload and start Alps.

```sh
systemctl daemon-reload
systemctl enable --now alps
```

You will need to have already set up nginx. Add this to a file in `/etc/nginx/sites-available/alps.conf`.

```nginx
server {
    listen 80;

    server_name mail.example.com;

    location / {
            proxy_pass http://localhost:1323;
    }
}
```

Now, link it to `/etc/nginx/sites-enabled/alps.conf` with this command.

```sh
ln -s /etc/nginx/sites-available/alps.conf /etc/nginx/sites-enabled/alps.conf
```

Now, run `certbot` and select your new domain to setup ssl on it.

Finally, you can access your web mail at `mail.example.org` and log in with your email and password.

## Contribution
XMR: `86MMzQFTWgWHdLmJgdUSyKYKitVtgw3Dbfe2hTFeZmSC92FUE7wFcEF5AA4ugqyge4hGdL8PwvZKB49fsGLbUtYdGmNgNU9`
