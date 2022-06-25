---
title: "RSS Bridge"
date: 2021-07-05
tags: ['service']
icon: 'rss.svg'
short_desc: 'Creates RSS feeds for normie sites like Facebook.'
---
RSS Bridge is a useful utility you can use to help you avoid the big
tech sites, like Facebook and Twitter, which instead of the feed you
usually would see, will be a based and minimalist RSS feed.

You\'ll need a server or VPS. Nearly any Operating system is supported
but for this tutorial I\'m gonna presume you\'re using a Debian-based
OS. You\'ll also need a domain name pointing to your server\'s IP
address [which is explained in this tutorial.](/basic/dns)

## Installation

### Setting Up and Configuring

First things first you\'ll need to make sure that you\'ve hardened you
SSH so that password authentication is disabled and you\'ll also want to
setup Fail2Ban. There\'s a great tutorial on how to do this [which can be read here.](/sshkeys)

Next we\'ll install the required packages:

```sh
apt install -y curl unzip nginx certbot php-fpm php-mysql php-cli php7.4-mbstring php7.4-curl php7.4-xml php7.4-sqlite3 php7.4-json
```

We now have to create the website configuration file. Create/open the a
file below:

```sh
nano /etc/nginx/sites-available/rss-bridge
```

And add the following content:

```nginx
server {
    root /var/www/rss-bridge;
    index index.php index.html index.htm index.nginx-debian.html;
    server_name rss-bridge.example.org;

    location / {
            try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
    }

    location ~ /\.ht {
            deny all;
    }
}
```

After you have saved the file, you need to create a symlink so the
server actually will read the file.

```sh
ln -s /etc/nginx/sites-available/rss-bridge /etc/nginx/sites-enabled/rss-bridge
```

Then we have to create the folder where the service will reside in.

```sh
mkdir -p /var/www/rss-bridge
cd /var/www/rss-bridge
```

Lets download the latest version of RSS-Bridge in the directory.

The newest version can be found
[here](https://github.com/RSS-Bridge/rss-bridge/releases), at the time of
writing that is \"RSS-Bridge 2021-04-25.\"

```sh
wget https://github.com/RSS-Bridge/rss-bridge/archive/refs/tags/2021-04-25.zip
```

Unzip the file:

```sh
unzip 2021-04-25.zip
```

This will create a directory called rss-bridge-version-number, we now
want to move all the file contents of the newly created directory to the
one we are in

```sh
mv rss-bridge-2021-04-25/* .
rm -rf rss-bridge-2021-04-25 2021-04-25.zip
```

Now all we need to do is grant read/write permissions and reload the web
server.

```sh
chown -R www-data:www-data /var/www/rss-bridge
systemctl reload nginx
```

That\'s it, you should now have a working rss-bridge installed. But you
should definately get an SSL certifcate installed [which is done briefly here](/basic/certbot).

-   [handskemager.xyz](https://handskemager.xyz)
-   Bitcoin: `bc1qhfjgwjzksf2auqjefwpvq20wvyugq3lhqgkxvu`{.crypto}
-   Monero:
    `88cPx6Gzv5RWRRJLstUt6hACF1BRKPp1RMka1ukyu2iuHT7iqzkNfMogYq3YdDAC8AAYRqmqQMkCgBXiwdD5Dvqw3LsPGLU`{.crypto}
