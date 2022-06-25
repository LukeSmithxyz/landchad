---
title: "Dovecot Email Server"
draft: true
---
In the article on [SMTP and Postfix](smtp.html), we set up a simple
Postfix server that we could use to programatically send mail with the
`mail` command. In order to have a true and fully-functional mail
server, we need Dovecot, which can store mails received by the server,
have and authenticate user accounts and interact with mail

## Installation

    apt install dovecot-imapd dovecot-sieve

## Certificate

We will want a SSL certificate for the `mail.` subdomain. We can get
this with [Certbot](certbot.html). Assuming we are using Nginx for our
server otherwise, run:

    certbot --nginx certonly -d mail.example.org

## DNS

## Configuring Dovecot

Dovecot\'s configuration file is in `/etc/dovecot/docevot.conf`. If you
open that file, you will this line: `!include conf.d/*.conf` which adds
all the `.conf` files in `/etc/dovecot/conf.d/` to the Dovecot
configuration.

One can edit each of these files individually to get the needed
configuration, but to make things easy here, delete or backup the main
configuration file and we will replace it with one single config file
with all important settings in it.

``` wide
ssl = required
ssl_cert = </etc/letsencrypt/live/mail.example.org/fullchain.pem
ssl_key = </etc/letsencrypt/live/mail.example.org/privkey.pem
ssl_min_protocol = TLSv1.2
ssl_cipher_list = EECDH+ECDSA+AESGCM:EECDH+aRSA+AESGCM:EECDH+ECDSA+SHA256:EECDH+aRSA+SHA256:EECDH+ECDSA+SHA384:EECDH+ECDSA+SHA256:EECDH+aRSA+SHA384:EDH+aRSA+AESGCM:EDH+aRSA+SHA256:EDH+aRSA:EECDH:!aNULL:!eNULL:!MEDIUM:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS:!RC4:!SEED
ssl_prefer_server_ciphers = yes
ssl_dh = </usr/share/dovecot/dh.pem
auth_mechanisms = plain login
auth_username_format = %n

protocols = $protocols imap

userdb {
    driver = passwd
}
passdb {
    driver = pam
}

mail_location = maildir:~/Mail:INBOX=~/Mail/Inbox:LAYOUT=fs
namespace inbox {
    inbox = yes
    mailbox Drafts {
    special_use = \Drafts
    auto = subscribe
}
    mailbox Junk {
    special_use = \Junk
    auto = subscribe
    autoexpunge = 30d
}
    mailbox Sent {
    special_use = \Sent
    auto = subscribe
}
    mailbox Trash {
    special_use = \Trash
}
    mailbox Archive {
    special_use = \Archive
}
}

service auth {
  unix_listener /var/spool/postfix/private/auth {
    mode = 0660
    user = postfix
    group = postfix
}
}
```

### Settings Explained

Take a good look at the settings to understand what\'s going on. Some of
the settings include:

1.  SSL settings to allow encrypted connections.
2.  Default directories for a mail account: Inbox, Sent, Drafts, Junk,
    Trash and Archive.
3.  The mail server will authenticate users against PAM/passwd, which
    means users you create on the server (so long as they are part of
    the `mail` group) will be able to receive and send mail.
4.  Create a `unix_listener` that will allow Postfix to authenticate
    users via Dovecot.

```{=html}
<!-- -->
```
    echo "auth    required        pam_unix.so nullok
    account required        pam_unix.so" >> /etc/pam.d/dovecot

## Connecting Postfix and Dovecot

[[Next:\<++\>](%3C++%3E)]{.next}
