---
title: "Rainloop"
tags: ['service']
icon: 'rainloop.png'
short_desc: 'A graphical website for accessing a mail server.'
---


[Rainloop](https://www.rainloop.net/)
is a webmail client, a program that allows you to access your email
online like Gmail. It is useful to be able to access you email from a
web browser because it allows you to easily access your email from any
device with a web browser without any additional setup.

If you set up
[![logo](/pix/nextcloud.svg)Nextcloud](/nextcloud)
then you do not need to install Rainloop because Nextcloud comes with a
webmail client. However, if all you want is a webmail client and you do
not need all of the extra things that Nextcloud provides, Rainloop would
be the better choice out of the two since it is less bloated and simpler
to install.

## Instructions

First we will install the required packages for Rainloop with the
following command:

```sh
apt-get install php7.4 php7.4-common php7.4-curl php7.4-xml php7.4-fpm php7.4-json php7.4-dev php7.4-mysql unzip -y
```

Then we will download the community version of Rainloop, unzip it into
an appropriate directory and fix all of the file permissions:

```sh
curl -L "https://www.rainloop.net/repository/webmail/rainloop-latest.zip" -o "rainloop.zip"
unzip rainloop.zip -d /var/www/mail
chown -R www-data: /var/www/mail
```

We have installed Rainloop itself, but now we need Nginx to serve the
client. We do that by adding the following text into the file
`/etc/nginx/sites-available/mail` (you can replace the bold text with
whatever is appropriate for your server).

```nginx
server {

    listen 80;
    listen [::]:80;

    server_name mail.example.org ;
    root /var/www/mail;

    index index.php;

    access_log /var/log/nginx/rainloop_access.log;
    error_log /var/log/nginx/rainloop_error.log;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_index index.php;
        fastcgi_split_path_info ^(.+\.php)(.*)$;
        fastcgi_keep_conn on;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        include /etc/nginx/fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
    location ~ /\.ht {
        deny all;
    }

    location ^~ /data {
        deny all;
    }
}
```

Then enable the site by linking it to the sites-enabled directory:

```sh
ln -s /etc/nginx/sites-available/mail /etc/nginx/sites-enabled/
```

Reload nginx:

```sh
systemctl reload nginx
```

Finally get certifications if you are using a new subdomain:

```sh
certbot --nginx
```

After that go to `mail.example.org/?admin` and login with the default
username and password: admin, 12345. Now you are in the admin panel and
the first thing you do should be to change the adminsitrator password by
looking in the security tab on the left.

{{< img alt="rainloop" src="/pix/rainloop-1.png" >}}

After securing the admin account you can go to domains and add your own
email address.

{{< img alt="rainloop" src="/pix/rainloop-2.png" >}}

Finally, go to `mail.example.org` and login with your email address and
password.

## Contribution

[Deniz Telci](https://deniz.telci.org/) - XMR:
`4AcKbpTUc3QX2zHYdh9HZwJAQyexdybFhF1WhXTFhxAcV9jgzB6kroqGZDgeW3rQqXEMYJioYo61kaLBqstwecty9Bjbr4v`
