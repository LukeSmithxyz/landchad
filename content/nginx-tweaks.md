---
title: "Nginx Tweaks"
date: 2022-06-16
---

The point of this article is to show you how to do some commonly-desired tweaks
in Nginx while in the meantime helping you understand how it works.

## Do not require `.html` in URLs

If your website is using lots of `.html` files for pages, it\'s sort of
overkill to make people type that in for every page they are looking for. We
can remove that requirement with Nginx.

Open your site\'s configuration file in `/etc/nginx/sites-enabled/` and within
the `server` block, there should be a `location` block that looks something
like this if you have followed [the guide here](/basic/nginx).

```nginx
location / {
    try_files $uri $uri/ =404 ;
}
```

What this means is that in the file location of `/`, i.e. anywhere and
everywhere in the root file system, We will look for the three things listed in
`try_files` in that order:

1.  `$uri`: a file that directly matches the content added after the domain.
2.  `$uri/`: a *directory* that directly matches the content added after the
    domain.
3.  `=404`: if neither of those is found, we give a 404 error, which as you
    probably know, signified \"Page not found.\"

We will now change the content inside the `location` block to the below:

```nginx
location / {
    if ($request_uri ~ ^/(.*)\.html$) { return 302 /$1; }
    try_files $uri $uri.html $uri/ =404 ;
}
```

`$1` here refers to the first content in the parentheses `()` in the preceeding
regular expression.
