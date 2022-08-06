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

## Dependencies

First, we install the dependencies:

```sh
apt install -y nginx python3-certbot-nginx mariadb-server php7.4 php7.4-{fpm,bcmath,bz2,intl,gd,mbstring,mysql,zip,xml,curl}
```

*Optionally*, you can improve the performance of your Nextcloud server by adjusting the child processes that are used to execute PHP scripts. That way, more PHP scripts can be executed at once. Make the following adjustments to `/etc/php/7.4/fpm/pool.d/www.conf`:

```systemd
pm = dynamic
pm.max_children = 120
pm.start_servers = 12
pm.min_spare_servers = 6
pm.max_spare_servers = 18
```

Start the MariaDB server:

```sh
systemctl enable mariadb --now
```

### Setting up a SQL Database

Next, we need to set up our SQL database by running a Secure
Installation and creating the tables that will store data that Nextcloud
will need. Run the following command:

```sh
mysql_secure_installation
```

We can say "Yes" to the following questions, and can input a root password.

```sh
Switch to unix_socket authentication [Y/n]: Y
Change the root password? [Y/n]: Y	# Input a password.
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

### HTTPS

As with any subdomain, we need to obtain an SSL certificate.

```sh
certbot certonly --nginx -d nextcloud.example.org
```

### Nginx configuration


In `/etc/nginx/sites-available/` we need to make a new configuration for
Nextcloud (example: `/etc/nginx/sites-available/nextcloud`).


Add the following content [based of Nextcloud's recommendations](https://docs.nextcloud.com/server/latest/admin_manual/installation/nginx.html) to the file, **remembering to replace `nextcloud.example.org` with your Nextcloud domain**.

```nginx
upstream php-handler {
    server unix:/var/run/php/php7.4-fpm.sock;
    server 127.0.0.1:9000;
}
map $arg_v $asset_immutable {
    "" "";
    default "immutable";
}
server {
    listen 80;
    listen [::]:80;
    server_name nextcloud.example.org ;
    return 301 https://$server_name$request_uri;
}
server {
    listen 443      ssl http2;
    listen [::]:443 ssl http2;
    server_name nextcloud.example.org ;
    root /var/www/nextcloud;
    ssl_certificate     /etc/letsencrypt/live/nextcloud.example.org/fullchain.pem ;
    ssl_certificate_key /etc/letsencrypt/live/nextcloud.example.org/privkey.pem ;
    client_max_body_size 512M;
    client_body_timeout 300s;
    fastcgi_buffers 64 4K;
    gzip on;
    gzip_vary on;
    gzip_comp_level 4;
    gzip_min_length 256;
    gzip_proxied expired no-cache no-store private no_last_modified no_etag auth;
    gzip_types application/atom+xml application/javascript application/json application/ld+json application/manifest+json application/rss+xml application/vnd.geo+json application/vnd.ms-fontobject application/wasm application/x-font-ttf application/x-web-app-manifest+json application/xhtml+xml application/xml font/opentype image/bmp image/svg+xml image/x-icon text/cache-manifest text/css text/plain text/vcard text/vnd.rim.location.xloc text/vtt text/x-component text/x-cross-domain-policy;
    client_body_buffer_size 512k;
    add_header Referrer-Policy                      "no-referrer"   always;
    add_header X-Content-Type-Options               "nosniff"       always;
    add_header X-Download-Options                   "noopen"        always;
    add_header X-Frame-Options                      "SAMEORIGIN"    always;
    add_header X-Permitted-Cross-Domain-Policies    "none"          always;
    add_header X-Robots-Tag                         "none"          always;
    add_header X-XSS-Protection                     "1; mode=block" always;
    fastcgi_hide_header X-Powered-By;
    index index.php index.html /index.php$request_uri;
    location = / {
        if ( $http_user_agent ~ ^DavClnt ) {
            return 302 /remote.php/webdav/$is_args$args;
        }
    }
    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }
    location ^~ /.well-known {
        location = /.well-known/carddav { return 301 /remote.php/dav/; }
        location = /.well-known/caldav  { return 301 /remote.php/dav/; }
        location /.well-known/acme-challenge    { try_files $uri $uri/ =404; }
        location /.well-known/pki-validation    { try_files $uri $uri/ =404; }
        return 301 /index.php$request_uri;
    }
    location ~ ^/(?:build|tests|config|lib|3rdparty|templates|data)(?:$|/)  { return 404; }
    location ~ ^/(?:\.|autotest|occ|issue|indie|db_|console)                { return 404; }
    location ~ \.php(?:$|/) {
        # Required for legacy support
        rewrite ^/(?!index|remote|public|cron|core\/ajax\/update|status|ocs\/v[12]|updater\/.+|oc[ms]-provider\/.+|.+\/richdocumentscode\/proxy) /index.php$request_uri;
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
        fastcgi_max_temp_file_size 0;
    }
    location ~ \.(?:css|js|svg|gif|png|jpg|ico|wasm|tflite|map)$ {
        try_files $uri /index.php$request_uri;
        add_header Cache-Control "public, max-age=15778463, $asset_immutable";
        access_log off;     # Optional: Don't log access to assets
        location ~ \.wasm$ {
            default_type application/wasm;
        }
    }
    location ~ \.woff2?$ {
        try_files $uri /index.php$request_uri;
        expires 7d;
        access_log off;
    }
    location /remote {
        return 301 /remote.php$request_uri;
    }
    location / {
        try_files $uri $uri/ /index.php$request_uri;
    }
}
```

Enable the site by running this command:

```sh
ln -s /etc/nginx/sites-available/nextcloud /etc/nginx/sites-enabled/
```

## Installing Nextcloud Itself

We should have all the moving pieces in place now, so we can download and
install Nextcloud itself. First, download the latest Nextcloud version and we will extract into `/var/www/` and ensure Nginx has the authority to use it.

```sh
wget https://download.nextcloud.com/server/releases/latest.tar.bz2
tar -xjf latest.tar.bz2 -C /var/www
chown -R www-data:www-data /var/www/nextcloud
chmod -R 755 /var/www/nextcloud
```

Start and enable php-fpm and reload nginx:

```sh
systemctl enable php7.4-fpm --now
systemctl reload nginx
```

Now we need to head to Nextcloud\'s web interface. In a web browser, go to the domain we have installed Nextcloud on:

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

In the event that anything goes wrong with the web interface of Nextcloud, Nextcloud has a commandline utility bundled with it called `occ`. You can use it with the following command:

```sh
sudo -u www-data php /var/www/nextcloud/occ
```

You can make this an alias by putting it in your `~/.bashrc` file for ease of use with the following alias:

```sh
alias occ="sudo -u www-data php /var/www/nextcloud/occ"
```

Enjoy your cloud services in freedom.

## Contributor(s)

- [Matthew \"Madness\" Evan](https://github.com/MattMadness)
- Edits by Luke
