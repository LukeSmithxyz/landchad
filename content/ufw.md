---
title: "Using UFW as a Firewall"
date: 2021-06-30
tags: ['server']
---
**Uncomplicated Firewall** (UFW) is a front-facing program for the more
involved `iptables` firewall program installed in most GNU/Linux
distributions. We can use `ufw` to restrict machines on the internet to
only access the services (SSH, websites etc) you want them to, but it
can also be used to prevent programs on the computer itself from
accesing parts of the internet it shouldn\'t.

## How to Get It

Log into your server by pulling up a terminal and typing:

```sh
ssh root@example.org
```

This command will attempt to log into your server and run a remote
shell. If you leave the settings default, it should prompt you for your
password, and you can just copy or type in the password from Vultr\'s
site.

Some VPS providers automatically install `ufw`, but if you do not have
it installed already, install it in the typical way:

```sh
apt install ufw
```

## First-Time Setup

You can check the status of `ufw` right now by running:

```sh
ufw status
```

Without any changes, it should report back `Status: inactive`. Let\'s
set it up so that only connections to SSH (standardized at port 22) are
allowed in, and then enable the firewall:

**Careful!** Enabling `ufw` without allowing SSH will block you from
remoting to your server. Double-check that you have allowed SSH, and if
you have changed the default SSH port, put in *that* number instead.

```sh
ufw default deny incoming # block all incoming connections by default
ufw allow in ssh # or: ufw allow in 22
ufw enable
```

`ufw` has an internal list of protocols applications, and the ports used
by them. In this case, it knows SSH is on port 22. We\'ll go more in
detail how to view all protocols `ufw` knows about. By default, when you
allow an incoming port, it allows that port both on IPv4 and IPv6.

With the firewall enabled and allowing only SSH in, all other ports are
protected from incoming requests. To view all your rules, run:

```sh
ufw status verbose
```

A firewall that allows to connect to SSH and their website may look
like:

```txt
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), deny (routed)
New profiles: skip

To                           Action      From
--                           ------      ----
22 (SSH)                     ALLOW IN    Anywhere
80,443/tcp (WWW Full)        ALLOW IN    Anywhere
22 (SSH (v6))                ALLOW IN    Anywhere (v6)
80,443/tcp (WWW Full (v6))   ALLOW IN    Anywhere (v6)
```

If you want to delete e.g. the \'WWW Full\' rule, run:

```sh
ufw delete allow in 'WWW Full'
ufw reload
```

## Enabling Common Services

You have blocked all incoming ports but SSH, which means no outsiders
would be able to access other services, like an email server or your
website. You should look at the ports your services are open on and
enable them individually. Here is a list of a few common services:

### Opening Port Numbers

Suppose you install [a Gemini server](/gemini), which must broadcast
on port 1965. By default `ufw` blocks all incoming connections on all
ports, so whenever you install a new service like this you will have to
tell `ufw` to enable the desired port:

```sh
ufw allow 1965
```

### Websites: HTTP and HTTPS

HTTP uses port 80 and HTTPS uses port 443. We can enable them like this:

```sh
ufw allow 80
ufw allow 443
```

But `ufw` additionally knows the typical ports of common serives, so you
can also run this:

```sh
ufw allow http
ufw allow https
```

And that will do the same thing. There are also other abbreviations for
common port lists:

```sh
ufw allow in 'WWW Full'
```

To see these other \"apps\" that `ufw` knows by default, run
`ufw app list`

### Email: IMAP, POP3, and SMTP

```sh
ufw allow in IMAPS
ufw allow in POP3
ufw allow in SMTP
ufw allow in 'Postfix SMTPS'
ufw allow in 'Mail Submission'
```

## Fine-Tuning Rules

Instead of denying all ports by default, you may want to deny (ignores
incoming requests) or reject (explicitly tells requests they\'re not
allowed):

```sh
ufw default allow in
ufw deny in PORT
ufw reject in PORT
ufw reload
```

You can add rules to comments to remember what they are there for:

```sh
ufw allow in PORT comment 'Secret SSH'
ufw reload
ufw status verbose
```

Output:

```txt
To                         Action      From
--                         ------      ----
PORT                       ALLOW IN    Anywhere                   # Secret SSH
PORT (v6)                  ALLOW IN    Anywhere (v6)              # Secret SSH
```

To deny outgoing ports:

```sh
ufw deny out PORT
```

Ratelimiting is useful to protect against brute-force login attacks,
like in SSH. Only IPv4 is supported for now. Enable it by running:

```sh
ufw limit PORT/tcp
```

To blocklist IP addresses:

```sh
ufw deny from IP_ADDRESS
```

To read more what you can do with `ufw`, run:

```sh
man ufw
```

## Recovering SSH {#recovering-from-losing-ssh}

If you have accidentally firewalled yourself from logging on your
computer, you can recover access by using your VPS\'s virtual console.
On Vultr, this is on your VPS\'s menu. To the right of the server name,
It is the leftmost icon that looks like a monitor.

{{< img src="/pix/ssh-01.png"  link="/pix/ssh-01.png" alt="View Console" >}}

Log in through there, and disable ufw by typing:

```sh
ufw disable
```

## Further Reading

-   `man ufw` 👈
-   [Ubuntu Wiki:
    UncomplicatedFirewall](https://wiki.ubuntu.com/UncomplicatedFirewall)
-   [Gufw (Graphical UFW)](https://help.ubuntu.com/community/Gufw)

**Contributor** - [shunter.xyz](https://shunter.xyz)
