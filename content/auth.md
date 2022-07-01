---
title: "Requiring Passwords for Webpages (HTTP Authentication)"
date: 2020-07-01
img: 'auth.svg'
tags: ['server']
---

HTTP basic authentication will allow you to secure parts (or all) of
your website with a username and password without the trouble of PHP or
Javascript. This will work with any Nginx server.

## Installation

We will be using the command `htpasswd` to make username and password
pairs.

```sh
apt install apache2-utils
```

The apache utils include a small username-password pair encryption tool.

Like the other tutorials on this site, this tutorial is for Nginx,
**not** for Apache servers.

Now think of a username and password and remember them.

    htpasswd -c /etc/nginx/myusers username

The `-c` flag creates a file. You can make the path of this file
anywhere outside of your webroot.

Obviously the username is up to you as well.

Type out your password twice to confirm. You can do this as many times
as you\'d like.

Check out user name password pairs (the password will be securely
hashed):

    cat /etc/nginx/myusers

## Nginx Config and Auth Basic

From here, we are going to edit our websites config file in
`/etc/nginx/sites-enabled`. Have in mind which folder you\'d like to
secure. Add something like this:

```nginx
server {
    #...
    location /secret-folder  {
        auth_basic "What's the Password?" ;
        auth_basic_user_file /etc/nginx/myusers ;
    }
    #...
}
```

#### Huh?

If you\'re stuck, try finding the line `location / {`

Just below this block is where you should add the custom location block

If you\'d like to do the opposite, such as making the entire site
private except for a public section, do this:

```nginx
server {
    #...
    auth_basic "What's the Password?" ;
    auth_basic_user_file /etc/nginx/myusers ;
    location /public/ {
        #...
        auth_basic off ;
    }
    #...
}
```

### IP Addresses

If passwords aren\'t enough we can ban an ip or accept one.

```nginx
location /api {
    #...
    allow 192.168.1.23:8080 ;
    deny 127.0.0.1 ;
}
```

If you want to check both a username and password with an ip address,
use the `satisfy` directive.

```nginx
location /api {
    #...
    satisfy all ;

    allow 192.168.1.23:8080 ;
    deny 127.0.0.1 ;

    auth_basic "What's the Password?" ;
    auth_basic_user_file /etc/nginx/myusers ;
}
```

### Complete Example

```nginx
http {
    server {
        listen 80;
        root /var/www/website ;

        #...
        location /secret-folder {
            satisfy all ;

            allow 192.168.1.3/24;
            deny 127.0.0.1 ;

            auth_basic "What's the Password?" ;
            auth_basic_user_file /etc/nginx/myusers ;
        }
    }
}
```

Now check your configuration with `nginx -t`

Reload nginx and you\'re good to go!

**Contributor** - [tomfasano.net](https://tomfasano.net)
