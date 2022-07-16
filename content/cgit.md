---
title: "Cgit"
date: 2021-09-14
short_desc: 'A hyperfast web frontend for git repositories.'
icon: 'cgit.svg'
tags: ['service']
---
Once you have your server hosting your git repositories, you might want
to allow others to browse your repositories on the web. Cgit is a Free
Software that allows browsing git repositories through the web.

Note that Cgit is a read-only frontend for Git repositories and doesn\'t
have issues, pull requests or user management. If that\'s what you want,
consider installing [Gitea](/gitea) instead.

## Installing cgit and fcgiwrap

### Install fcgiwrap

NGINX doesn\'t have the capability to run CGI scripts by itself, it
depends on an intermediate layer like fcgiwrap to run CGI scripts like
cgit:

```sh
apt install fcgiwrap
```

And now we can install cgit itself with:

```sh
apt install cgit
```

## Setting up NGINX

You should have an NGINX server running with a TLS certificate by now.
Add the following configuration to your server to pass the requests to
Cgit, while serving static files directly:

```nginx
server {
    listen 443 ssl;
    listen [::]:443 ssl;
    ssl_certificate /etc/ssl/nginx/git.example.org.crt;
    ssl_certificate_key /etc/ssl/nginx/git.example.org.key;
    server_name git.example.org;

    root /usr/share/cgit ;
    try_files $uri @cgit ;

    location @cgit {
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME /usr/lib/cgit/cgit.cgi;
        fastcgi_param PATH_INFO $request_uri;
        fastcgi_param QUERY_STRING $query_string;
        fastcgi_pass unix:/run/fcgiwrap.socket;
    }
}
```

Then get NGINX to reload your configuration.

## Configuring cgit

You\'ve got cgit up and running now, but you\'ll probably see it without
any style and without any repository. To change this, we need to
configure Cgit to our liking, by editing `/etc/cgitrc`.

```txt
css=/cgit.css
logo=/cgit.svg
virtual-root=/

# Title and description shown on top of each page
root-title=Chad's git server
root-desc=A web interface to LandChad's git repositories, powered by Cgit

# The location where git repos are stored on the server
scan-path=/srv/git/
```

This configuration assumes you followed the [git hosting guide](/git)
and store your repositories on the `/srv/git/` directory.

Cgit\'s configuration allows changing many settings, as documented on
the cgitrc(5) manpage installed with Cgit.

### Changing the displayed repository owner

Cgit\'s main page shows each repo\'s owner, which is \"git\" in case you
followed the git hosting guide, but you might want to change the name to
yours. Cgit shows the owner\'s system name, so you need to modify the
git user to give it your name:

```sh
usermod -c "Your Name" git
```

### Changing the repository description

Navigate to your bare repository on the server and edit the
`description` file inside it

### Displaying the repository idle time

To do this, we need to create a post-receive hook for each repository
that updates the file cgit uses to determine the idle time. Inside your
repository, create a file `hooks/post-receive` and add the following
contents:

```sh
#!/bin/sh

agefile="$(git rev-parse --git-dir)"/info/web/last-modified

mkdir -p "$(dirname "$agefile")" &&
git for-each-ref \
    --sort=-authordate --count=1 \
    --format='%(authordate:iso8601)' \
    >"$agefile"
```

And give it execution permissions with:

```sh
chmod +x hooks/post-receive
```

Next time you push to that repository, the idle time should reset and
show the correct value.

### Allowing clone via HTTPS

If you want others to be able to clone your git repository, you might
need to enable the `git://` daemon or give public SSH access, both of
which have their cons. You can set up your NGINX server to call a git
subprogram that allows cloning anonymously via HTTP(S).

To do this, add the following lines to your nginx server, above the
`location @cgit` line we added before:

```nginx
location ~ /.+/(info/refs|git-upload-pack) {
    include             fastcgi_params;
	fastcgi_param       SCRIPT_FILENAME /usr/lib/git-core/git-http-backend;
	fastcgi_param       PATH_INFO           $uri;
	fastcgi_param       GIT_HTTP_EXPORT_ALL 1;
	fastcgi_param       GIT_PROJECT_ROOT    /srv/git;
	fastcgi_param       HOME                /srv/git;
	fastcgi_pass        unix:/run/fcgiwrap.socket;
}
```

Note: `GIT_PROJECT_ROOT` and `HOME` must point to the location where
your repositories are stored.

You can also add the `clone-prefix` setting to cgit so the clone URL
is shown for each repository:

```txt
clone-prefix=https://git.example.org
```

## Contribution

-   Ariel Costas -- [website](https://costas.dev)
