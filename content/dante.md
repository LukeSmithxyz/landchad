---
title: Dante
date: 2023-05-13
icon: 'dante.png'
tags: ['socks5','proxy','vpn','service']
short_desc: 'SOCKS Proxy software'
---

[Dante](https://www.inet.no/dante/index.html) is a SOCKS server and client
software. SOCKS5 is a network proxy protocol which can be used to route traffic
through your VPS, similar to a VPN. SOCKS5 is useful as several applications
such as browsers and torrent clients. It's especially useful as the proxy
settings can often be entered at an application level meaning the traffic for
specific apps can be routed securely through a proxy connection while leaving
the rest routing through your default network. Also it has the added benefit of
being shareable if you'd like to allow friends without VPNs to connect to
applications through a proxy with minimal setup.  

# Installation

To install Dante on debian install the dante-server package

```sh
apt install dante-server
```

# Configuration

## System setup

### Creating user
Before beginning to configure the dante configuration file, you will first need to
create a user which will be used to authenticate the proxy.

This login may be passed insecurely depending on the login application so it is
important to create this user *without a login shell*. In this guide the user
will be called **prox**.

```sh
useradd -r -s /bin/false prox
passwd prox
```

Once user and password has been created, save the credentials to use for login
later.

### Finding server network interface

As part of the configuration we will need to find the network interface used by
the server the proxy will be hosted on.

To find this information run the `ip a` command.

Generally this will be `eth0` for servers but in my case is the `enp1s0` interface.


### Opening port

Finally, a port will need to be opened to run this proxy. The default port is
1080 however you can use whichever port you'd like and change it in the
configuration file below.

```sh
ufw allow 1080
```


## Dante Configuration

The configuration file for dante is located at `/etc/danted.conf`

Before configuring, it is recommended to create a backup of the default configuration file.

```sh
cp /etc/danted.conf /etc/danted.conf.bak
```

Once a backup is saved, updated the configuration file /etc/danted.conf with the below settings:

```
logoutput: /var/log/socks.log   # Log connections
internal: enp1s0 port = 1080    # Specify internal network interface and port. Port here specifies which port will be used for connecting
external: enp1s0                # External network interface
clientmethod: none              
socksmethod: username           # Authentication method, for this we are using username + passwd
user.privileged: root           # user to be used for privileged operations
user.notprivileged: prox        # Username which is allowed to connect

client pass {
        from: 0.0.0.0/0 to: 0.0.0.0/0
        log: error connect disconnect
}

socks pass {
        from: 0.0.0.0/0 to: 0.0.0.0/0
        log: error connect disconnect
}
```

If more configuration is required, details can be found on the [debain manpage](https://manpages.debian.org/testing/dante-server/danted.conf.5.en.html)
Now that configuration is complete, we can restart the service and verify that it is running correctly.


```sh
systemctl restart danted.service
systemctl status danted.service
```

# Client Side

## Verification

To verify that the proxy is working enter the following command on the client device:

```sh
curl -v -x socks5://prox:USER_PSWD@SERVER_IP:1080 landchad.net
```

NOTE: If the server IP has a domain linked to it, the SERVER_IP field can be
replaced with the site and the DNS server will be used to find the IP.

If the command runs without error, Congratulations your proxy is working correctly.



*Written by [Abbas](https://github.com/abbas-rizvi)*
