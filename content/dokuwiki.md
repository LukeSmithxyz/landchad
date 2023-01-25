---
title: "DokuWiki"
icon: 'dokuwiki.svg'
tags: ['service']
short_desc: 'A simple wiki with clean syntax and no databases.'
---

[DokuWiki](https://www.dokuwiki.org) is a simple wiki software, similar to MediaWiki. Unlike MediaWiki, it uses plain text files to store its content, not databases, making it simpler to configure than MediaWiki. It's a good choice if you want a simple wiki engine without all the bells and whistles of MediaWiki and the additional step of setting up databases.

## Installation

Although DokuWiki is available on the main debian repos, it is outdated and has a different directory structure, which may lead to problems with plugins and make it harder to follow the official documentation, so we're gonna install it from a tarball.

First, install the dependencies.

```sh
apt install nginx php php-fpm php-xml php-mbstring php-zip php-intl php-gd 
```

Now, get the tarball.

```sh
wget https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz
tar xzvf dokuwiki-stable.tgz
mv dokuwiki-*a /var/www/dokuwiki
chown -R www-data:www-data /var/www/dokuwiki
```

## Nginx Configuration

Create a file named `/etc/nginx/sites-available/dokuwiki` using your favorite text editor and add the following lines, based on the configuration [here](https://www.dokuwiki.org/install:nginx). **Remember to change `wiki.example.org` to your website's name.** Also, pay attention to the lines containing `client_max_body_size`, which determines the maximum file size upload, and the first `location` line, because it needs to be commented during the installation and uncommented when it's done.

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name wiki.example.org;
 
    # Maximum file upload size is 4MB - change accordingly if needed
    client_max_body_size 4M;
    client_body_buffer_size 128k;
 
    root /var/www/dokuwiki;
    index doku.php;
 
    #Remember to comment the below out when you're installing, and uncomment it when done.
    #location ~ /(conf/|bin/|inc/|vendor/|install.php) { deny all; }
 
    #Support for X-Accel-Redirect
    location ~ ^/data/ { internal ; }
 
    location ~ ^/lib.*\.(js|css|gif|png|ico|jpg|jpeg)$ {
        expires 365d;
    }
 
    location / { try_files $uri $uri/ @dokuwiki; }
 
    location @dokuwiki {
        # rewrites "doku.php/" out of the URLs if you set the userwrite setting to .htaccess in dokuwiki config page
        rewrite ^/_media/(.*) /lib/exe/fetch.php?media=$1 last;
        rewrite ^/_detail/(.*) /lib/exe/detail.php?media=$1 last;
        rewrite ^/_export/([^/]+)/(.*) /doku.php?do=export_$1&id=$2 last;
        rewrite ^/(.*) /doku.php?id=$1&$args last;
    }
 
    location ~ \.php$ {
        try_files $uri $uri/ /doku.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param REDIRECT_STATUS 200;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        # fastcgi_pass unix:/var/run/php5-fpm.sock; #old php version
    }
}
```

Enable the website.

```sh
ln -s /etc/nginx/sites-available/dokuwiki /etc/nginx/sites-enabled/
```

Generate a SSL certificate for the subdomain.

```sh
certbot --nginx
```

Restart nginx and php in order for the changes to take effect.

```sh
systemctl restart nginx && systemctl restart php7.4-fpm 
```

Finally, go to `wiki.yourwebsite.com/install.php` to finish the installation process. Read up [the documentation](https://www.dokuwiki.org/installer) in order to understand what each of those itens mean.

Once that's done, remember to uncomment the `location` line on the nginx configuration file. Open `/etc/nginx/sites-available/dokuwiki` with a text editor and remove the "#" symbol at the beginning of the line.

```nginx
#Remember to comment the below out when you're installing, and uncomment it when done.
location ~ /(conf/|bin/|inc/|vendor/|install.php) { deny all; }
```

Reload nginx once again for the changes to take effect.

```sh
systemctl restart nginx
```

Your wiki is now live! Have fun and happy hacking.

**Contributor** - [Adachi](https://github.com/AdachiWasRight)
