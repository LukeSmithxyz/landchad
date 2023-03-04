---
title: "Prosody"
date: 2022-04-03
icon: 'prosody.svg'
tags: ['service']
short_desc: 'A minimalist XMPP chat server.'
---

XMPP is a fantastically simple protocol that's usually used as a messenger. It's highly extensible, better than IRC, lighter and more decentralized than Matrix, and normie social media like Telegram can't hold a candle to it.

XMPP is so decentralized and extensible that there are many [*different*](/ejabberd) XMPP servers. Here, let's set up a [Prosody](https://prosody.im/) XMPP server.

## Installation

To install Prosody, first add the official Prosody repositories for Debian:

```sh
# Install extrepo if you already haven't
apt install extrepo
extrepo enable prosody
apt update
```
Then, install Prosody:

```sh
apt install prosody
```

## Configuration

The Prosody configuration file is in `/etc/prosody/prosody.cfg.lua`. To set it all up, we will be changing several things.

### Setting Admins

Let's go ahead and set who our admin(s) will be. Find the line that says `admins = { }` and to this we can specify one or more server admins.

```cfg
# To add one admin:
admins = { "chad@example.org" }

# We can add more than one by separating them by commas. (This file is written in Lua.)
admins = { "chad@example.org", "chadmin@example.org" }
```

