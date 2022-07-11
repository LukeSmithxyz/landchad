---
title: "PeerTube"
date: 2021-07-31
icon: 'peertube.svg'
tags: ['service','activity-pub']
short_desc: 'Your own self-hosted video-site also compatible with Activity Pub.'
---

PeerTube is a self-hosted and (optionally) federated video sharing
platform that saves bandwith on videos the more people watch. PeerTube
instances can follow each other to share videos and grow the federated
network, but you can always keep your instance to yourself if you choose
to.

## Note on Bandwidth

Video sharing is the most bandwidth intensive thing on the internet! If
you plan on just having a small personal site with a few viewers and
friends, that won\'t be a big concern, but most VPS providers like Vultr
have caps on how much bandwidth can be used within a month without being
throttled. This level is far beyond what most sites need, but it might
be an issue with a video site!

So if you plan on having a big video-sharing PeerTube site, it\'s a good
idea to host it with a provider that offers infinite bandwidth. I
strongly recommend getting a separate VPS with
[Frantech/BuyVM](https://my.frantech.ca/aff.php?aff=3886). They have
unmetered bandwidth, extremely cheap block storage for hosting many,
many videos and they even have a good record of being censorship
resistant.

## Prerequisites

**Most** of PeerTube\'s dependencies can be installed with this command:

```sh
apt install -y curl sudo unzip vim ffmpeg postgresql postgresql-contrib g++ make redis-server git python-dev cron wget
```

It\'s also important to start all associated daemons:

```sh
systemctl start postgresql redis
```

PeerTube also requires **NodeJS 14** and **yarn** which cannot be
installed from the Debian repositories. This means they have to be
installed from separate, external repos:

```sh
curl -fsSL https://deb.nodesource.com/setup_14.x | bash -
apt install -y nodejs
npm install --global yarn
```

Now we create a PeerTube user to run and handle PeerTube with the proper
permissions:

```sh
useradd -m -d /var/www/peertube -s /bin/bash -p peertube peertube
```

## Database

PeerTube requires a PostgreSQL database to function. To create it, first
make a new Postgres user named PeerTube:

```bash
su -l postgres
createuser -P peertube
createdb -O peertube -E UTF8 -T template0 peertube_prod
psql -c "CREATE EXTENSION pg_trgm;" peertube_prod
psql -c "CREATE EXTENSION unaccent;" peertube_prod
exit
```

Be sure to **make note of your Postgres user password,** as it will be
needed later when setting up PeerTube.

## Installation

Using `su -l`, we will become the PeerTube user to create the required
directories and download and install PeerTube itself with the proper
permissions. First, we create the required directories.

```sh
su -l peertube
mkdir config storage versions
chmod 750 config
```

### Downloading PeerTube

Still as the PeerTube user, we can now check for the most recent
PeerTube versions number, download and install it in the newly created
`versiond` directory.

```bash
VERSION=$(curl -s https://api.github.com/repos/chocobozzz/peertube/releases/latest | grep tag_name | cut -d '"' -f 4)
cd /var/www/peertube/versions
wget "https://github.com/Chocobozzz/PeerTube/releases/download/${VERSION}/peertube-${VERSION}.zip"
unzip peertube-${VERSION}.zip
rm peertube-${VERSION}.zip
```

### Installation via Yarn

The downloaded release can then be symbolically linked to
`/var/www/peertube/peertube-latest` and **yarn** is used to install
PeerTube:

```sh
cd /var/www/peertube
ln -s versions/peertube-${VERSION} ./peertube-latest
cd ./peertube-latest
yarn install --production --pure-lockfile
```

## Configuration

PeerTube\'s default config file can be copied over to
`/var/www/peertube/config/production.yaml` so it can actually be used:

Note that we are still running these as the PeerTube user (having run
`su -l peertube`).

```sh
cd /var/www/peertube
cp peertube-latest/config/production.yaml.example config/production.yaml
```

Now the `production.yaml` file must be edited in the following ways:

First, add the hostname:

```yaml
webserver:
  https: true
  hostname: 'example.org'
  port: 443
```

Then, the database:

```yaml
database:
  hostname: 'localhost'
  port: 5432
  ssl: false
  suffix: '_prod'
  username: 'peertube'
  password: 'your_password'
  pool:
     max: 5
```

An email to generate the admin user:

```yaml
admin:
  # Used to generate the root user at first startup
  # And to receive emails from the contact form
  email: 'chad@example.org'
```

And **optionally,** email server information:

```yaml
smtp:
  # smtp or sendmail
  transport: smtp
  # Path to sendmail command. Required if you use sendmail transport
  sendmail: null
  hostname: mail.example.org
  port: 465 # If you use StartTLS: 587
  username: your_email_username
  password: your_email_password
  tls: true # If you use StartTLS: false
  disable_starttls: false
  ca_file: null # Used for self signed certificates
  from_address: 'admin@example.org'
```

At this point, we have done all we need to do as the PeerTube user. Run
`exit` or press <kbd>Ctrl-d</kbd> to log out and return to the root prompt where
we will configure Nginx and other system settings.

## Certbot

First, we will want a Certbot SSL certificate to encrypt connections to
our PeerTube instance. Just run the following:

```sh
certbot --nginx -d peertube.example.org certonly
```

## Nginx

PeerTube includes an Nginx configuration that can be copied over to
`/etc/nginx/sites-available:`

```sh
cp /var/www/peertube/peertube-latest/support/nginx/peertube /etc/nginx/sites-available/peertube
```

Because the PeerTube config is so long, it\'s recommended to use `sed`
to modify the contents of the file, replacing `${WEBSERVER_HOST}` with
your hostname, and `$(PEERTUBE_HOST)` with your localhost and port,
which by default should be `127.0.0.1:9000`:

```sh
sed -i 's/${WEBSERVER_HOST}/example.org/g' /etc/nginx/sites-available/peertube
sed -i 's/${PEERTUBE_HOST}/127.0.0.1:9000/g' /etc/nginx/sites-available/peertube
```

Once you\'re happy with the Nginx config file, link it to
`sites-enabled` to activate it:

```sh
ln -s /etc/nginx/sites-available/peertube /etc/nginx/sites-enabled/peertube
```

## Running PeerTube

A config file for a systemd daemon is included in PeerTube and can be
setup and started like so:

```sh
cp /var/www/peertube/peertube-latest/support/systemd/peertube.service /etc/systemd/system/
systemctl daemon-reload
systemctl start peertube
```

PeerTube will take a minute or so to start, but after it does, you can check
its status with `systemctl status peertube` and at this point, your
PeerTube site should be live!

## Using PeerTube

To set a password for your admin user, run:

```sh
cd /var/www/peertube/peertube-latest
NODE_CONFIG_DIR=/var/www/peertube/config NODE_ENV=production npm run reset-password -- -u root
```

Login to your PeerTube instance using the admin email specified in your
`production.yaml` file and the admin password you just set.

{{< img alt="PeerTube login" src="/pix/peertube-login.jpg" >}}

Once logged in, it\'s recommended to create a separate user without
admin privileges for uploading videos to PeerTube. This can be done
easily from the users tab in the administration section.

Enjoy your PeerTube instance!

------------------------------------------------------------------------

## Updating PeerTube

PeerTube is constantly adding new features, so it\'s a good idea to
[check for new
updates](https://github.com/Chocobozzz/PeerTube/blob/develop/CHANGELOG.md)
and add them if you wish. Just in the past year, they have added
livestreaming and more.

Updating is fairly easy now since an `upgrade.sh` script has been added.
Just run:

```sh
cd /var/www/peertube/peertube-latest/scripts && sudo -H -u peertube ./upgrade.sh
```

Although check the
[changelog](https://github.com/Chocobozzz/PeerTube/blob/develop/CHANGELOG.md)
to see if there are additional manual requirements for particular
updates.

------------------------------------------------------------------------

*Written by [Denshi.](https://denshi.org) Donate Monero
[here](https://denshi.org/donate.html)
[\[QR\]](https://denshi.org/images/monero.jpg)*
