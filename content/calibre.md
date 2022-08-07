---
title: "Calibre"
date: 2021-08-03
icon: "calibre.png"
short_desc: 'A public or private digital library.'
tags: ['service']
---

The Calibre library server is a great way to store your eBooks. It
allows you to:

-   Share your books with others.
-   Easily transfer your books between devices and access them from
    anywhere.

## Installation

Install the Calibre package. You might also want rsync to upload books.

```sh
apt install -y calibre rsync
mkdir /opt/calibre
```

Either upload your existing library using `rsync`. For example to
`/opt/calibre/`.

```sh
cd ~/Documents
rsync -avuP your-library-dir root@{{<hl>}}example.org{{</hl>}}:/opt/calibre/
```

Or create a library and add a book to it:

```sh
cd /opt/calibre
calibredb add book.epub --with-library your-library
```

For more information about the `calibredb` command see `man calibredb`.

Add a new user to protect your server:

```sh
calibre-server --manage-users
```

## Creating a service

Create a new file `/etc/systemd/system/calibre-server.service` and add
the following:

```systemd
[Unit]
Description=Calibre library server
After=network.target

[Service]
Type=simple
User=root
Group=root
ExecStart=/usr/bin/calibre-server --enable-auth --enable-local-write /opt/calibre/your_library --listen-on 127.0.0.1

[Install]
WantedBy=multi-user.target
```

You can change the port with the `--port` prefix. Additional information
`man calibre-server`.

Issue `systemctl daemon-reload` to apply the changes.

Enable and start the service.

```sh
systemctl enable calibre-server
systemctl start calibre-server
```

## A reverse proxy with Nginx

Create a new file `/etc/nginx/sites-available/calibre` and enter the
following:

```nginx
server {
    listen 80;
    client_max_body_size 64M; # to upload large books
    server_name {{<hl>}}calibre.example.org{{</hl>}} ;

    location / {
        proxy_pass http://127.0.0.1:8080;
    }
}
```

Issue a Let\'s Encrypt certificate. [Detailed instructions and additional information](/certbot).

```sh
certbot --nginx
```

Now just go to **calibre.example.org**. The server will request an
username and a password.

{{< img src="/pix/calibre/calibre-1.png" alt="calibre" >}}


After login you will see something like this.

{{< img src="/pix/calibre/calibre-2.png" alt="calibre" >}}

## Contribution

Author: rflx -- [website](https://rflx.xyz) \-- XMR:
`48T5XpHTXAZ5Nn8YCypA4aWn1ffQLHJkFGDArXQB6cmrP6cqLY72cu7CR2iq2MmL5Ndu3d47e5MKjGpL4prYgdrTCFAHD9c`
