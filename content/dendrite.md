---
title: "Matrix Dendrite"
date: 2023-03-21
icon: 'element.svg'
tags: ['service']
short_desc: "A faster server implementation of Matrix."
---

The Matrix protocol's default implementation, [Synapse,](/matrix) is very memory and processor hungry, mostly due to it being written in the *interpreted Python programming language.* This means that running Synapse on less powerful servers may **take a lot of resources away** from other services. If you need a more efficient and less memory-intensive but still fully functional Matrix server, then [Dendrite](https://github.com/matrix-org/dendrite) is for you.

## Prerequisities

### DNS Records and Delegation

You are **not required** to run a Matrix server under a subdomain (like **matrix.example.org**), regardless of server software. You can run your server under **example.org** to ensure usernames and rooms look like `@user:example.org` and `#room:example.org` respectively.

Because Matrix uses **HTTP** for transport over the SSL ports (443 and 8448), you'll have to configure NGINX for it to work. This can cause confusion, especially if you're running both a [static website](/basic/nginx/) and Matrix server under the same domain (like **example.org**).

Depending on your setup, there are 2 different configurations to achieve this:

1. Your *desired* domain (**example.org**) has an [A DNS record](http://localhost:1313/basic/dns/) that already poinst to your desired Matrix server, so you can configure this or add to your existing NGINX static site configuration to setup Matrix.

2. You wish to use Matrix with your *desired* domain (**example.org**) but this domain's A record points to a different server, accessible through another domain (like **matrix.example.org**). In this case, look into [delegation.](https://matrix-org.github.io/synapse/latest/delegate.html)
 

### NGINX Configuration

Here's an example configuration for a Matrix server running under **example.org:**

```nginx
server {
        server_name {{<hl>}}example.org{{</hl>}};

        listen 80;
        listen [::]:80;

        listen 443 ssl http2 default_server;
        listen [::]:443 ssl http2 default_server;

        listen 8448 ssl http2 default_server;
        listen [::]:8448 ssl http2 default_server;

        location ~* ^(\/_matrix|\/_synapse|\/_client) {
                proxy_pass http://localhost:8008;
                proxy_set_header X-Forwarded-For $remote_addr;
                client_max_body_size {{<hl>}}50M{{</hl>}};
        }

        # These sections are required for client and federation discovery
        # (AKA: Client Well-Known URI)
        location /.well-known/matrix/client {
                return 200 '{"m.homeserver": {"base_url": "https://{{<hl>}}example.org{{</hl>}}"}}';
                default_type application/json;
                add_header Access-Control-Allow-Origin *;
        }

        location /.well-known/matrix/server {
                return 200 '{"m.server": "{{<hl>}}example.org{{</hl>}}:443"}';
                default_type application/json;
                add_header Access-Control-Allow-Origin *;
        }
}
```

Let's say you also want to run a **static website** under **example.org.** This can be achieved by adding these usual lines under the `server` section:

```nginx
		# Basic static site configuration, like any other site
		root /var/www/{{<hl>}}example.org{{</hl>}};
		index index.html;		

		location / {
                try_files $uri $uri/ =404;
        }
```

#### Certbot Certificates

Finally, make sure to download and enable TLS certificates for this setup by using the `certbot` command:

```sh
certbot --nginx -d {{<hl>}}example.org{{</hl>}}
```

## Installation

Dendrite has no official distribution packages at the time of writing. To install and run it, you must first install *the Go programming language* and then compile the Dendrite software from source.

### Installing Go

First, download the latest Go tarball:
```sh
curl -fLO "https://dl.google.com/go/$(curl https://go.dev/VERSION?m=text).linux-amd64.tar.gz"
```

Then, extract the contents to `/usr/local`, which will create the directory `/usr/local/go`:
```sh
tar -C /usr/local -xzfv go*.tar.gz
```

Then finally, make sure the `/usr/local/go/bin/` path is accessible in the `$PATH` variable for every user by editing `/etc/profile` and adding the following line:

```sh
export PATH=$PATH:/usr/local/go/bin
```

### Compiling and Installing Dendrite

Besides Go, we also need the `build-essential` package to compile software:

```sh
apt install build-essential
```

Now download the Dendrite repository using `git` and change directory to it:

```sh
git clone https://github.com/matrix-org/dendrite
cd dendrite
```
Finally, run the `./build.sh` script to compile Dendrite:

```sh
./build.sh
```

*This might take a few minutes,* but once the process is finished you should find the final Dendrite programs populating the `bin/` directory.

## Configuration

To configure Dendrite, begin by coping the `dendrite-sample.yaml` configuration file to `dendrite.yaml`:

```sh
cp dendrite-sample.yaml dendrite.yaml
```

To configure your domain, edit the following under the `global:` section:

```yaml
server_name: {{<hl>}}example.org{{</hl>}}
```

### Server Signing Keys

Generate the signing keys used by your homeserver with the following command, ran from the Dendrite repository:

```sh
./bin/generate-keys --private-key matrix_key.pem
```

You can also import old keys from Synapse, by specifying their file path in the `old_private_keys:` variable in `dendrite.yaml`.

### Database Configuration

By default, Dendrite will create SQLite databases for all its various components. On most server deployments however, it is beneficial to run Dendrite with a more efficient database backend, like PostgreSQL.

Begin by installing PostgreSQL:

```sh
apt install postgresql
```

Then start the daemon:

```sh
systemctl restart postgresql
```

Now create a user named `dendrite` to manage your database:

```sh
su -c "createuser --pwprompt dendrite" postgres
```

And finally, create the actual database:

```sh
su -c "psql -c 'CREATE DATABASE dendrite ENCODING 'UTF8' LC_COLLATE='C' LC_CTYPE='C' template=template0 OWNER dendrite;'" postgres
```

Now we can configure this in `dendrite.yaml` using the `connection_string:` option under the `database:` section:

```yaml
  database:
    connection_string: postgres://dendrite:{{<hl>}}password{{</hl>}}@localhost/dendrite?sslmode=disable
    max_open_conns: 90
    max_idle_conns: 5
    conn_max_lifetime: -1
```

**Important:** If you find `database:` sub-sections under the individual Dendrite modules in `dendrite.yaml` (`app_service_api`, `federation_api`, `key_server`, `media_api`, `mscs`, `room_server`, `sync_api` and `user_api`), make sure to **comment these out** as these would override the global `database` configuration.

### Voice and Video Calls

Dendrite supports native voice and video calling by connecting to a compatible TURN and STUN server.

Begin by setting up the [coturn](/coturn) TURN server using the guide provided, setting either a shared secret or a username-password pair for authentication.

Then edit the `turn:` section in `dendrite.yaml`:

```yaml
  turn:
    turn_user_lifetime: "5m"
    turn_uris:
      - turn:{{<hl>}}turn.example.org{{</hl>}}?transport=udp
      - turn:{{<hl>}}turn.example.org{{</hl>}}?transport=tcp

    turn_shared_secret: "{{<hl>}}your_shared_secret{{</hl>}}"

    # If your TURN server requires static credentials, then you will need to enter
    # them here instead of supplying a shared secret. Note that these credentials
    # will be visible to clients!
    # turn_username: ""
    # turn_password: ""
```

### File Directory and Ownership

Like [Synapse,](/matrix) it's recommended you place the Dendrite program files in `/opt` to keep your server organized:

```sh
mv dendrite/ /opt/
```

It's also recommended you create a `dendrite` user, who will own the `/opt/dendrite` directory, so it can be used to run Dendrite as a service:

```sh
useradd dendrite -d /opt/dendrite
chown -R dendrite:dendrite /opt/dendrite
```

### Setting up a systemd Service

Now setup a **systemd service** to run Dendrite automatically for you. Make sure to set the `WorkingDirectory` to the directory where your Dendrite repository is located!

```systemd
[Unit]
Description=Dendrite (Matrix Homeserver)
After=syslog.target
After=network.target
After=postgresql.service ## Remove this if you're not using PostgreSQL

[Service]
Environment=GODEBUG=madvdontneed=1
RestartSec=2s
Type=simple
User={{<hl>}}dendrite{{</hl>}}
Group={{<hl>}}dendrite{{</hl>}}
WorkingDirectory={{<hl>}}/opt/dendrite/{{</hl>}}
ExecStart={{<hl>}}/opt/dendrite/bin/dendrite{{</hl>}}
Restart=always
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
```

Refresh the systemd daemon configuration by running:

```sh
systemctl daemon-reload
```

And finally, **run Dendrite** by running:

```sh
systemctl restart dendrite
```

## Using Dendrite

### Creating Users

To create users on the Dendrite server, first ensure it is running. Then, enter a secret value into the `registration_shared_secret:` field under the `client_api` section:

```yaml
registration_shared_secret: "your_secret_string"
```

 Then, use the `./bin/create-account` tool located in its repository:

```sh
./bin/create-account -config dendrite.yaml -username {{<hl>}}user{{</hl>}} -admin 
```
This will automatically prompt you for a password.

Congratulations! You've installed the Matrix Dendrite homeserver. Now you can login with any [Matrix client](https://matrix.org/clients/) you wish, and chat securely.

---
Written by [Denshi.](https://denshi.org)
Donate Monero at:
`48dnPpGgo8WernVJp5VhvhaX3u9e46NujdYA44u8zuMdETNC5jXiA9S7JoYMM6qRt1ZcKpt1J3RZ3JPuMyXetmbHH7Mnc9C`
