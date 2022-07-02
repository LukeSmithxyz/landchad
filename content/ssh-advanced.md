---
title: "SSH - Advanced Usage"
date: 2022-07-01
tags: ['server']
---

## Introduction

This page is dedicated to advanced SSH usage examples. We will discuss
the following concepts:

-   config files (for client)
-   tunneling
-   jumping

## Config files

Config files allow you to specify certain rules for all or chosen hosts.
The file has a really simple structure. It is divided into sections
which begin with the `Host` keyword. Sections are read one by one and
**the first matching section takes precedence over the remaining
sections**---you write more specific sections at the top and the more
general sections below.

### Why even bother?

You might say that SSH client doesn\'t need any special configuration -
you just type user@host and that\'s it. Well, what happens when you
manage multiple servers? Maybe you want to use a different pair of keys
for each servers? Maybe the server uses a port other than the default 22
to avoid automated bots trying to log in?

That\'s where config files come in handy!

### Example scenario

Let\'s assume that you manage 3 servers, with the following access info:

1.  very.long.hostname.example1.com
    -   user: admin
    -   port: 22
    -   key name: id_rsa
2.  example2.com
    -   user: billthemaster
    -   port: 2222
    -   key name: example2_ecdsa
3.  192.168.133.7
    -   user: management
    -   port: 22
    -   key name: id_rsa

You got tired having to always specify the identity file location with
the `-i` option and the port with `-p` option for example2.com. Don\'t
even mention `admin@very.long.hostname.example1.com`!

In the given example, the config file could look like this:

```text
Host server1
  HostName very.long.hostname.example1.com
  User admin
  IdentityFile ~/.ssh/id_rsa

Host server2
  HostName example2.com
  Port 2222
  User billthemaster
  IdentityFile ~/.ssh/example2_ecdsa

Host server3
  HostName 192.168.133.7
  User management
  IdentityFile ~/.ssh/id_rsa

Host *
  IdentityFile /path/to/some/other/key
  ```

You can see here usage of `Host *`. Options specified in this section
will affect all other hosts.

### But where do I put this file?

SSH looks for the options in the following order:

1.  command line arguments
2.  `~/.ssh/config`
3.  `/etc/ssh/ssh_config`

You can also specify a custom path with the `-F` argument, for example:

```sh
ssh -F ~/Documents/projects/someproject/config/ssh production
```

\...or discard any config file:

```sh
ssh -F /dev/null username@hostname
```

There\'s more to ssh config files, but I direct you to `man ssh_config`
for more information

## SSH Tunneling (\"port forwarding\")

SSH tunneling gives you the ability to route TCP traffic from your
location to the remote server or the other way around (if server allows
for this). Thanks to it, you can set up a secure connection with a
service that doesn\'t provide any encryption by default. You can treat
it like a lite VPN.

You can for example access your SQL server via SSH without opening the
port for public - you just need SSH port opened on the server\'s
firewall. It\'s also a great way of creating a secure channel for
connecting with other hosts on the server\'s network.

### Local to remote

You can route traffic from your local network to the remote server\'s
network by using the `-L` option. Let\'s say you want to access a MySQL
service on the remote server. You can tell SSH to route any traffic that
comes to your 3000 port to port 3306 on the remote server with the
following example:

```sh
ssh -L 3000:localhost:3306 username@example.com
```

The above command states that anyone connecting to your port 3000 will
be routed via the SSH connection to the localhost:3306 from the remote
server\'s perspective

If you can\'t understand the above description, let\'s take a look at
another example:

```sh
ssh -L localhost:8080:192.168.178.25:80 username@example.com
```

The above command states that any traffic coming from your device (and
only yours, because of `localhost`) will be routed via the SSH channel
to `192.168.178.25:80` in the server\'s network.

In general, the argument\'s structure is as follows:

```sh
-L [local_address:][local_port]:[remote_address]:[remote_port]
```

The `local_address` can be your LAN IP, `localhost` or any other address
that your device has. Depending on it, other devices in the specified
network will be able to connect to you or not.

The `remote_address` can be any address reachable from the server.

You can, of course, route multiple ports. For example:

```sh
ssh -L 8000:localhost:8000 -L 8001:localhost:8001 username@example.com
```

Please, remember, this works **only** on TCP based services, **not** UDP
based.

### Remote to local

There might come a need for you to open your locally running service
(for example a game server) to external connections. Let\'s say you
can\'t or don\'t want to set up port forwarding on your router.

You can use SSH to forward any traffic that is coming to a port on
remote server to a port on your local network host. The same as in the
case \"Local to remote\", but the other way around.

However, there is one additional step that is neccessary and requires
you to have a root access to the remote server. You have to edit
`/etc/ssh/sshd_config` file, to instruct SSH server to route traffic to
the other end of SSH connection - your device.\
Find and uncomment or append the one of the following lines to the file:

```text
GatewayPorts yes # to allow all remote devices
GatewayPorts clientspecified # to allow only specific remote devices
```

You can then specify the forwarding rule with the `-R` option, for
example open `192.168.178.2:21` on your local network, to be accessible
from a remote server on port 2100:

```sh
ssh -R 2100:localhost:21 username@example.com
```

\...or provide access only to your friend with an IP `111.111.111.111`:

```sh
ssh -R 111.111.111.111:2100:localhost:21 username@example.com
```

You can replace `localhost` with any host accessible from your local
device, for example your local media server etc.

## SSH Jumping

Jumping is a method of connecting to a target via one or more
intermediate servers. This can be used to access servers behind
firewalls etc. All connections on the chain are encrypted and routed via
SSH.

You can easily jump as shown in the following example:

```sh
ssh -J username1@example1.com username2@example2.com
```

You can also specify multiple intermediaries, by separating them with a
comma:

```sh
ssh -J username1@example2.com,username2@example.com username3@example3.com
```

There is also a possibility to set up \"jumping\" connection in a config
file:

```text
Host intermediary1
  HostName target.intermediary-example.com
  User john

Host target1
  HostName target.example.com
  ProxyJump intermediary1

Host target2
  HostName target2.example.com
  ProxyJump username@example1.com
  ```
