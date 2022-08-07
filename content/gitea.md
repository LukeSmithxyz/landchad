---
title: "Gitea"
date: 2020-07-02
icon: 'gitea.svg'
tags: ['service']
short_desc: "A fully-featured Github-like git website for serious software projects and communities."
---

Gitea allows you to self-host your git repositories similar to [bare
repositories](/git), but comes with additional features that you might know
from GitHub, such as issues, pull requests or multiple users. Its advantage
over GitLab---another Free Software GitHub clone---is that it is much more
lightweight and easier to setup.

Head over to [gitea.com](https://gitea.com) to see what it looks like in
practice.

Although Gitea is lighter than Gitlab, if you have a VPS with only 512MB of
RAM, you will probably have to upgrade. Gitea is more memory-intensive than
having just a bare git repository. If you just want a minimalist browseable git
server without  issue tracking and pull requests, install [cgit](/cgit)
instead.

## Installing Gitea

First install a few dependencies:

```sh
apt install curl sqlite3
```

Unfortunately, Gitea itself is not in the official Debian repos, so we
will add a third-party repository for it.

Add the repo\'s gpg key to apt\'s trusted keys:

```sh
curl -sL -o /etc/apt/trusted.gpg.d/morph027-gitea.asc https://packaging.gitlab.io/gitea/gpg.key
```

Then add the actual repository to apt:

```sh
echo "deb [arch=$(dpkg --print-architecture)] https://packaging.gitlab.io/gitea gitea main" > /etc/apt/sources.list.d/morph027-gitea.list
```

Now we can install Gitea:

```sh
apt update
apt install gitea
```

Since apt automatically enables and starts the Gitea service, it should
already be running on port `3000` on your server!

## Setting up a Nginx reverse proxy

You should know how to generate SSL certificates and use Nginx by now.
Add this to your Nginx config to proxy requests made to your git
subdomain to Gitea running on port 3000:

```nginx
server {
	listen 443 ssl;
	listen [::]:443 ssl;
	ssl_certificate /etc/ssl/nginx/{{<hl>}}git.example.org{{</hl>}}.crt;
	ssl_certificate_key /etc/ssl/nginx/{{<hl>}}git.example.org{{</hl>}}.key;
	server_name {{<hl>}}git.example.org{{</hl>}};
	location / {
		proxy_pass http://localhost:3000/; # The / is important!
		proxy_redirect off;
		proxy_set_header Host $host;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_set_header X-Forwarded-Proto $scheme;
	}
}
```


And reload Nginx:

```sh
systemctl reload nginx
```

## Setting up Gitea

If everything worked fine you should now see a setup screen when you go
to your configured domain in the browser. The options should be pretty
self-explanatory, it is only important to select SQLite3 and to replace
the base url and SSH server domain with your own.

Database Type:
:   SQLite3

SSH Server Domain:
:   **git.example.org**

Gitea Base URL:
:   **git.example.org**

These and other settings can be changed in a configuration file later so
don\'t worry about making wrong decisions right now.

After clicking the install button you should now be able to log into
your Gitea instance with the account you just created! Explore the
settings for more things to do, such as setting up your SSH keys.

If Gitea does not load fully and has random errors, it is possible that
you need to increase your available memory on your VPS. This can usually
be done on your VPS-provider\'s website without too much trouble.

## A few extras

### Automatically create a new repo on push

This is an incredibly useful feature for me. Open up
`/etc/gitea/app.ini` and add `DEFAULT_PUSH_CREATE_PRIVATE = true` to the
`repository` section like so:

```systemd
[repository]
ROOT = /var/lib/gitea/data/gitea-repositories
DEFAULT_PUSH_CREATE_PRIVATE = true
```

If you now add a remote to a repository like this

```sh
git remote add origin 'ssh://gitea@{{<hl>}}git.example.org{{</hl>}}/username/coolproject.git'
```

and push, Gitea will automatically create a private `coolproject`
repository in your account!

### Change tab-width

By default Gitea displays tabs 8 spaces wide, however I prefer 4 spaces.
We can change this!

```sh
mkdir -p /var/lib/gitea/custom/templates/custom/
```

And write this into
`/var/lib/gitea/custom/templates/custom/header.tmpl`:

```css
<style>
.tab-size-8 {
tab-size: 4 !important;
-moz-tab-size: 4 !important;
}
</style>
```

## Contribution

-   [phire](https://phire.cc)
