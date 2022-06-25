---
title: "Log on with SSH Keys"
date: 2021-06-29
tags: ['server']
---
Let\'s generate and use SSH keys on our computer. This allows us to
ensure our identity better than a password ever could. This allows us to
do two main things:

1.  **Password-less login**: With SSH keys, we can permanently designate
    our profile on our local computer as safe for our server, allowing
    us to bypass password verification when logging into our server.
2.  **Prevent hacking**: Since we no longer need a password to log in,
    we can simply deactivate password logins on our server altogether,
    which prevents hacking from people who may be so lucky as to guess
    our password!

In other words, using an SSH key to login is **both safer, faster and
easier**.

This is especially useful once you start making scripts on your computer
that interact with your server. You can upload files in the background,
edit your spam filters or anything else from your local computer without
having to input your password each time you touch the server.

## Generate an SSH key pair

Generating an SSH key is simple. Just run:

```sh
ssh-keygen
```

It will prompt you for several options and you can generally chose the
default options in each case. It will ask you to optionally include a
password on your SSH key. I generally recommend against this unless you
happen to be using a computer where you don\'t have root access but
someone else does (it does minimize the ease of using an SSH key in our
case).

### What does this SSH key do?

Now whenever you use `ssh` to log into a server, you have the public key
of this SSH key pair as your identifier. You can tell your server to
trust this key and it will automatically allow password-less logins from
this computer.

### Backing up your key

We will do that momentarily, but first, I recommend you backup your
newly generated key if you plan to use it. If we disable logins to this
one key and then lose the key, we might be locked out of our server.

I suggest copying your entire `~/.ssh/` directory (user-specific) to a
USB drive and storing it securely. You may also copy it to the same
place on another computer to use the key there.

## Making your server trust your key.

Now that you have generated an SSH key, just run the following:

```sh
ssh-copy-id root@yourdomain.com
```

The command will ask for your server\'s root password and log you in
briefly. What this does is that it puts your public SSH key fingerprint
on your server in a file `/root/.ssh/authorized_keys`. This file in turn
allows approved SSH keys to log in without passwords.

Note that you can also replace **root** with a username of an account on
the server if you had made a non-root user that you\'d like to easily
log into as well. For the username **user**, it will also store the key
in `/home/user/.ssh/authorized_keys`.

To test if this has worked, now try logging in normally to your server
with ssh:

```sh
ssh root@yourdomain.com
```

It should now let you log in without a password prompt!

If you find that this does not work try running the following, make sure
you are in the directory where the keys where created.

```sh
chmod 700 ~/.ssh/
chmod 644 ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/authorized_keys
```

For whatever reason these files due not have the correct permissions
set, as ssh is very picky about correct file permissions this can cause
errors. The above will fix these.

## Disabling Password Logins for Security

Once we have authorized ssh keys for all the devices we need, we can
actually just disable password logins. If you\'ve ever looked at your
system logs (`journalctl -xe`) you will find that there are always
hundreds of random Chinese computers trying to brute force every server
connected to the internet with random passwords. They are usually
unsuccessful, but let\'s make it **impossible** for them.

Log into your server and open the `/etc/ssh/sshd_config` file. Here we
can set settings for our SSH daemon that receives SSH requests.

Now find, uncomment or create the following three lines and set them all
to **no**:

```sh
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM no
```

Once we\'ve done that, we will reload our SSH daemon:

```sh
systemctl reload sshd
```

### We\'re done!

Now you can log in quickly and password-less-ly to your server, despite
the fact that it is now more secure than ever!

With these settings, even if a hacker steals or perfectly guesses an
account password, they still cannot log in without an approved SSH key!

## What if I lose my SSH key?!

Firstly, don\'t do this. Take every precaution that you have a backup.

If this does happen, Vultr and most other VPS providers will have a way
out. Log onto their website and select the server you want to log into.

{{< img src="/pix/ssh-01.png" alt="vultr login" >}}

In the image above, to the right of your VPS name are a series of icons.
Click on the computer screen-like icon which is the leftmost one.

This will open up a browser window emulating a terminal and you can
always login with your password here, since logins here count as being
local---they do not use SSH and therefore can indeed validate with
your password even if you have disabled it over SSH.

From here, simply reverse the settings we set above and you can log in
via SSH with a password and reapprove a newly created SSH key or
whatever you want to do.
