---
title: "Setting up an E-mail Inbox"
tags: ['mail']
date: 2022-12-04
---
In the article on [SMTP and Postfix](/mail/smtp), we set up a simple
Postfix server that we could use to programatically send mail with the
`mail` command. In order to have a true and fully-functional mail
server, users should be able to login to a mail client where they
can read their inbox and send mail remotely. In order to achieve this we need Dovecot,
which can store mails received by the server,
authenticate user accounts and interact with mail.

If we're setting up an inbox we will also want spam detection software, such
as spam assassin.

## Dovecot and Spamassassin

    apt install dovecot-imapd dovecot-sieve spamassassin spamc

Unblock the imap port:

    ufw allow 993

## Certificate

We will want a SSL certificate for the `mail.` subdomain. We can get
this with [Certbot](/basic/certbot/). Assuming we are using Nginx for our
server otherwise, run:

    certbot --nginx certonly -d mail.example.org

## DNS

We also need two little DNS records set on your domain registrar's site/DNS server:

1. An MX record. Just put your domain, **example.org**, in the "Points to" field.
2. A CNAME record. Host field: **mail.example.org**. "Points to" field: **example.org.**

## Configuring Dovecot

Dovecot\'s configuration file is in `/etc/dovecot/docevot.conf`. If you
open that file, you will see this line: `!include conf.d/*.conf` which adds
all the `.conf` files in `/etc/dovecot/conf.d/` to the Dovecot
configuration.

One can edit each of these files individually to get the needed
configuration, but to make things easy here, delete or backup the main
configuration file and we will replace it with one single config file
with all important settings in it. Make sure you change `ssl_cert`
and `ssl_key` accordingly.

``` wide
# Note that in the dovecot conf, you can use:
# %u for username
# %n for the name in name@domain.tld
# %d for the domain
# %h the user's home directory

# Connections between the mail client and Dovecot needs to be encrypted
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

# Search for valid users in /etc/passwd
userdb {
    driver = passwd
}
#Fallback: Use plain old PAM to find user passwords
passdb {
    driver = pam
}

# Our mail for each user will be in ~/Mail, and the inbox will be ~/Mail/Inbox
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

# Here we let Postfix use Dovecot's authetication system.
service auth {
  unix_listener /var/spool/postfix/private/auth {
    mode = 0660
    user = postfix
    group = postfix
}
}

protocol lda {
  mail_plugins = \$mail_plugins sieve
}
protocol lmtp {
  mail_plugins = \$mail_plugins sieve
}
plugin {
	sieve = ~/.dovecot.sieve
	sieve_default = /var/lib/dovecot/sieve/default.sieve
	sieve_dir = ~/.sieve
	sieve_global_dir = /var/lib/dovecot/sieve/
}
```

### Settings Explained

Take a good look at the above settings to understand what\'s going on. Some of
the settings include:

1.  SSL settings to allow encrypted connections.
2.  The mail server will authenticate users against PAM/passwd, which
     means users you create on the server (so long as they are part of
        the `mail` group) will be able to receive and send mail.
3.  Default directories for a mail account: Inbox, Sent, Drafts, Junk,
    Trash and Archive.
4.  Create a `unix_listener` that will allow Postfix to authenticate
    users via Dovecot.
5.  Setup the Dovecot sieve plugin, which provides mail filtering facilities
    at time of final message delivery. Sieve scripts can be used to
    customize how messages are delivered, whether they're forwarded
    or stored in special folders.

Next, we can tell sieve to automatically move mail flagged as spam to
the junk folder:

    echo "require [\"fileinto\", \"mailbox\"];
    if header :contains \"X-Spam-Flag\" \"YES\"
            {
                    fileinto \"Junk\";
            }" > /var/lib/dovecot/sieve/default.sieve

After that, we should create the `vmail` user and group, which will
access the mails, and then update the sieve configuration:

    grep -q '^vmail:' /etc/passwd || useradd vmail
    chown -R vmail:vmail /var/lib/dovecot
    sievec /var/lib/dovecot/sieve/default.sieve

Then, enable pam authentication for Dovecot:

    echo "auth    required        pam_unix.so nullok
    account required        pam_unix.so" >> /etc/pam.d/dovecot

## Connecting Postfix and Dovecot

We need to tell Postfix to look to Dovecot for authenticating users/passwords.
Dovecot will be putting an authentication socket in `/var/spool/postfix/private/auth`.

    postconf -e 'smtpd_sasl_auth_enable = yes'
    postconf -e 'smtpd_sasl_type = dovecot'
    postconf -e 'smtpd_sasl_path = private/auth'
    postconf -e 'mailbox_command = /usr/lib/dovecot/deliver'

## Connecting Postfix and Spamassassin

We will change `/etc/postifx/master.cf` so postfix can route mail through spamassassin. First
we can cleanup the default configuration. Feel free to make a backup.

    sed -i '/^\s*-o/d;/^\s*submission/d;/^\s*smtp/d' /etc/postfix/master.cf

Finally, run this command to finish the configuration for spamassassin.

    echo "smtp unix - - n - - smtp
    smtp inet n - y - - smtpd
      -o content_filter=spamassassin
    submission inet n       -       y       -       -       smtpd
      -o syslog_name=postfix/submission
      -o smtpd_tls_security_level=encrypt
      -o smtpd_sasl_auth_enable=yes
      -o smtpd_tls_auth_only=yes
    smtps     inet  n       -       y       -       -       smtpd
      -o syslog_name=postfix/smtps
      -o smtpd_tls_wrappermode=yes
      -o smtpd_sasl_auth_enable=yes
    spamassassin unix -     n       n       -       -       pipe
      user=debian-spamd argv=/usr/bin/spamc -f -e /usr/sbin/sendmail -oi -f \${sender} \${recipient}" >> /etc/postfix/master.cf

## Make new mail accounts

This is the easy part. Let's say we want to add a user Billy and let him
receive mail, run this:

    useradd -m -G mail billy
    passwd billy

Any user added to the `mail` group will be able to receive mail. Suppose a user
Cassie already exists and we want to let her receive mail too. Just run:

    usermod -a -G mail cassie
