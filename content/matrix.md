---
title: "Matrix Synapse"
date: 2021-07-16
icon: 'element.svg'
tags: ['service']
short_desc: "An encrypted chat server sleek and accessible even to normies."
---

Matrix is easy-to-use, decentralized and encrypted private chat
software. Matrix is federated, meaning that with a Matrix account on any
server, including your own, you can talk to any other Matrix account on
the internet, similar to email. Matrix also allows fully end-to-end
encrypted group chats.

**Synapse** is the name of the default Matrix server. It is written in
Python. While it is requires somewhat more system resources than [an
XMPP server](/prosody), it makes up for that in being very accessible
to non-technical users.

## Installation

Synapse is not in the Debian package repositories by default, but we can
easily add Matrix\'s repository including it:

```sh
apt install -y lsb-release wget apt-transport-https
wget -O /usr/share/keyrings/matrix-org-archive-keyring.gpg https://packages.matrix.org/debian/matrix-org-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/matrix-org-archive-keyring.gpg] https://packages.matrix.org/debian/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/matrix-org.list
```

After we update our packages lists, we will be able to install Synapse
with `apt`.

```sh
apt update
apt install matrix-synapse-py3
```

When prompted, give your main domain name (not a subdomain). This will
be the domain appended to your Matrix address, e.g.
`@chad:landchad.net`.

## Nginx configuration

Create an Nginx configuration file for Matrix, say
`/etc/nginx/sites-available/matrix` and add the content below:

```nginx
server {
        server_name {{<hl>}}matrix.example.org{{</hl>}} ;
        listen 80;
        listen [::]:80;
        location / {
                proxy_pass http://localhost:8008;
        }
        location ~* ^(\/_matrix|\/_synapse\/client) {
                proxy_pass http://localhost:8008;
                proxy_set_header X-Forwarded-For $remote_addr;
                client_max_body_size 50M ;
        }
        location /.well-known/matrix/server {
                return 200 '{"m.homeserver": {"base_url": "https://{{<hl>}}matrix.example.org{{</hl>}}"}}';
                default_type application/json;
                add_header Access-Control-Allow-Origin *;
        }
}
```

Note the `client_max_body_size` variable. By default, Nginx caps the
size of files it can transfer. We increase that to 50M if needed by
Matrix. (Note however that both Matrix and Nginx have seperate settings
for this and to raise it to something much larger, you will have to
increase the value in both configuration files.)

Now let\'s enable the Nginx Matrix site and reload Nginx to make it
active.

```sh
ln -s /etc/nginx/sites-available/matrix /etc/nginx/sites-enabled
systemctl reload nginx
```

### Encryption

Obviously, we need to encrypt our `matrix` subdomain as well. Let\'s do
that with certbot:

```sh
certbot --nginx -d {{<hl>}}matrix.example.org{{</hl>}}
```

## Configuration


### Read the config file

The configuration file for Matrix is in
`/etc/matrix-synapse/homeserver.yaml`. It is well documented and
commented, so you can read about the settings, but let\'s change the
essential ones here.

Make what changes you want and run `systemctl reload matrix-synapse` to
make the system configuration active.

### Create an administrator account

If you allow open registration on your server in the configuration file,
you can create an account through Element or another Matrix client, but
you are probably going to want an official admin account to use. To make
one, simply run the following command, which will then give you several
choices for creating a user, among which will be the ability to make it
an admin.

```sh
cd /etc/matrix-synapse

register_new_matrix_user -c homeserver.yaml http://localhost:8008
```

### Error Shared secret registration is not enabled

Sometimes the default configuration is not fully setup, so you need
to add the following the keys to your `homeserver.yaml`:

- `macaroon_secret_key`
- `registration_shared_secret`

Make sure to restart Matrix Synapse

```sh
systemctl restart matrix-synapse
```

## Using Matrix with ![Element Matrix logo](/pix/element.svg)Element

There are many different [clients](https://matrix.org/clients/) that can
be used on desktops or phones to chat on your Matrix server, but the
most popular and most widely vetted is ![Element
logo](/pix/element.svg)Element.

Get Element to access your Matrix server:

-   Mobile:
    -   [F-droid](https://f-droid.org/packages/im.vector.app/)
    -   [Google
        Play](https://play.google.com/store/apps/details?id=im.vector.app)
    -   [Apple App
        Store](https://apps.apple.com/app/vector/id1083446067)
-   Real computer:
    -   GNU/Linux: You know how to install it.
    -   [Windows](https://packages.riot.im/desktop/install/win32/x64/Element%20Setup.exe)
    -   [Mac](https://packages.riot.im/desktop/install/macos/Element.dmg)

Note also that Element has a web client (i.e. a version that can be
accessed on your own website) that is also easy to install on an Nginx
server, although that will be covered in another article.
