---
title: "GitWeb"
date: 2023-08-21
short_desc: "Git's \"official\" read-only web frontend."
icon: 'git.svg'
tags: ['service']
---
Once you have your own Git server, you might want to allow others to browse your
repositories. GitWeb, similar to [Cgit](/cgit), is a CGI script written by the
authors of Git which allows browsing repositories over the web.

Note that just like Cgit, GitWeb is a read-only frontend. If you want to have
collaboration features such as issues and pull requests, consider installing
[Gitea](/gitea) instead.

## Installing gitweb and fgciwrap

NGINX isn't capable of running CGI scripts by itself, so we'll need to install
an intermediate layer named fcgiwrap to run CGI scripts such as GitWeb:

```sh
apt install fcgiwrap
```

If you want syntax highlighting, you'll also need to install `highlight`:
```sh
apt install highlight
```

Now, we can install GitWeb itself:

```sh
apt install gitweb
```

## Setting up NGINX

By now, you should have NGINX running with a TLS certificate. Add the following
configuration to a new file in `/etc/nginx/sites-available`:

```nginx
server {
	server_name {{<hl>}}git.example.org{{</hl>}};

	location /gitweb.cgi {
		include fastcgi_params;
		fastcgi_param SCRIPT_FILENAME /usr/share/gitweb/gitweb.cgi;
		fastcgi_param GITWEB_CONFIG /etc/gitweb.conf;
		fastcgi_pass unix:/run/fcgiwrap.socket;
	}

	location / {
		root /usr/share/gitweb;
		index gitweb.cgi;
	}

	location ~ /.+/(info/refs|git-upload-pack) {
		include fastcgi_params;
		fastcgi_param SCRIPT_FILENAME /usr/lib/git-core/git-http-backend;
		fastcgi_param PATH_INFO $uri;
		fastcgi_param GIT_PROJECT_ROOT {{<hl>}}/srv/git{{</hl>}};
		fastcgi_param HOME {{<hl>}}/srv/git{{</hl>}};
        # git-daemon's default setting is to not export repositories without
        # a "git-daemon-export-ok" file.
        # To export everything regardlessly, uncomment the following line:
        # fastcgi_param GIT_HTTP_EXPORT_ALL 1;
		fastcgi_pass unix:/run/fcgiwrap.socket;
	}

    # Certbot configuration goes here...
}
```

Symlink the configuration file into `/etc/nginx/sites-enabled` and reload NGINX.

## Configuring GitWeb

Open `/etc/gitweb.conf` in your favorite editor, clear it and paste the following:

```perl
# path to git projects (<project>.git)
$projectroot = "{{<hl>}}/srv/git{{</hl>}}";
# directory to use for temp files
$git_temp = "/tmp";
# if this file exists, export the repository
# if you want to export all repositories regardless of this file, comment
$export_ok = "git-daemon-export-ok";
# list of base URLs, will be used for generating clone URLs
@git_base_url_list = qw(https://{{<hl>}}git.example.org{{</hl>}});
# enable syntax highlighting, comment if highlight is not installed
$feature{'highlight'}{'default'} = [1];
# git-diff-tree(1) options to use for generated patches
# -M is for detecting renames, add more if desired
@diff_opts = ("-M");
```

GitWeb is very configurable and this example is just scratching the surface, be
sure to read the `gitweb.conf` man page for a full list of options.

If you decided to enable use of the `git-daemon-export-ok` file, be sure to
`touch` it in every repository you wish to be browsable and clonable over HTTPS.

## Final touches
To fill in the repository owner field, set the git option `gitweb.owner` (run
the command as `git`):

```sh
git -C /path/to/repository config gitweb.owner "User <someone@somewhere.com>"
```
*Note: This config **has** to be set per each repository, setting it globally will
do nothing!*

To fill in the description field, simply fill it in at
`/path/to/repository/description`.

## Contribution
[Duje Mihanović](http://dujemihanovic.xyz) - XMR:
`85qXBHh99bJ62p7s8upmoqYsvHrJvZWLTD7riHFo3E2jRvdQRoiNuXKRaDMAQiJ34Kfix3KHouNCW6bbD4zniWB5QxZR9Xx`
or OpenAlias
