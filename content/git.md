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

## Creating a git user

To prevent exploiting your system, services should usually be run under another
user that can only affect the relevant parts of the server. Let's create a user
for git.

```sh
useradd -m git -d /var/git -s /bin/bash
```

The `git` user's home directory will be `/var/git` and we also set the default
user shell as bash instead of sh for ease when on the command line.

### Become the git user and create the directory

If you\'re logged in to your server as root and have `git` installed,
you can become the `git` user by executing

```sh
su -l git
```

The `-l` option should put us in `git`'s home directory, but you can `cd
/var/git` otherwise.

### Create the repo

Now you can create the bare repository with

```sh
git init --bare {{<hl>}}my-repo.git{{</hl>}}
```

By convention, bare repository names end with \".git\". (A bare repository is
just one without the file index, (i.e. the familiar browseable file structure).)

Repeat the above command for any other repositories you want to host.

## Syncing local repositories with your server

### Set up SSH login for the git user

Git uses SSH to connect to a server, and we will definitely want to use an SSH
key pair that we authorized. This is not only most secure, but also easiest
since we don't need to put in our password whenever we pull or push.

There is a brief article [on setting up SSH keys](/sshkeys). We need to do
exactly that, but for the `git` user, instead of the default `root` user. Note
that if you want to upload your SSH key directly to the git user as in that
tutorial, remember to run `passwd git` to give the git user a password so you
can log in.

If you've already set up password-less SSH log-ins for root (and disabled SSH
password authentication), you can run the following commands as root, which
will copy over your authorized key to the git user as well.

```sh
mkdir /var/git/.ssh	# Create the required directory.
cp ~/.ssh/authorized_keys /var/git/.ssh/	# Copy over the authorized key.
chown git:git -R /var/git/.ssh	# Make the created directory and contents to be owned by the git user.

```

### Syncing a new repository with your server

How that we've set that up, we can push a repository we have on our computer to
that newly created bare repo. First, on our local computer, we run a command like this:

```sh
git remote add origin git@{{<hl>}}example.org{{</hl>}}:{{<hl>}}my-repo.git{{</hl>}}
```

Note some of the things you will change:

- `example.org`, obviously is a stand-in for your domain name.
- `my-repo.git` is the name of the repository, but it is also the relative location of it. Since it is in the `git` user's home directory, we don't need anything else, but if you decide to put a git repository elsewhere---like in `/var/www/git/stuff.git`, you can provide that absolute file location instead.
- `origin` is a unique name for your remote repository. Since "origin" is probably already used if you are using Github or another service, you'll want to change this to whatever you want. Could be `myserver` or `vps` or `own`, as long as it is unique.

Once you run that command successfully to add a new remote repository, and also assuming you change `origin` to let's say the more unique `personal`, you can push your local git server as expected:

```sh
git push {{<hl>}}personal{{</hl>}} master
```

That's all a git server is! Very simple.

If you want a minimalist front-end to a git server, follow our guide on [cgit](/cgit)!

If you want a large and user-friendly Github-like site for your git projects, follow our guide on [Gitea](/gitea)!

## Contribution

- Martin Chrzanowski \-- [website](https://m-chrzan.xyz), [donate](https://m-chrzan.xyz/donate.html)
- Edits and fixes by Luke.
