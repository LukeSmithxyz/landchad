---
title: "ejabberd"
date: 2022-03-29
icon: 'ejabberd.png'
tags: ['service']
short_desc: "A chat server based on XMPP."
---

[Ejabberd](https://ejabberd.im) is a server for the XMPP protocol
written in Erlang. It\'s easier to configure and setup than
[Prosody](/prosody) due to having most of its modules built-in and
pre-configured by default.

## Prerequisites

### Subdomains

Ejabberd presumes that you have already created all the **required and
optional subdomains** for its operation prior to running it.

Depending on the usecase, you may need any or all of the following
domains for XMPP functionality:

-   **example.org** - Your XMPP hostname
-   **conference.example.org** - For Multi User Chats (MUCs)
-   **upload.example.org** - For file upload support
-   **proxy.example.org** - For SOCKS5 proxy support
-   **pubsub.example.org** - For publish-subscribe support

This guide will assume **all these subdomains** have been created.

## Installation

Ejabberd is available in the Debian repositories:

```sh
apt install ejabberd
```

## Configuration

The ejabberd server is configured in `/etc/ejabberd/ejabberd.yml`.
Changes are only applied by restarting the ejabberd daemon in systemd:

```sh
systemctl restart ejabberd
```

### Hostnames

The **XMPP hostname** is specified in the `hosts` section of
`ejabberd.yml`:

```yml
hosts:
  - example.org
```

### Certificates

Unlike [Prosody,](https://prosody.im) ejabberd doesn\'t come equipped
with a script that can automatically copy over the relevant certificates
to a directory where the ejabberd user can read them.

One way of organizing certificates for ejabberd is to have them stored
in `/etc/ejabberd/certs`, with each domain having a separate directory
for both the fullchain cert and private key.

Using certbot, this process can be easily automated with these commands:

```sh
$DOMAIN=subdomain.example.org
certbot --nginx -d $DOMAIN certonly; mkdir /etc/ejabberd/certs/$DOMAIN
cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem /etc/ejabberd/certs/$DOMAIN
cp /etc/letsencrypt/live/$DOMAIN/privkey.pem /etc/ejabberd/certs/$DOMAIN
```

This should be ran with your XMPP hostname **(example.org)** and
repeated for all your desired subdomains.

To enable the use of all these certificates in ejabberd, the following
configuration is necessary:

```yml
certfiles:
  - "/etc/ejabberd/certs/*/*.pem"
```

### Admin User

The **admin user** can be specified in `ejabberd.yml` under the `acl`
section:

```yml
acl:
  admin:
    user: admin
```

This would make **admin@example.org** the user with administrator
privileges.

### Message Archives

The ejabberd server supports keeping archives of messages through its
`mod_mam` module. This can be enabled by uncommenting the following
lines:

```yml
mod_mam:
  assume_mam_usage: true
  default: always
```

## Database

### Why use a database?

In the `mod_mam` section of the ejabberd config file, the following
message is in comments:

```yml
mod_mam:
  ## Mnesia is limited to 2GB, better to use an SQL backend
  ## For small servers SQLite is a good fit and is very easy
  ## to configure. Uncomment this when you have SQL configured:
  ## db_type: sql
```

As these comments imply, an **SQL backend** is strongly recommended if
you wish to use your ejabberd server for anything more than just
testing. Ejabberd supports **MySQL, SQLite** and **PostgreSQL.**

While all of those are suitable choices, the best database system to use
is PostgreSQL. It\'s the same database backend used by
[PeerTube](/peertube) and [Matrix](/matrix), making it the most
convenient option if you\'re already running those too.

### Installing PostgreSQL

PostgreSQL is available in the Debian repositories:

```sh
apt install postgresql
```

Start the PostgreSQL daemon to begin using it:

```sh
systemctl start postgresql
```

### Creating the Database

To create the database, first create a PostgreSQL user for ejabberd:

```sh
su -c "createuser --pwprompt ejabberd" postgres
```

Then, create the database and make `ejabberd` its owner:

```sh
su -c "psql -c 'CREATE DATABASE ejabberd OWNER ejabberd;'" postgres
```

### Importing Database Scheme

Ejabberd doesn\'t create the database scheme by default; It has to be
imported into the database before use.

```sh
su -c "curl -s https://raw.githubusercontent.com/processone/ejabberd/master/sql/pg.sql | psql ejabberd" postgres
```

### Configuring ejabberd to use PostgreSQL

Finally, add the following configuration to `ejabberd.yml`:

```yml
sql_type: pgsql
sql_server: "localhost"
sql_database: "ejabberd"
sql_username: "ejabberd"
sql_password: "psql_password"
```

Once you\'ve ensured your database name, username and password are all
correct, enable SQL storage for `mod_mam`:

```yml
mod_mam:
  ## (Other parameters)
  db_type: sql
```

## Using ejabberd

### Registering the Admin User

To begin using ejabberd, firstly start the ejabberd daemon:

```sh
systemctl restart ejabberd
```

Then, using `ejabberdctl` as the ejabberd user, register the admin user
which is set in `ejabberd.yml`:

```sh
su -c "ejabberdctl register admin example.org password" ejabberd
```

This will create the user **admin@example.org.**

### Using the Web Interface

By default, ejabberd has a web interface accessible from
**http://example.org:5280/admin**. When accessing this interface, you
will be prompted for the admin credentials:

{{< img src="/pix/ejabberd-login.jpg" >}}

After signing in with the admin credentials, you will be able to manage
your ejabberd server from this web interface:

{{< img src="/pix/ejabberd-admin.jpg" >}}

## TURN & STUN for Calls

Ejabberd supports the **TURN** and **STUN** protocols to allow internet
users behind NATs to perform voice and video calls with other XMPP
users.

Firstly, setup a TURN and STUN server with [Coturn,](/coturn) using
an **authentication secret.**

Then, edit `mod_stun_disco` to contain the appropriate information for
your turnserver:

```yml
  mod_stun_disco:
    secret: "your_auth_secret"
    services:
      -
        host: turn.example.org
        type: stun
      -
        host: turn.example.org
        type: turn
```

And with that, you\'ve successfully setup your ejabberd XMPP server!

------------------------------------------------------------------------

*Written by [Denshi.](https://denshi.org) Donate Monero
[here](https://denshi.org/donate.html)
[\[QR\]](https://denshi.org/images/monero.jpg)*
