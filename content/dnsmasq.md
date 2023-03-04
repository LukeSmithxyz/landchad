---
title: "Dnsmasq"
icon: 'dnsmasq.svg'
tags: ['service']
short_desc: "Host your own DNS server to block ads and social media."
date: 2022-09-13
---

[Dnsmasq](https://dnsmasq.org) is a libre DNS and DHCP system that allows anyone to run a DNS server to resolve domains.
Normally to block domains and ads, users on most operating systems can edit their **`/etc/hosts` file** or use one of the many existing ad-blocking hosts collections available online.
However, if you're trying to block ads **over your entire home network** and do not have access to your router's hosts file,
then setting up your own DNS server can be very advantageous.

This also comes with the benefit of increased flexibility regarding name resolution;
for example, with Dnsmasq, you can employ the usage of **wildcard domains** to block massive ranges of ads, trackers and entire social media networks.

## Before we begin...
while Dnsmasq is very versatile software that can be used for a variety of networking and DNS applications,
this guide assumes you only want to setup Dnsmasq to **block domains from resolving** (ie. ads and social media sites).
It is possible to get **custom domain resolution** and **internal network services** running using Dnsmasq,
but this is beyond the scope of this article.

## Installation
Dnsmasq is available in the Debian repositories:
```
apt install dnsmasq
```

## Configuration
### Basic configuration
By default, Dnsmasq will start a DNS server listening on `localhost:53`.
You can even test this if you have the `bind9` package installed:

```sh
dig @localhost example.org
```

This command should return the A DNS records for `example.org`.

We can configure Dnsmasq to listen on the public internet by editing its config file, `/etc/dnsmasq.conf`.
In this file, you'll find this line, commented out:

```sh
#interface=
```
We need to specify the **interface we wish to listen on** to provide the DNS service.
In most cases (such as when using a Debian VPS) this will simply be `eth0`.
However, please run `ip a` to determine which interface is correct for your system, if you're unsure.

```sh
interface={{<hl>}}eth0{{</hl>}}
```

It's also **highly recommended** to uncomment this following line,
just to prevent Dnsmasq from forwarding requests to local names.
```
domain-needed
```

Now all we have to do is restart Dnsmasq's systemd service:

```sh
systemctl restart dnsmasq
```

And, on our **local machine,** we can try using the `bind9` utilities to test our DNS server:
```sh
dig @{{<hl>}}your_servers_public_ip{{</hl>}} example.org
```

This should return the correct A DNS records for `example.org`, like when testing using `localhost`.

### Changing Authoritative DNS Providers
By default, Dnsmasq will use the DNS servers provided in `/etc/resolv.conf`.
You can change this file directly, altering DNS resolution for your entire system:

```sh
# Quad9 DNS Server
nameserver  {{<hl>}}9.9.9.9{{</hl>}}
nameserver  {{<hl>}}149.112.112.112{{</hl>}}
```

## Blocking DNS Requests

### Using a Hostsfile
As mentioned previously, one of Dnsmasq's advantages is that it can read `/etc/hosts` and other host resolution files.
This makes it 100% compatible with existing ad-blocking hosts files.

```sh
0.0.0.0     www.youtube.com
0.0.0.0     www.reddit.com
```
This hosts file blocks `www.youtube.com` and `www.reddit.com`.

To read another hosts file, in addition to `/etc/hosts`, you can use the following in `/etc/dnsmasq`:
```sh
addn-hosts=/etc/hosts.2
```

The only complication is that **every time you update the hosts file, Dnsmasq must be restarted:**

```sh
systemctl restart dnsmasq
```

### Using Dnsmasq's Configuration
For more advanced forms of DNS blocking, such as **domain wildcards,** you can edit `/etc/dnsmasq.conf` directly:

```sh
address=/{{<hl>}}netflix.com{{</hl>}}/0.0.0.0
```
This configuration will block all requests to `netflix.com` and its subdomains. This way you **don't need a massive hosts file** containing every single possible subdomain. All you need to know is the root domain.

And as usual, remember to restart the Dnsmasq systemd service every time the configuration is altered.
```
systemctl restart dnsmasq
```

## Using Dnsmasq
If you intend to use your new DNS server on your home network,
this is as easy as setting your primary DNS resolver in your router's settings to your **DNS server's public IP address.**

For example, on a local Linux machine, you could edit `/etc/resolv.conf`:
```sh
nameserver  {{<hl>}}your_servers_public_ip{{</hl>}}
```

Generally this should be an intuitive process on most router interfaces,
and most OS' will let you edit the DNS in their respective network settings.

---

Written by [Denshi.](https://denshi.org)
Donate Monero at:
`48dnPpGgo8WernVJp5VhvhaX3u9e46NujdYA44u8zuMdETNC5jXiA9S7JoYMM6qRt1ZcKpt1J3RZ3JPuMyXetmbHH7Mnc9C`
