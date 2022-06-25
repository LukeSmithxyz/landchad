---
title: "Movim"
draft: true
icon: 'movim.svg'
tags: ['service']
short_desc: 'An XMPP-based social media site, blog and chat site.'
---
## Installing the Packages and Database

### Dependencies

    apt install -y nginx python3-certbot-nginx postgresql composer php-fpm php-curl php-mbstring php-imagick php-gd php-pgsql php-xml git

### Installing Movim Itself

    cd /var/www
    git clone https://github.com/movim/movim.git
    cd movim
    composer install

### Preparing Permissions

    cd /var/www
    chown www-data movim &&  chown www-data movim/public &&  chmod u+rwx movim

### Database setup

    su - postgres # Become the postgres user
    psql # Open a postgresql prompt
    CREATE USER movim WITH PASSWORD 'yourpassword' ;
    CREATE DATABASE movim WITH OWNER movim ;
    \q

leave postgres user

We now have to tell movim to use this newly created postgresql username
and database that we\'ve created. Create a new file in
`/var/www/movim/config/db.inc.php` and add the following content:

    <?php
    $conf = [
        'type'        => 'pgsql',
        'username'    => 'movim',
        'password'    => 'yourpassword',
        'host'        => 'localhost',
        'port'        => 5432,
        'database'    => 'movim'
    ];

ask for pass https://movim.yourdomain.com Choose postgresq localhost
pass

## Configuration with nginx

Let\'s create an nginx configuration file for this movim site. I will
create a file `movimsite.conf` in `/etc/nginx/sites-available/` and add
the following content:

    server {
            listen 80 ;
            listen [::]:80 ;
            server_name movim.lukesmith.xyz ;
            include /etc/nginx/snippets/movim.conf ;
            location / {
                    try_files $uri $uri/ =404;
            }
    }

Note above that this is calling the file
`/etc/nginx/snippets/movim.conf` which contains the content needed for
Movim and should be autocreated when installing the Debian package.

To enable the site, let\'s link the file to the `sites-enabled`
directory and then reload nginx to update it.

    ln -s /etc/nginx/sites-available/movimsite.conf /etc/nginx/sites-enabled/
    systemctl reload nginx

Now, run [certbot](/basic/certbot) which we installed above to get secured
connections on your site. Choose to \"Redirect\" unencrypted connections
when prompted.

    certbot --nginx

## Systemd service

Let\'s create a systemd service for Movim. Create the file
`/etc/systemd/system/movim.service` and add the content below:

    [Unit]
    Description=Movim daemon
    After=nginx.service network.target local-fs.target

    [Service]
    User=www-data
    Type=simple
    Environment=PUBLIC_URL=https://localhost/movim/
    Environment=WS_PORT=8080
    EnvironmentFile=-/etc/default/movim
    ExecStart=/usr/bin/php daemon.php start --url=${PUBLIC_URL} --port=${WS_PORT}
    WorkingDirectory=/var/www/movim/
    StandardOutput=syslog
    SyslogIdentifier=movim
    PIDFile=/run/movim.pid
    Restart=on-failure
    RestartSec=10

    [Install]
    WantedBy=multi-user.target

    systemctl daemon-reload
    systemctl restart movim

Install prosody modules apt install mercurial mkdir -p
/usr/share/prosody hg clone https://hg.prosody.im/prosody-modules/
/usr/share/prosody/modules
