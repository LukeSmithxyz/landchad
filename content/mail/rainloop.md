---
title: "Rainloop"
tags: ['service']
icon: 'rainloop.png'
draft: true
short_desc: 'A graphical website for accessing a mail server.'
---
## Dependencies

First, we make sure we have all Rainloop\'s basic dependencies
installed. It requires PHP and some other modules.

    apt install -y nginx curl mariadb-server php php-cli php-fpm php-curl php-json php-mbstring php-mysql php-common php-xml unzip

## Installation

    mkdir /var/www/rainloop
    cd /var/www/rainloop
    wget https://www.rainloop.net/repository/webmail/rainloop-community-latest.zip
