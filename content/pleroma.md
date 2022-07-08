---
title: "Pleroma"
date: 2021-07-01
icon: 'pleroma.svg'
tags: ['service','activity-pub']
short_desc: 'A federated Twitter-like microblogging system.'
---
Hopefully by now you won\'t have to be sold on the invasive practices
that social media companies conduct. Websites such as Facebook and
Twitter aquire so much data on users that they often know more about you
than you know about yourself. The simple solution to this is to not use
social media. However, that just isn\'t an option for most people. So
the next best thing is to setup a self-hosted and federalised social
media site so that you have full control over your data. I\'ve
previously made [a video showing all the steps in depth if you want to
check it out.](https://www.youtube.com/watch?v=l7mVsLSsotU) If you run
into any issues I suggest you look at the video.

You\'ll need a server or VPS. Nearly any Operating system is supported
but for this tutorial I\'m gonna presume you\'re using a Debian-based
OS. You\'ll also need a domain name pointing to your server\'s IP
address [which is explained in this tutorial.](/basic/dns)

## Installation

### Setting Up and Configuring

First things first you\'ll need to make sure that you\'ve hardened you
SSH so that password authentication is disabled and you\'ll also want to
setup Fail2Ban. There\'s a great tutorial on how to do this [which can
be read here.](/sshkeys)

Next we\'ll install the required packages:

```sh
apt install -y curl unzip libncurses5 postgresql postgresql-contrib nginx certbot libmagic-dev
```

You can manually configure postgreSQL to suit your system better. [Check
out the documentation
here](https://docs-develop.pleroma.social/backend/configuration/postgresql/)
and then run the below command:

```sh
systemctl restart postgresql
```

### Installing the Pleroma App

#### First as the root user

Pleroma is not in the Debian app repositories, so we will install it
manually. First create the Pleroma user by running the below command:

```sh
useradd -m -s /bin/bash -d /opt/pleroma pleroma
```

Then, still as root, we will create the required directories and give
the Pleroma user ownership of them.

```sh
mkdir -p /var/lib/pleroma/uploads
chown -R pleroma /var/lib/pleroma
mkdir -p /var/lib/pleroma/static
chown -R pleroma /var/lib/pleroma
mkdir -p /etc/pleroma
chown -R pleroma /etc/pleroma
```

#### Now, as the new Pleroma user

Now run `su -l pleroma` to login as the Pleroma user. Now use the `curl`
command below to download the Pleroma software and unzip it.

```sh
curl 'https://git.pleroma.social/api/v4/projects/2/jobs/artifacts/stable/download?job=amd64' -o /tmp/pleroma.zip
unzip /tmp/pleroma.zip -d /tmp/
```

Note that we are downloading the **amd64** version here. If you know you
have a different CPU architecture, replace that with whatever your
architecture is.

```sh
mv /tmp/release/* /opt/pleroma
rmdir /tmp/release
rm /tmp/pleroma.zip
./bin/pleroma_ctl instance gen --output /etc/pleroma/config.exs --output-psql /tmp/setup_db.psql
```

We need to briefly return to the root user so we can run the following
command (via the postgres user) to set up the database. Type <kbd>ctrl-d</kbd> or
run `exit` to return to the root user, then run:

```sh
su postgres -s $SHELL -lc "psql -f /tmp/setup_db.psql"
```

Then return to the pleroma user with `su -l pleroma` and we will test to
see that Pleroma can run:

```sh
./bin/pleroma_ctl migrate
./bin/pleroma daemon
```

That will initialize Pleroma. It might take as long as a minute to get
started, so wait a bit, then run the following:

```sh
curl http://localhost:4000/api/v1/instance
```

If everything is working, this command will give you a long line of
messy output. If it is not, you will get a connection error message.
Once it is working successfully, stop the Pleroma daemon and we will
interface Pleroma with the web server.

```sh
./bin/pleroma stop
```

### Setup and Configure Nginx

Return again to the root user. Let\'s copy Pleroma\'s Nginx
configuration file from the template given in the installation and
enable it:

```sh
cp /opt/pleroma/installation/pleroma.nginx /etc/nginx/sites-available/pleroma.conf
ln -s /etc/nginx/sites-available/pleroma.conf /etc/nginx/sites-enabled/pleroma.conf
```

Edit the `etc/nginx/sites-available/pleroma.conf` file and replace
**example.tld** with your domain name.

We now have to get a SSL certificate to enable encryption, since we have
a model configuration that already includes SSL information, just check
the brief [the standalone certificate page](/standalone) to get the
needed certificate. Once you\'ve got your cert setup, copy over the
Nginx configuration with the below command:

Once everything, including your Cerbot certificate is ready, simply
reload Nginx with this command:

```sh
systemctl reload nginx
```

### Setting up the service

Pleroma itself runs on a SystemD service similar to other things running
on your server like Nginx. To start the service up run the below
commands:

```sh
cp /opt/pleroma/installation/pleroma.service /etc/systemd/system/pleroma.service
systemctl start pleroma
systemctl enable pleroma
```

If everything worked then when you go to your domain in the web browser
you should see a bare-bones Pleroma instance.

### Creating an Admin User

You\'ll be able to create new accounts on the Pleroma instance in the
login section on the website but the easiest way to setup an admin
account is with the CLI. Simply run the below command replaced with your
username:

```sh
su -l pleroma
./bin/pleroma_ctl user new username username@example.org --admin
```

If you run into any issues then [feel free to checkout the
documentation](https://docs-develop.pleroma.social/backend/installation/otp_en/)
or send me an email or message. My details are below.

-   [biasedriot.co](https://biasedriot.co)
-   [youtube](https://www.youtube.com/channel/UCehh50T6qtDpt_kEUF33GJw)
-   Bitcoin: `1Dmn9jEtWAhdLk1HHWkUVNeDdAaBCwNajm`{.crypto}
-   Monero:
    `84Y4FZiTbLeR5qc1fBrBhB1yq5agKtEdoixq2w1ysXJv486MiBCz3czGT15bqeXDPpdLoNyF93inxY3BCk6g8mrDMNKoArS`