Note that we have not created these accounts yet, we will do this [below](#user).

### Set the Server URL

Find the line `VirtualHost "localhost"` and replace `localhost` with your domain. In our case, we will have `VirtualHost "example.org"`

### Multi-User Chats

Most people will probably want the ability to have chats with more than two users. This is easily enough to enable. In the config file, add the following:

```cfg
Component "chat.example.org" "muc"
    modules_enabled = { "muc_mam" }
    restrict_room_creation = "admin"
```

On the first line, you must have a separate subdomain for your multi-user chats. I use the `chat.` subdomain, but some use `muc.`. Anything is possible.

The second line is important because it prevents non-admins from creating and squatting rooms on your server. The only situation where you might not want that is if you indend to open a general public chat system for people you don't know.

Read more about the `muc` plugin on the Prosody documentation page [here](https://prosody.im/doc/modules/mod_muc).

### Enabling chat histories

By default, Prosody will send out messages received only to the first available clients.
That means that if you have your desktop client turned off and your cell phone receives a message,
it will *not* be available to the desktop client when you start it.

While this may be preferred in some cases,
enable the `mam` module (Message Archive Management) to have the server hold on messages and sync them to all clients.

Within the `modules_enabled` block, you can uncomment the `mam` line to enable it.
You can see other settings for this module [here](https://prosody.im/doc/modules/mod_mam)
like, for example, how long a server should hold on to message histories for synching.

Note also that Prosody comes with the `carbons` activated module by default, which is related.
This will send received messages to *all* active clients (your phone and desktop),
although it will not save messages like MAM for clients not online or to be added later.

### File sharing

With this we can bring XMPP to the level of other popular instant messaging applications like Matrix and whatsapp.
It is extremely easy to setup.
This part is optional, but it can make XMPP more normie-friendly if you plan on moving family members and friends over to XMPP.

First we need to install extra prosody modules. Run the following command:

```sh
apt install prosody-modules
```

Then we can add the following line to you prosody config file to enable file uploads:

```cfg
Component "uploads.example.org" "http_upload"
```

As you will notice, you need another subdomain for this. We will add an ssl certficate for this later.

You will also need to go back to `modules_enabled` and uncomment the `http_files` module.
This is used to actually serve the files to users.

And the last part of the setup is to enable the built in proxy server.
This helps with file transfers for devices behind a NAT, and unless you are using XMPP in a LAN, you probably need this.
Enable the proxy by adding the following line to the config:

```cfg
Component "proxy.example.org" "proxy65"
```

As you can see, another subdomain is needed. We will add ssl certificates for this later.

At this point, file sharing is now setup and ready to be used. Although there are some concerns that should be addressed.

A big concern with file sharing is large files, seeing as all files shared over XMPP will be stored on your server. This can become a problem when many (and large) files are being shared. We can put a cap on large files by adding the following line to our config:

```cfg
http_upload_file_size_limit = 20971520
```

This puts a 20MB cap on all files being shared. The value is specified in bytes. You can also specify after how long files should be deleted by adding the following line:

```cfg
http_upload_expire_after = 60 * 60 * 24 * 7
```

The value is specified in seconds. The above line will make prosody delete files after a week.

If it is for some reason neccessary, you can also manually invoke expiry with the following command:

```cfg
prosodyctl mod_http_upload expire
```

### Database Setup

Prosody includes the `internal` and `sql` storage backends by default. If you wish to run Prosody with PostgreSQL, edit the following lines:

```cfg
storage = "sql"

sql = {
    driver = "PostgreSQL",
    database = "{{<hl>}}prosody{{</hl>}}",
    username = "{{<hl>}}prosody{{</hl>}}",
    password = "{{<hl>}}password{{</hl>}}",
    host = "localhost"
}
```

(This is assuming you've installed the `postgresql` package, and setup a database named `prosody` with a user named `prosody` as the owner.)

### Other things to check

Check the config file for other settings you might want to change. For example, if you want to run a general public XMPP server, you can allow anyone to create an account by changing `allow_registration` to `true`.

Another thing you can do is enable the `csi_simple` module, which will add some optimizations for mobile devices.

Another thing worth noting is the `archive_expires_after = "1w"` line. This specifies after how long message archives will be deleted.

Also the `smacks` module helps a lot with slow internet connections.

## Certificates

Obviously, we want to have client-to-server and server-to-server encryption. Nowadays, use can use Certbot to generate certificates and use a convenient command below `prosodyctl` to import them.

**If you have multi-user chat enabled, be sure to get a certificate for that subdomain as well.** Include the `--nginx` option assuming you have an Nginx server running.

```sh
certbot -d chat.example.org --nginx
```

**If you have file sharing enabled, be sure to get a certificate for those subdomains as well.**

```sh
certbot -d uploads.example.org --nginx
certbot -d proxy.example.org --nginx
```

Once you have the certificates for encryption, run the following to import them into Prosody.

```sh
prosodyctl --root cert import /etc/letsencrypt/live/
```

Note that you might get an error that a certificate has not been found if your `muc` subdomain and your main domain share a certificate. It should still work, this is just notifying you that no specific certificate for the subdomain.

**Note:** The above command will need to be rerun when certificates are renewed. You may want to create a [cronjob](/cron) to have this done automatically.

## Creating users/admins manually {#user}

Let's manually create the admin user we prepared for above. Note that you can indeed do this in your XMPP client if you have not disabled registration, but this is how it is done on the command line:

```sh
prosodyctl adduser chad@example.org
```

This will prompt you to create a password as well.

## Make changes active

With any system service, use `systemctl reload` or `systemctl restart` to make the new settings active:

```sh
systemctl restart prosody
```

## Using your Server!

Once your server is set up, you just need an XMPP client to use your new and secure chat system.

-   GNU/Linux: [Dino](https://dino.im/) or [Gajim](https://gajim.org/)
-   Windows: [Gajim](https://gajim.org/) also runs on Windows.
-   Android: [Conversations.im](https://conversations.im/) or
    [snikket](https://snikket.org/)
-   Mac/iOS: [Monal IM](https://monal.im/) or
    [Siskin](https://siskin.im/) for iOS alone
-   command-line (GNU/Linux, MacOS, Windows):
    [Profanity](https://profanity-im.github.io/)
-   [See a more complete list kept by
    XMPP](https://xmpp.org/software/clients.html)

Install whichever of these clients you want on your computer or phone and you can log into your new XMPP server with the account you made. Note that if you enabled public registration, anyone can create an account on your server through one of these clients.

### Account addresses

XMPP account addressed look just like email addresses: `username@example.org`. You can message any account on any XMPP server on the internet with that format.

### Note on MUCs (multi-user chats)

Remember that MUCs are kept on a separate subdomain that we created and should've gotten a certificate for above, for example, `chat.example.org`. Chatrooms are created and referred to in the following format: `#chatroomname@chat.example.org`.

### Note on firewalls and opening ports

If you use a firewall, you should open ports 5222 and 5281. The first one is needed for clients to be able to connect to your server. The second is only necessary if you are using the `http_upload` module for file sharing.

A complete list of ports used by Prosody can be found [here](https://prosody.im/doc/ports).
