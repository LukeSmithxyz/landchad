---
title: "Rsync: Upload and Sync Files and Websites"
date: 2021-07-01
img: 'rsync.png'
tags: ['server']
---

rsync is a simple way to copy files and folders between your local computer and
server. While you can install [Nextcloud](/nextcloud) is a more normie-friendly
Dropbox/Google Drive-like way to share files, people familiar with the
command-line will find all they need in the simple `rsync` command.

It not only makes file-transfer easy, but it allows you to build and
maintain your website offline, then easily upload it to the proper
directory on your server so you don\'t need to constantly be logged into
your server to modify your site.

## Installing rsync

Run the following on your server *and* on your local machine.

```sh
apt install rsync
```

## Uploading files with rsync

From your local machine you can upload files to your server like this:

```sh
rsync -rtvzP /path/to/file root@example.org:/path/on/the/server
```

You will be prompted for the root password and then uploading will
commence.

If you omit **root@**, rsync will not attempt to log in as root, but
whatever your local username is.

### Options to rsync

In this command, we give several options to rsync. You can remove some of these
or add to them based on your needs:

-   `-r` -- run recurssively (include directories)
-   `-t` -- transfer modification times, which allows skipping files
    that have not been modified on future uploads
-   `-v` -- visual, show files uploaded
-   `-z` -- compress files for upload
-   `-P` -- if uploading a large file and upload breaks, pick up where
    we left off rather than reuploading the entire file

Avoid using the commonly used `-a` option when uploading to a server. It can
transfer your local machine\'s user and group permissions to your
server, which might cause breakage.

But `-a` is useful for making back-ups of important directories. It's an alias for many options at once (`-rlptgoD`)---read `man rsync` for the details.

### Scriptability

It\'s a good idea to build your website offline, then make an rsync
script or bash alias like the one above to upload the edited files when
you have made updates.

### Password-less authentication

To avoid having to manually input your password each upload, you can set
up [SSH keys](/sshkeys) to securely idenitify yourself and computer
as a trusted.

### Picky trailing slashes

rsync is very particular about trailing slashes. This is useful, but can
be confusing to some new users. Suppose we run the following wanting to
mirror our offline copy of our website in the directory we use on our
server (`/var/www/websitefiles/`):

```sh
❌ rsync -rtvzP ~/websitefiles/ root@example.org:/var/www/websitefiles/
```

This will *not actually do quite what we want*. It will take our local
`websitefiles` directory and put it *inside* `websitefiles` on the
remote machine, ending up with `/var/www/websitefiles/websitefiles`.

Instead, remove the trailing slash from the remote server location:

```sh
✅ rsync -rtvzP ~/websitefiles/ root@example.org:/var/www/websitefiles
```

`websitefiles/` has been replaced with `websitefiles`, and this will do
what we want.

## Downloading files with rsync {#downloading-file-with-rsync}

You may just as easily download files and directories from your server
with rsync:

```sh
rsync -rtvzP root@example.org:/path/to/file /path/to/file
```

If you don't keep a local copy of your website or other things saved on a server🔒, it might be a good idea to set up a [cronjob](/cron) or just a normal script on your local computer that takes back-ups of your website in case of server failure!
