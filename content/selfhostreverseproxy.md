---
title: "Exposing self-hosted services through a reverse proxy VPS" 
date: 2024-05-25
tags: ['server']
---
## Introduction

Self-hosting brings far greater control, upgradeability and flexibility than renting out a VPS. However,
directly exposing your IP and network brings certain security risks. Not to mention things like port forwarding
can be a bit messy. Thankfully, using a cheap VPS as a reverse proxy for the self-hosted machine these problems can be mitigated for minimal cost.
The machines are connected using a VPN and the VPS uses a reverse proxy to pass conenctions to the relevant port on the host machine. This guide will use
tinc for the VPN and Caddy for reverse proxying, as they work well and have dead simple configuration. In addition, Caddy automatically handles getting and renewing
SSL certs.

## Preface

This guide assumes you're using Debian as the OS on both machines, which shall be referred to as `home` and `vps` respectively.
I have performed this setup using Debian 12, however 11/10 should work the same. In addition, this guide assumes you have a domain name
and have already pointed it to the IP of the VPS.

## Installation

### Installing tinc and net-tools

Install tinc and net-tools with apt on both machines:
```sh
apt install net-tools tinc
```

### Installing Caddy

On `vps`, import Caddy's repository:
```sh
apt install -y debian-keyring debian-archive-keyring apt-transport-https

curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg

curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
```

Afterwards, run an update and install Caddy with apt:
```sh
apt update
apt install caddy
```

## Configuring tinc

### Creating directories

On both machines, create the directories needed for your VPN configuration:

```sh
sudo mkdir -p /etc/tinc/myvpn/hosts
```

Replace `myvpn` with whatever you wish to name your VPN network.

### Writing tinc.conf files

On both systems, make a file called `/etc/tinc/myvpn/tinc.conf`.

On `vps`, write the following in that file:
```
Name = vps
AddressFamily = ipv4
Interface = tun0
ConnectTo = home
```

Conversely, on `home`'s `tinc.conf` write the following:
```
Name = home
AddressFamily = ipv4
Interface = tun0
ConnectTo = vps
```

### Writing host files

On `vps`, write the following to the file `/etc/tinc/myvpn/hosts/vps`:

```
Address = <vps public IP>
Subnet = 10.0.0.1/32
```

Afterwards, run the following command:

```sh
tincd -n myvpn -K4096
```
This will create an RSA keypair for the system and append the public key to the end of the host file you just wrote.

On home, write the following to the file `/etc/tinc/myvpn/hosts/home`:

```
Subnet = 10.0.0.2/32
```
Afterwards, run the same `tincd` command seen previously. Copy the `home` file to the `/etc/tinc/myvpn/hosts` directory on vps
and vice-versa.

### Writing tinc-up and tinc-down scripts

`tinc-up` and `tinc-down` are scripts used by tinc to start and stop the network interface used by a particular network.
On both machines, write the following to `/etc/tinc/melon/tinc-up`:

```
#!/bin/sh
ifconfig $INTERFACE 10.0.0.2 netmask 255.255.255.0
``` 

and write the following to `/etc/tinc/melon/tinc-down`:
```
#!/bin/sh
ifconfig $INTERFACE down
```

Afterwards, on both machines make those script files executable using `chmod +x tinc-up/down`.

## Running tinc

### Verifying connectivity

To start the tinc daemon, run the following command on both systems:
```sh
systemctl start tinc@myvpn
```

To test if tinc is working properly, run `ping 10.0.0.2` from `vps` and `ping 10.0.0.1` from `home`. If 
the ping is successful, tinc is up and running properly. In addition, you can run `ip a` to check if the VPN interface is up with
the proper subnet address. Finally, you can then enable tinc at startup using
`systemctl enable tinc@myvpn`.

## Running self-hosted services over this VPN

To run a self-hosted service over the VPN, the application must be configured to listen on the subnet IP where it would normally
listen on `localhost` (`127.0.0.1`). Take Pleroma's configuration, as an example. In the file `prod.secret.exs`, the following section
sets the application to listen for incoming connections `localhost:4000`:
```
config :pleroma, Pleroma.Web.Endpoint,
  ...
  http: [ip: {127, 0, 0, 1}, port: 4000],
  ...
```

The reverse proxy program (e.g. Nginx, Apache, Caddy) then sends incoming connections to that localhost port.
To get it to run on our setup, this config would be the following:
```
config :pleroma, Pleroma.Web.Endpoint,
  ...
  http: [ip: {10, 0, 0, 2}, port: 4000],
  ...
```

Afterwards, the reverse proxy on the vps can pass to this subnet address to make the application accessible on the public internet.

## Setting up Caddy

Write the following to `/etc/caddy/Caddyfile` on `vps`:
```
your.domain.here {
	reverse_proxy 10.0.0.2:yourporthere
}
```

Replace `your.domain.here` with your domain and `yourporthere` with whatever port your service is listening on.
Afterwards, start caddy with `systemctl start caddy` and go to your domain in a browser. If it directs you to the default
Caddy page, it means your Caddyfile is valid and you should run `systemctl restart caddy` after.

If you have followed this guide successfully, congratulations on successfully setting up a VPS reverse proxy! Now you can selfhost in peace.

## Additional notes

If you prefer Nginx over Caddy, the following configuration should work:
```
server {
    listen 80;
    server_name myapp.example.com;

    location / {
        proxy_pass http://10.0.0.2:8383;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Useful links

- [Gentoo wiki page on tinc](https://wiki.gentoo.org/wiki/Tinc)
- [Alpine wiki page on setting up a tinc VPN](https://wiki.alpinelinux.org/wiki/Setting_up_a_VPN_with_tinc)

----

Written by Tadano
