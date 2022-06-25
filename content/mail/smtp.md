---
title: "Setting up a Postfix SMTP server"
draft: true
---
The first step to setting up an email server is having an SMTP server.
SMTP sends and receives email. Whether we want a full email server or
just the ability to send automated email by script, we will need SMTP,
and Postfix is the standard SMTP server.

Here let\'s set a server up. Note that our goal is to be able to send
emails from our server. If you want a full email server, this is the
first step, and we will address the rest later.

## Before beginning!

Whatever VPS ([Vultr](https://www.vultr.com/?ref=8384069-6G) or
[Frantech](https://my.frantech.ca/aff.php?aff=3886)) or IPS you are
using, it is a very common policy to **automatically block all email
ports by default**. VPS providers do this to prevent spammers from using
their services.

If you want to start an email server, therefore, go to your VPS\'s site
and open a ticket or make a request to open up email ports. This is a
simple process that requires nothing too special. One of the wagies at
your VPS will kindly do the needful and open your ports for you. Note
that this is not the same as unblocking a port with [ufw](ufw.html).

## Installation

First, we install Postfix and also `mailutils`, which comes with some
mail programs we will use.

    apt install -y mailutils postfix

Installing Postfix for the first time will give us some graphical
options.

![SMTP Postfix internet site choice](pix/smtp-01.png)

When asked for a \"mail name\", give your full domain name from which
you would like mail to come and go, e.g. [example.org]{.dfn} or
[landchad.net]{.dfn}.

![SMTP Postfix fully qualified domain name](pix/smtp-02.png)

## Test the email

That is actually all you need to have set up to have a barebones,
send-only email server. We can test our server by running a `mail`
command like that below.

    echo "Hi there.

    This is the text." | mail -s "Email from the server" your@emailaddress.com

And that is simply enough the command your server can run to send mail.
Note that we use the `-s` option to specify the email\'s subject while
we pipe the email content into the `mail` command via standard input. In
this example I use a quoted multiline email as an example.

## Do you see your message?

If you sent the above test message to an account on Gmail or another
major email provider, there is **very high** chance of the message you
sent above being marked as spam or not appearing at all!

Don\'t worry, we\'ll take care of that in the next two articles where we
set up rDNS and OpenDKIM to validate the emails you send.

[[Next: rDNS and PTR Records](rdns.html)]{.next}
