---
title: "Jitsi"
date: 2021-07-31
icon: "jitsi.svg"
tags: ['service']
short_desc: "Video-chat software."
---

<dfn>Jitsi</dfn> is a set of open-source projects that allows you to easily
build and deploy secure video conferencing solutions.

Is really easy to install, and also a really good private, federated and
libre alternative to Zoom or other video conferencing software. You can
create calls just by typing the URL, and loging-in is not necessary.

## Dependencies and Installation

First, install some dependencies:

```sh
apt install gpg apt-transport-https nginx python3-certbot-nginx
```

Jitsi has its own package repository, so let\'s add it.

```bash
curl https://download.jitsi.org/jitsi-key.gpg.key | gpg --dearmor > /usr/share/keyrings/jitsi-keyring.gpg
echo 'deb [signed-by=/usr/share/keyrings/jitsi-keyring.gpg] https://download.jitsi.org stable/' > /etc/apt/sources.list.d/jitsi-stable.list
apt update -y
```

Ok. So now we can install Jitsi, but before we do that, let\'s setup the
firewall `ufw`, in case you have it enabled, and the SSL certificate.

## Enable Required Ports

If you are using [ufw](/ufw) or another firewall, there are several
ports we need to ensure are open:

```sh
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 10000/udp
ufw allow 3478/udp
ufw allow 5349/tcp
ufw enable
```

For your information, these allow the following:

- 80 TCP -- Certbot.
- 443 TCP -- General access to Jitsi Meet.
- 10000 UDP -- General network video/audio communications.
- 3478 UDP -- Quering the stun server ([Coturn](/coturn), optional, needs config.js change to enable it).
- 5349 TCP -- Fallback network video/audio communications over TCP (when UDP is blocked for example), served by [Coturn](/coturn).

## SSL certificate

I\'ll be using [certbot](/basic/certbot) and
[Nginx](/basic/nginx) to generate a certificate for the
Jitsi subdomain to allow encrypted connections.

```sh
certbot --nginx certonly -d {{<hl>}}meet.example.org{{</hl>}}
```

We will not create an Nginx config file for Jitsi because the Jitsi
package we will be installing will do that automatically.

## Installation

To begin the installation process, just run:

```sh
apt install jitsi-meet
```

It will ask you for your `hostname`; there you\'ll need to input the
subdomain you have just added to Nginx, like `{{<hl>}}meet.example.org{{</hl>}}`.

For the SSL certificate, choose `I want to use my own certificate`.

When it ask you for the certification key and cert files, input
`/etc/letsencrypt/live/{{<hl>}}meet.example.org{{</hl>}}/privkey.pem` and
`/etc/letsencrypt/live/{{<hl>}}meet.example.org{{</hl>}}/fullchain.pem` respectively.

## Using Jitsi

{{< img alt="Jitsi once installed" src="/pix/jitsi-01.webp" >}}

Jitsi can be used in a browser by then just going to `{{<hl>}}meet.example.org{{</hl>}}`.

Note that there are also Jitsi clients for all major platforms:

-   [Desktop](https://desktop.jitsi.org/Main/Download.html) (Windows,
    MacOS, GNU/Linux)
-   Android ([F-Droid](https://f-droid.org/en/packages/org.jitsi.meet/)
    and [Google
    Play](https://play.google.com/store/apps/details?id=org.jitsi.meet))
-   [iPhone/iOS](https://apps.apple.com/us/app/jitsi-meet/id1165103905)

**When using a Jitsi app for the first time, remember to go to the
\"Settings\" menu and change your server name to the Jitsi site you just
created.**

When you create a video chatroom, its address will appear as
`meet.example.org/yourvideochatname` and can be shared as such.

## Security

By default, anyone who has access to **meet.example.org** will be able
to create a chatroom. You probably don\'t want that, so you\'ll need to
set up some authentication. The simplest option is to handle
authentication through the local [Prosody](/prosody) user
database.

### Prosody configuration

First, we need to enable password authentication in
[Prosody](/prosody). Edit
`/etc/prosody/conf.avail/{{<hl>}}meet.example.org{{</hl>}}.cfg.lua`, and locate this
block:

```lua
VirtualHost "{{<hl>}}meet.example.org{{</hl>}}"
    authentication = "anonymous"
```

And change the authentication mode from `"anonymous"` to
`"internal_hashed"`.

Then, to enable guests to login and join your chatrooms, add the
following block **after** the one you just edited:

```lua
VirtualHost "guest.{{<hl>}}meet.example.org{{</hl>}}"
    authentication = "anonymous"
    c2s_require_encryption = false
```

### Jitsi Meet configuration

Next, in `/etc/jitsi/meet/{{<hl>}}meet.example.org{{</hl>}}-config.js`, uncomment the
following line:

```js
var config = {
    hosts: {
        // anonymousdomain: 'guest.jitsi-meet.example.com',
    },
}
```

And change `'guest.jitsi-meet.example.com'` to
`'{{<hl>}}guest.meet.example.org{{</hl>}}'` (your Jitsi domain preceded by `meet.`).

### Jicofo configuration

Finally, we configure Jicofo to only allow the creation of conferences
when the request is coming from an authenticated user. To do so, add the
following `authentication` section to `/etc/jitsi/jicofo/jicofo.conf`:

```yaml
jicofo {
  authentication: {
    enabled: true
    type: XMPP
    login-url: {{<hl>}}meet.example.org{{</hl>}}
 }
```

### Create users in Prosody and restart the services

You now need to register some users in [Prosody](/prosody), you
can do so manually using `prosodyctl`:

```sh
prosodyctl register &ltusername> meet.example.org &ltpassword>
```

Finally, restart `prosody`, `jicofo`, and `jitsi-videobridge2`:

```sh
systemctl restart prosody
systemctl restart jicofo
systemctl restart jitsi-videobridge2
```

## More info

This article is based on [the original
documentation](https://jitsi.github.io/handbook/docs/devops-guide/devops-guide-quickstart).
There you can find more details and configurations.

-   Written by [Jose Fabio.](https://josefabio.com)
    Donate Monero:
    `484RLdsXQCDGSthNatGApRPTyqcCbM3PkM97axXezEuPZppimXmwWegiF3Et4BHBgjWR7sVXuEUoAeVNpBiVznhoDLqLV7j`
    [\[QR\]](https://josefabio.com/figures/monero.jpg)
-   Edited and revised by [Luke](https://lukesmith.xyz).
