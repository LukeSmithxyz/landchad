---
title: "Harden your E-mail Server"
tags: ['mail']
date: 2022-12-05
---

## Hardening Postfix

Put restrictions on servers sending mail to you.

    postconf -e 'smtpd_recipient_restrictions = permit_sasl_authenticated, permit_mynetworks, reject_unauth_destination, reject_unknown_recipient_domain'

## Anonymize Headers

Use some regular expressions to prevent some meta data like a client's ip address
from being leaked.

    echo "/^Received:.*/     IGNORE
    /^X-Originating-IP:/    IGNORE
    /^User-Agent:/        IGNORE
    /^X-Mailer:/        IGNORE" >> /etc/postfix/header_checks

Add this file to the postfix configuration:

    postconf -e "header_checks = regexp:/etc/postfix/header_checks"

## Fail2Ban

If you're not familiar with fail2Ban, it's essentially a program which
blocks bot's and hacker's login requests after a few invalid attempts.

    apt-get install fail2ban

Make a local copy of the configuration file:

    cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

Go down to the `# Mail servers` line and paste this:

    [postfix]

    enabled  = true
    port     = smtp,ssmtp,submission
    filter   = postfix
    logpath  = /var/log/mail.log


    [sasl]

    enabled  = true
    port     = smtp,ssmtp,submission,imap2,imap3,imaps,pop3,pop3s
    filter   = postfix-sasl
    # You might consider monitoring /var/log/mail.warn instead if you are
    # running postfix since it would provide the same log lines at the
    # "warn" level but overall at the smaller filesize.
    logpath  = /var/log/mail.warn
    maxretry = 1
    bantime  = 21600

    [dovecot]

    enabled = true
    port    = smtp,ssmtp,submission,imap2,imap3,imaps,pop3,pop3s
    filter  = dovecot
    logpath = /var/log/mail.log

This will only grant 2 login attempts and then block the requester for 6 hours. Now restart `fail2ban`:

    systemctl restart fail2ban
