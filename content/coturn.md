---
title: "Coturn"
date: 2022-03-29
icon: "webrtc.svg"
img: "webrtc.svg"
tags: ['service']
---

[Coturn](https://github.com/coturn/coturn) is a libre **STUN** and
**TURN** server software that allows users of chat protcols (Such as
[XMPP](/prosody) and [Matrix](/matrix)) to perform WebRTC **voice
and video calls** despite them being behind NATs.

Almost every self-hosted voice and video conferencing program (such as
[Jitsi](/jitsi) and [Nextcloud\'s](/nextcloud) Talk app) will
**require** Coturn or some other equivalent turnserver to function
properly.

## Installation

Coturn is available in the Debian repositories:

```sh
apt install coturn
```

## Configuration

### Base configuration

Coturn\'s configuration file is `/etc/turnserver.conf`. There are a few
aspects that need to be changed in order to get a fully-functioning
turnserver.

Here is an example of some sane defaults:

```md
server-name=turn.example.org
realm=turn.example.org
listening-ip=your_public_ip

listening-port=3478
min-port=10000
max-port=20000

## The "verbose" option is useful for debugging issues
verbose
```

### Authentication

There are two options for authentication on a turnserver:

1.  **Usernames** and **passwords,**
2.  or **authentication secrets.**

Depending on what self-hosted service is being used in conjunction with
Coturn, you may need one or the other of these two options.

#### Usernames and Passwords

To utilize username and password authentication with Coturn, add the
following configuration in `turnserver.conf`:

```txt
lt-cred-mech
user=username:password
```

#### Authentication Secrets

To utilize authentication secrets with Coturn, add the following
configuration in `turnserver.conf`:

```txt
use-auth-secret
static-auth-secret=your_auth_secret
```

## TURNS (TLS Encryption)

Some self-hosted services (such as Matrix and XMPP) may support the use
of **TURNS:** An encrypted version of TURN, which allows for WebRTC
connections to be established with the use of an encrypted TLS tunnel,
just like HTTPS allows for encrypted viewing of websites.

To utilize TURNS, certificates need to be declared for
**turn.example.org** in `turnserver.conf`:

```txt
cert=/etc/letsencrypt/live/turn.example.org/fullchain.pem
pkey=/etc/letsencrypt/live/turn.example.org/privkey.pem
```

## Starting Coturn

After all configuration changes are complete, Coturn can be started with
its systemd daemon:

```sh
systemctl restart coturn
```

Congratulations! You\'ve successfully setup a Coturn server!

------------------------------------------------------------------------

*Written by [Denshi.](https://denshi.org) Donate Monero
[here](https://denshi.org/donate.html)
[\[QR\]](https://denshi.org/images/monero.jpg)*
