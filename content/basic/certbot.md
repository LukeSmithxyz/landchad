---
title: "Certbot and HTTPS"
date: 2021-07-13
tags: ['basic']
---
Once you have a website, it is extremely important to enable encrypted
connections over HTTPS/SSL. You might have no idea what that means, but
it\'s easy to do now that we\'ve [set our web server up](/basic/nginx/).

Certbot is a program that automatically creates and deploys the
certificates that allow encrypted connections. It used to be painful
(and often expensive) to do this, but now it\'s all free and automatic.

## Why is encryption important?

-   With HTTPS, users\' ISPs cannot snoop on what they are looking at on
    your website. They know that they have connected, but the particular
    pages they visit are private as everything is encrypted. HTTPS
    increases user privacy.
-   If you later create usernames and passwords for any service on your
    site, lack of encryption can compromise that private data! Most
    well-designed software will automatically *prevent* any unencrypted
    connections over the internet.
-   Search engines like Google favor pages with HTTPS over unencrypted
    HTTP.
-   You get the official-looking green 🔒 symbol in the URL bar in most
    browsers which makes normies subtly trust your site more.

## Let\'s do it!

{{< img alt="website without https/ssl" src="/pix/nginx-website.png" link="/pix/nginx-website.png" >}}

Note in this picture that a browser accessing your site will say \"Not
secure\" or something else to notify you that we are using an
unencrypted HTTP connection rather than an encrypted HTTPS one.

## Installation

Just run:

```sh
apt install python3-certbot-nginx
```

And this will install `certbot` and its module for `nginx`.

## Run

As I mentioned in the previous article, firewalls might interfere with
certbot, so you will want to either disable your firewall or at least
ensure that it allows connections on ports 80 and 443:

```sh
ufw allow 80
ufw allow 443
```

Now let\'s run certbot:

```sh
certbot --nginx
```

The command will ask you for your email. This is so when the
certificates need to be renewed in three months, you will get an email
about it. You can set the certificates to renew automatically, but it\'s
a good idea to check it the first time to ensure it renewed properly.
You can avoid giving your email by running the command with the
`--register-unsafely-without-email` option as well.

Agree to the terms, and optionally consent to give your email to the EFF
(I recommend against this obviously).

Once all that is done, it will ask you what domains you want a
certificate for. You can just press enter to select all.

{{< img alt="activate HTTPS for a site with certbot" src="/pix/certbot-01.png" link="/pix/certbot-01.png" >}}

It will take a moment to create the certificate, but afterwards, you
will be asked if you want to automatically redirect all connections to
be encrypted. Since this is preferable, choose 2 to Redirect.

{{< img alt="redirecting http to encrypted https with certbot" src="/pix/certbot-02.png" link="/pix/certbot-02.png" >}}

### Checking for success

You should now be able to go to your website and see that there is a
🔒 lock icon or some other notification that you are now on an encrypted
connection.

{{< img alt="A 🔒 symbol symbolizing our new HTTPS layer for our website!" src="/pix/certbot-03.png" link="/pix/certbot-03.png" >}}

## Setting up certificate renewal

As I mentioned in passing, the Certbot certificates last for 3 months.
To renew certificates, you just have to run `certbot --nginx renew` and
it will renew any certificates close to expiry.

Of course, you don\'t want to have to remember to log in to renew them
every three months, so it\'s easy to tell the server to automatically
run this command. We will use a [cronjob](/cron) for this. Run the
following command:

```sh
crontab -e
```

There might be a little menu that pops up asking what text editor you
prefer when you run this command. If you don\'t know how to use vim,
choose `nano`, the first option.

This `crontab` command will open up a file for editing. A crontab is a
list of commands that your operating system will run automatically at
certain times. We are going to tell it to automatically try to renew our
certificates every month so we never have to.

Create a new line at the end of the file and add this content:

```txt
0 0 1 * * certbot --nginx renew
```

Save the file and exit to activate this cronjob.

For more on cron and crontabs please [click here!](/cron)

You now have a live website on the internet. You can add to it what you
wish.

As you add content to your site, there are many other things you can
also install linked on [the main page](/), and many more
improvements, tweaks and bonuses.
