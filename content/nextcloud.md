---
title: "Nextcloud"
date: 2021-06-30
icon: 'nextcloud.svg'
tags: ['service']
short_desc: 'A free and private Google Drive-like cloud storage system.'
---

## What is Nextcloud? {#whatis}

[![](/pix/nextcloud.svg)Nextcloud](https://nextcloud.com)
is a free and open source solution for cloud storage. However it can
also do other things, such as manage your email, notes, calender, tasks,
and can even connect to the Fediverse (think Mastodon and Pleroma).
Pretty much every service that Google has to offer has a much better
alternative as a Nextcloud app and this is a must-have for anyone
wanting to get away from Google services but still wants a traditional
cloud experience (in the likes of Google Services, anyways).

## Instructions

We should upgrade the system and then install packages that we might
need. Run the following command:

```sh
apt full-upgrade -y && apt install mariadb-server php-mysql php php-gd php-mbstring php-dom php-curl php-zip php-simplexml php-xml php-fpm -y
```

Next, we need to set up our SQL database by running a Secure
Installation and creating the tables that will store data that Nextcloud
will need. Run the following command:

```sh
mysql_secure_installation
```

When it asks for root a password, say yes and input a new and secure
password. The root password here is just for the SQL database, not for
the GNU/Linux system.

Answer the rest of the questions as follows:

```sh
Remove anonymous users? [Y/n]: Y
Disallow root login remotely? [Y/n]: Y
Remove test database and access to it? [Y/n]: Y
Reload privilege tables now? [Y/n]: Y
```


Next, sign into the SQL database with the new and secure password you
chose before. Run the following command:

```sh
mysql -u root -p
```

We need to create a database for Nextcloud. Follow the instructions
below and change some of the placeholders as you wish:

```mysql
CREATE DATABASE nextcloud;
GRANT ALL ON nextcloud.* TO 'username'@'localhost' IDENTIFIED BY 'password';
FLUSH PRIVILEGES;
EXIT;
```

Now we need to configure PHP. Let\'s start my making sure that the PHP
user is set to `www-data` and if that is not the case, add the
`www-data` user if needed and set the correct variable in `nginx.conf`.
Make sure this line is at the beginning of `/etc/nginx/nginx.conf`.

```nginx
user www-data;
```

Check for the `www-data` user by running `id -u www-data`. If a number
is output from that command, then the www-data user exists. If not. add
the user simply by running `useradd www-data`

Next, we need to ensure that we have SSL certificates generated for your
website. If you have not already done this, refer to [this
guide](/basic/certbot).

In `/etc/nginx/sites-available/` we need to make a new configuration for
Nextcloud (example: `/etc/nginx/sites-available/nextcloud`). Create it
and open it, modify, and add the following lines:

```nginx
upstream php-handler {
    server unix:/var/run/php/php7.4-fpm.sock;
    server 127.0.0.1:9000;
}

server {
    listen 80;
    listen [::]:80;
    server_name example.org;

    return 301 https://$server_name$request_uri;
}

server {
    listen 443      ssl http2;
    listen [::]:443 ssl http2;
    server_name example.org;
    ssl_certificate     /etc/letsencrypt/live/example.org/fullchain.pem ;
    ssl_certificate_key /etc/letsencrypt/live/example.org/privkey.pem ;

    root /var/www;

    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }

    location ^~ /.well-known {
        location = /.well-known/carddav { return 301 /nextcloud/remote.php/dav/; }
        location = /.well-known/caldav  { return 301 /nextcloud/remote.php/dav/; }

        location /.well-known/acme-challenge    { try_files $uri $uri/ =404; }
        location /.well-known/pki-validation    { try_files $uri $uri/ =404; }

        return 301 /nextcloud/index.php$request_uri;
    }

    location ^~ /nextcloud {
        client_max_body_size 512M;
        fastcgi_buffers 64 4K;

        gzip on;
        gzip_vary on;
        gzip_comp_level 4;
        gzip_min_length 256;
        gzip_proxied expired no-cache no-store private no_last_modified no_etag auth;
        gzip_types application/atom+xml application/javascript application/json application/ld+json application/manifest+json application/rss+xml application/vnd.geo+json application/vnd.ms-fontobject application/x-font-ttf application/x-web-app-manifest+json application/xhtml+xml application/xml font/opentype image/bmp image/svg+xml image/x-icon text/cache-manifest text/css text/plain text/vcard text/vnd.rim.location.xloc text/vtt text/x-component text/x-cross-domain-policy;

        add_header Referrer-Policy                      "no-referrer"   always;
        add_header X-Content-Type-Options               "nosniff"       always;
        add_header X-Download-Options                   "noopen"        always;
        add_header X-Frame-Options                      "SAMEORIGIN"    always;
        add_header X-Permitted-Cross-Domain-Policies    "none"          always;
        add_header X-Robots-Tag                         "none"          always;
        add_header X-XSS-Protection                     "1; mode=block" always;

        fastcgi_hide_header X-Powered-By;

        index index.php index.html /nextcloud/index.php$request_uri;

        location = /nextcloud {
            if ( $http_user_agent ~ ^DavClnt ) {
                return 302 /nextcloud/remote.php/webdav/$is_args$args;
            }
        }

        location ~ ^/nextcloud/(?:build|tests|config|lib|3rdparty|templates|data)(?:$|/)    { return 404; }
        location ~ ^/nextcloud/(?:\.|autotest|occ|issue|indie|db_|console)                  { return 404; }

        location ~ \.php(?:$|/) {
            fastcgi_split_path_info ^(.+?\.php)(/.*)$;
            set $path_info $fastcgi_path_info;

            try_files $fastcgi_script_name =404;

            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_param PATH_INFO $path_info;
            fastcgi_param HTTPS on;

            fastcgi_param modHeadersAvailable true;
            fastcgi_param front_controller_active true;
            fastcgi_pass php-handler;

            fastcgi_intercept_errors on;
            fastcgi_request_buffering off;
        }

        location ~ \.(?:css|js|svg|gif)$ {
            try_files $uri /nextcloud/index.php$request_uri;
            expires 6M;
            access_log off;
        }

        location ~ \.woff2?$ {
            try_files $uri /nextcloud/index.php$request_uri;
            expires 7d;
            access_log off;
        }

        location /nextcloud/remote {
            return 301 /nextcloud/remote.php$request_uri;
        }

        location /nextcloud {
            try_files $uri $uri/ /nextcloud/index.php$request_uri;
        }
    }
}
```

Enable the site by running this command:

```sh
ln -s /etc/nginx/sites-available/nextcloud /etc/nginx/sites-enabled/
```

Next, we need to download the latest release tarball of Nextcloud. Go to
https://nextcloud.com/install/#instructions-server and copy the URL of
the .tar.bz2 tarball from the More Downloads dropdown menu then go to
your server\'s shell prompt and download the tarball with wget. Here is
an example:

```sh
wget https://download.nextcloud.com/server/releases/nextcloud-21.0.2.tar.bz2
```

Now we need to extract the Nextcloud tarball. Run the following command:

```sh
tar -xjf nextcloud*.tar.bz2 -C /var/www
```

If you have multiple Nextcloud tarballs in the current working directory
you might want to manually specify which one you wish to extract.

Let\'s correct the ownership and permissions of those files. Run the
following commands:

```sh
chown -R www-data:www-data /var/www/nextcloud
chmod -R 755 /var/www/nextcloud
```


Start and enable the php-fpm and the mariadb services (the name of the
php-fpm service may have a version number ahead of it, use bash\'s tab
autocomplete to help you out with that):

```sh
systemctl enable php7.4-fpm
systemctl start php7.4-fpm
systemctl enable mariadb
systemctl start mariadb
```

Reload the nginx service:

```sh
systemctl reload nginx
```

Now we need to head to Nextcloud\'s web interface. Go to your web
browser and go to your website, but go to the subdirectory \"nextcloud\"
instead. Go to `https://example.org/nextcloud`. This will launch the
configuration wizard.

-  Choose an admin username and secure password.
-  Leave Data folder at the default value unless it is incorrect.
-  For Database user, enter the user you set for the SQL database.
-  For Database password, enter the password you chose for the new user
   in MariaDB.
-  For Database name, enter: `nextcloud`
-  Leave \"localhost\" as \"localhost\".
-  Click Finish.

Congratulations, you have set up your own Nextcloud instance.

## What\'s Next? {#whatsnext}

Now you may be wondering: What do I do now? Here are some suggestions:

-  Rice your Nextcloud instance by changing your themeing and
   installing new themes and plugins in Settings in the Nextcloud Web
   Interface.
-  Install the Nextcloud Client on your personal computer and sync your
   files to your instance.
-  Install the Nextcloud App on your mobile device and sync your files
   to your instance.
-  Set up your email account on the Nextcloud Mail app on the web
   interface to view and sync your email there (just like Gmail).
-  Schedule events with Nextcloud Calender.
-  Write notes in Markdown inside the Nextcloud Notes web and mobile
   app.
-  Set the Nextcloud Dashboard as your web browser\'s homepage (it is
   pretty nice).

Enjoy your cloud services in freedom.

------------------------------------------------------------------------

*Written by [Matthew \"Madness\" Evan](https://github.com/MattMadness)*
