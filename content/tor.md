---
title: "Tor"
date: 2021-06-30
icon: 'tor.svg'
tags: ['service']
short_desc: "Set your site up privately on the 'dark web.'"
---

Now that you have a website, why not offer it on a private alternative
such as the onion network?

## Setting up Tor

### Installing Tor

First, we need to ensure that our CPU architecture is supported. Ensure
that it is either amd64, arm64, or i386:

    dpkg --print-architecture

We need to [add the Tor repos to our
system](https://support.torproject.org/apt/tor-deb-repo/) to get the
latest version of Tor:

    apt install -y apt-transport-https gpg
    echo "deb     [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org $(lsb_release -cs) main
    deb-src [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org $(lsb_release -cs) main" > /etc/apt/sources.list.d/tor.list

Then we need to add the GPG keys to our keyring:

    curl -s https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor > /usr/share/keyrings/tor-archive-keyring.gpg

Now install Tor:

    apt update
    apt install tor deb.torproject.org-keyring

### Enabling Tor

Next edit the file `/etc/tor/torrc`, uncommenting the following lines:

    HiddenServiceDir /var/lib/tor/hidden_service/
    HiddenServicePort 80 127.0.0.1:80

#### Optional: Running multiple onion services

If you want to forward multiple virtual ports for a single onion
service, just add more HiddenServicePort lines (replace the 80 with any
unoccupied port).

If you want to run multiple onion services from the same Tor client,
just add another HiddenServiceDir line.

Now start and enable Tor at boot:

     systemctl enable --now tor

If the next command outputs "active" in green you\'re golden!

     systemctl status tor

Now your server is on the dark web. The following command will give you
your onion address:

     cat /var/lib/tor/hidden_service/hostname

## Adding the Nginx Config

From here, the steps are almost identical to setting up a normal website
configuration file. Follow the steps as if you were making a new website
in the webserver [tutorial](/basic/nginx) up until the server block of
code. Instead, paste this:

            server {
                listen 127.0.0.1:80 ;
                root /var/www/landchad ;
                index index.html ;
                server_name your-onion-address.onion ;
            }

#### Clarification

Nginx will listen on port 80 for your *server\'s* localhost.

The `root` line is the path to whichever website of yours you\'d like to
mirror.

Now we are almost done, all we have to do is enable the site and reload
nginx which, is also covered in [the webserver
tutorial](nginx.html#enable).

### Advertise your onion service

You can add the Onion-Location header to your normal website to
advertise your onion service to Tor users. On your regular site\'s nginx
config, add the following line:

    server {
        ...
        add_header Onion-Location http://your-onion-address.onion$request_uri;
    }

After doing this and reloading nginx, when visiting your regular site
via Tor, you should see a \".onion available\" button on the address
bar, which should take you to the onion service.

### Update regularly!

Make sure to update Tor on a regular basis by running:

    apt update
    apt install tor

#### Note:

You do **<u>not</u>** need to run certbot for an ssl certificate.
HTTP over tor is plenty secure!

**Contributor** - [tomfasano.net](https://tomfasano.net)
