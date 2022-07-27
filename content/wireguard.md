---
title: "Wireguard"
date: 2022-07-26
icon: 'wireguard.svg'
tags: ['service']
short_desc: "Fast, Modern, Secure VPN Tunnel"
---

Looking for lightweight privacy on the go? Then consider hosting a WireGuard VPN service.
In addition to this setup guide, we'll also demonstrate how to tunnel
your WireGuard traffic through a TLS WebSocket connection to circumvent some
deep packet inspection systems.

As an example, we'll be using a virtual 172.16.0.0/24 network, but any private ip range will suffice.

## Installation

### On the Server
Install the WireGuard management tools:

    apt install wireguard

Enable IPv4 forwarding by uncommenting the following line in `/etc/sysctl.d/99-sysctl.conf`

    net.ipv4.ip_forward=1

Run the following command to apply the change:

    sysctl -w net.ipv4.ip_forward=1

### On the Client
Use your package manager to install the WireGuard Management Tools.
On Arch and Fedora based distros the package is `wireguard-tools`. For Debian based, it's listed above.

Create the public and private keys for your machine:

    sudo bash -c "umask 077 ; wg genkey > /etc/wireguard/client_priv.key"
    sudo bash -c "wg pubkey < /etc/wireguard/client_priv.key > /etc/wireguard/client_pub.key"


### Back to the Server

Generate the public and private keys for your server:

    umask 077 ; wg genkey > /etc/wireguard/server_priv.key
    wg pubkey < /etc/wireguard/server_priv.key > /etc/wireguard/server_pub.key

Create a WireGuard configuration file `/etc/wireguard/wg0.conf`, where `wg0` is the name of the network interface:

    [Interface]
    Address = 172.16.0.1/24
    ListenPort = 51820
    PrivateKey = (server's private key goes here)
    # Firewall rules
    PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

    [Peer]
    # Client #1 details
    PublicKey = (client's public key goes here)
    # Traffic to route to this client
    AllowedIPs = 172.16.0.2/32

Paste the server's private key and client's public key on their respective
lines, each being around 45 characters with an equal sign at the end.

#### Note on extra peers

In our example, the subnet could recognize up to 254 other peers. Add the new
peer's info below the first peer and update the `AllowedIPS` line to the next virtual
ip. Don't change the `32`: this ensures everyone's tunnel is isolated.
Use this optionally for extra devices or for friends.

Enable and start the WireGuard service:

    systemctl enable --now wg-quick@wg0.service

Change `wg0` to match the name of the config file if you called it something different.

### Back to the Client

Create another WireGuard configuration file in `/etc/wireguard/myvpn.conf`:

    [Interface]
    Address = 172.16.0.2/24
    PrivateKey = (client's private key goes here)
    # Set to your desired DNS server
    # DNS = 9.9.9.9

    [Peer]
    PublicKey = (server's public key goes here)
    # Endpoint (server) can be a domain name or IP address
    Endpoint = (server's IP address goes here):51820
    # Traffic to route to server
    AllowedIPs = 0.0.0.0/0, ::/0

Fill in your information where needed. Remember to use your server's public ip address, not the wireguard one.

Start WireGuard:

    sudo wg-quick up myvpn

If you cannot ping `172.16.0.1` or reach the Internet, and have meticulously followed this guide so far,
there's a good chance you're behind a corporate firewall. Read on.

## WebSocket Tunnel

#### Note on TLS
If your server hosts a website with https, you won't be able to use port 443 to
obfuscate your WireGuard packets as TLS traffic. You may use some other innocuous
port, but there's no guarantee you'll punch through the picky firewall.

### On the Server

Download and install wstunnel:

    wget https://github.com/erebe/wstunnel/releases/download/v4.0/wstunnel-x64-linux
    mv wstunnel-x64-linux /usr/local/bin/wstunnel
    chmod uo+x /usr/local/bin/wstunnel
    setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/wstunnel

Make a new systemd service config file, `/etc/systemd/system/wstunnel.service`:

    [Unit]
    Description=Tunnel WireGuard UDP over websocket
    After=network.target

    [Service]
    Type=simple
    User=nobody
    ExecStart=/usr/local/bin/wstunnel -v --server wss://0.0.0.0:443 --restrictTo=127.0.0.1:51820
    Restart=no

    [Install]
    WantedBy=multi-user.target

Enable and start wstunnel:

    systemctl enable --now wstunnel

### On the Client

Download and install wstunnel and a helper script:

    wget https://github.com/erebe/wstunnel/releases/download/v4.0/wstunnel-x64-linux
    sudo mv wstunnel-x64-linux /usr/local/bin/wstunnel
    sudo chmod +x /usr/local/bin/wstunnel
    wget https://codeberg.org/onasaft/sbx/raw/branch/main/vpn/wstunnel.sh
    sudo mv wstunnel.sh /etc/wireguard/wstunnel.sh
    sudo chmod +x /etc/wireguard/wstunnel.sh

Create the wstunnel configuration file, `/etc/wireguard/myvpn.wstunnel`:

    REMOTE_HOST=(server's IP address goes here)
    REMOTE_PORT=51820
    # Use the following line if you're connecting to your VPN server using a domain name.
    # UPDATE_HOSTS='/etc/hosts'

Edit `/etc/wireguard/myvpn.conf`. Change the `Endpoint` line to `127.0.0.1:51820` and add these four lines to the `[Interface]` section:

    Table = off
    PreUp = source /etc/wireguard/wstunnel.sh && pre_up %i
    PostUp = source /etc/wireguard/wstunnel.sh && post_up %i
    PostDown = source /etc/wireguard/wstunnel.sh && post_down %i

Start WireGuard again:

    sudo wg-quick up myvpn

To disconnect, type `down` instead of `up`. And just like that, you now host a WireGuard VPN server!

**Contributor** - [tomfasano.net](https://tomfasano.net)
