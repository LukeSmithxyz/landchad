---
title: "Git Server"
date: 2020-07-01
icon: 'git.svg'
tags: ['service']
short_desc: "Hosting your own basic git server."
---

Once you have your own VPS or other Internet-available server, you can
start hosting your own git repositories. The goal of this tutorial is
for you to go from

```sh
git clone github.com/...
```

to

```sh
git clone YourLandChadDomainName.xyz/...
```

so you can cultivate your own homegrown, grass-fed code, rather than
relying on a centralized proprietary service like GitHub.

## Installing git

You most likely already have it installed on your server, but if not,
run:

```sh
apt install git
```

We don\'t need any additional software, `git` itself ships with
everything needed to host a remote repository!

## Creating bare repositories

For each repository you want to host, you will need to manually create
what\'s called a \"bare\" repository on your server. These hold all the
commits and any other git data needed for your repository, but without
an expanded \"index\" in which you can just browse all the files of a
certain commit in the file system.

These repositories need to be owned by the `git` user, and you should
probably pick a directory where you will store them all. One sane choice
is under `/srv/git/`, and we will use this as the example directory for
the rest of the tutorial, but any other path will do as well.

### Become the git user and create the directory

If you\'re logged in to your server as root and have `git` installed,
you can become the `git` user by executing

```sh
su git
```

Now navigate to/create your desired directory, for example

```sh
cd /srv
mkdir git
```

### Create the repo

Now you can create the bare repository with

```sh
git init --bare my-repo.git
```

By convention, bare repository names end with \".git\".

Repeat the above command for any other repositories you want to host.

## Syncing local repositories with your server

### Set up SSH login for the git user

You will need to be able to login remotely via `ssh` as the `git` user
we\'ve used before. To do this, you will either need to set up a
password for the `git` user by running `passwd git`, or copy your public
SSH key from your local machine to `/home/git/.ssh/authorized_keys`. See
the [SSH keys instructional](/sshkeys) for details (just log in as
`git` instead of `root`).

### Syncing a new repository with your server

If you\'ve just created a new repository on your local machine, you will
need to tell `git` where the remote repository is to be able to sync
with it (using commands like `git push` or `git pull`). We do this by
defining a \"remote\" for your repository.

A remote is just a named URL remembered in your repo\'s configuration.
So we need a name and a URL. By convention, the \"main\" remote is
called \"origin\". The URL has the format `user@host:path`, where:

-   `user` is `git`, the `git` user we\'ve already worked with before.
-   `host` is your domain name. Alternatively you could even use your
    server\'s raw IP address.
-   `path` is the absolute path to the repository on the server, in our
    example `/srv/git/my-repo.git`

So, to create a new remote, run:

```sh
git remote add origin git@yourdomain.xyz:/srv/git/my-repo.git
```

Now you\'ll be able to run `git push origin master` to push your commits
or `git pull origin` to pull from the remote.

### Syncing an existing repository

If you\'ve already set up your local repository to sync with a service
like GitHub it probably already has a remote called \"origin\". You can
see your repo\'s remotes with:

```sh
git remote -v
```

You can follow the above instructions, substituting an arbitrary other
name other than \"origin\" to create a differently named remote, e.g.

```sh
git remote add vps git@...
```

Now you\'ll be able to push/pull with `git push vps master` and
`git pull vps`, respectively.

Or, to completely sever ties with your centralized git provider, first
remove the original origin with: `git remote remove origin` and then
follow the instructions as above.

## Contribution

-   Martin Chrzanowski \-- [website](https://m-chrzan.xyz),
    [donate](https://m-chrzan.xyz/donate.html)
