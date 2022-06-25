---
title: "Maintaining a Server"
date: 2021-06-29
tags: ['server']
---
Here are some important topics you should be familiar with whenever you
are managing a server.

## Keep packages up to date. {#update}

All GNU/Linux distributions use package managers to easily be able to
install and update packages without manually downloading them. On
Debian, which we use here for these tutorial the package manager is
`apt-get` or `apt` for short.

It\'s a good idea to use `apt` to keep your software reasonably up to
date.

```sh
apt update
apt upgrade
```

Not only do up-to-date packages often come with more features, but they
can also fix any possible security bugs.

## Troubleshooting general problems

Often when you are installing something new, you might miss a step and
run into an error, so it\'s important to know how to check and see what
errors have happened on your computer.

On Debian and other GNU/Linux distributions that use systemd (most of
them), you can use the command `journalctl` to look at the system\'s
general log. You will probably want to run `journalctl -xe` as the `-x`
and `-e` as that gives the most information and starts you at the bottom
of the log to see the most recent errors.

Some programs do not use this system log, but have their own logs stored
in `/var/log/`, or sometimes it\'s more convenient to look at a specific
program\'s log to see only its issues.

For example, we can see that in `/var/log/nginx/`, nginx produces both
`error` and `access` files. The `access` files show you all the times
people connect to files on your server and much more. We can look at the
most recent errors by running:

```sh
tail -n 25 /var/log/nginx/error.log
```

The command `tail -n 25` means \"show me the last 25 lines of this
file.\" You can replace that with `less` to browse the whole file. In
`less`, navigate with arrows or vim-keys and exit with `q`.

### systemctl

Another tool on systemd distributions is `systemctl`. At a basic level,
use `systemctl status put-service-name-here` to see if a system service
is running and its most recent log. But there\'s much more to
`systemctl`.

For example, you can run `systemctl stop nginx` to stop NginX and
`systemctl start nginx` to start it back up (or use `restart` for both).
When you make changes to a program\'s configuration files, `reload` well
make them reload them. If you no longer want a service to start when the
system is rebooted, use `disable`, or conversely, to make a service
start on reboot use `enable`.

## Finding Files

Especially if you\'re new to how a GNU/Linux system is arranged, you
might need help finding files. To find program-related files, you can
just use `whereis`:

```sh
$ whereis nginx
nginx: /usr/sbin/nginx /usr/lib/nginx /etc/nginx /usr/share/nginx /usr/share/man/man8/nginx.8.gz
```

This command lists the directories related to that program. For example,
`/etc/nginx` is where the configuration files are and `/usr/share/nginx`
is where the library and module-like files are.

But `whereis` can be used only with installed programs. A more general
tool is the pair of `updatedb` and `locate`.

`updatedb` is a command that quickly indexes every file and directory on
your computer. Then you can run `locate` to find a file containing a
given name. After running `updatedb`, try running `locate nginx` to find
all files with \"nginx\" in their name.

You can make your search more specific by chaining other Unix commands
through pipes. For example, `grep` takes input and returns only lines
that match an extra argument. In the example below, we `locate` all
files with \"nginx\" in the name, but we use `grep` to only show us
those with the word \"available\" in them.

```sh
root@landchad:~# locate nginx | grep available
/etc/nginx/modules-available
/etc/nginx/sites-available
/etc/nginx/sites-available/default
/etc/nginx/sites-available/landchad
/usr/share/nginx/modules-available
/usr/share/nginx/modules-available/mod-http-auth-pam.conf
/usr/share/nginx/modules-available/mod-http-dav-ext.conf
/usr/share/nginx/modules-available/mod-http-echo.conf
/usr/share/nginx/modules-available/mod-http-geoip.conf
/usr/share/nginx/modules-available/mod-http-image-filter.conf
/usr/share/nginx/modules-available/mod-http-subs-filter.conf
/usr/share/nginx/modules-available/mod-http-upstream-fair.conf
/usr/share/nginx/modules-available/mod-http-xslt-filter.conf
/usr/share/nginx/modules-available/mod-mail.conf
/usr/share/nginx/modules-available/mod-stream.conf
```

`updatedb` is an ideal candidate for a [cronjob](/cron) so you
don\'t have to worry about running each time. For example, adding the
following to your crontab will run `updatedb` every 30 minutes:

```sh
*/30 * * * * /usr/bin/updatedb
```
