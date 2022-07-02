---
title: Networking Basics
date: 2022-07-01
tags: ['concepts']
---

## A quick detour to binary

You probably know that everything computers do, they do in binary
(zeroes and ones) under the hood. But how does that actually work?

Binary is just another numbering system like decimal (there are many
others!), so while with decimal each digit can have 10 different values
(0-9, hence **deci**mal), numbers represented in binary have 2 possible
values (0-1, hence **bi**nary). In binary a digit is called a bit.

What is the highest number you can represent with one digit in decimal?
Easy: 9. So how many different values are there? 10 (0-9).

What about 2 digits? 99 and 100, respectively. 3 digits? 999 and 1000.
I\'m sure I don\'t need to bore you by continueing.

### The maths behind it

Can we define a formula for the amount of possible values a decimal
number with `n` digits can have?

It\'s pretty easy: <code>10<sup>n</sup></code>.

Now the 10 there in a numbering system where each digit can have 10
different values can\'t be a coincidence!

So we can generalize: In a numbering system where each digit can have
`x` different values, the amount of possible values for a number with
`n` digits is <code>x<sup>n</sup></code>.

So how many different values can we represent with 8 Bits (1 Byte)?
<code>2<sup>8</sup> = 256</code> (0-255).

The IPv4 addresses you know are 32 bits long. So how many computers
could we theoretically assign unique IPs to on the internet?
<code>2<sup>32</sup> = 4,294,967,296</code>. That\'s 4 Billion! However there are far more
computers than that on the internet now, which is why people had to come
up with hacks (which we\'ll talk about later) so that we can today still
predominantly use pretty IPv4, as opposed to that ugly new IPv6 (eww).

We\'ll say \"IP address\" instead of \"IPv4 address\" from here on.

By the way, this principle goes a long way in computing! Say, for
example, I know your password is 7 letters long and contains only
lowercase english letters (a-z). How many times would I have to guess at
maximum to crack your password? <code>25<sup>7</sup> = 6,103,515,625</code> times.

### Converting from binary to decimal

You can use the same principle to convert from one numbering system to
another. Each digit gains \"significance\", starting at zero going from
right to left. This is easiest understood through an example from
decimal:

<pre><code>943 = 9*10<sup>2</sup> + 4*10<sup>1</sup> + 3*10<sup>0</sup> = 900 + 40 + 3 = 943</code></pre>

The same holds true for binary:

<pre><code>11001101 = 2<sup>7</sup> + 2<sup>6</sup> + 2<sup>3</sup> + 2<sup>2</sup> + 2<sup>0</sup> = 128 + 64 + 8 + 4 + 1 = 205</code></pre>

### The binary behind IP addresses

As mentioned, IP addresses are made up of 32 bit, or 4 byte. IP
addresses are usually represented in \"dotted-decimal\" notation, where
we write the decimal value of the first byte (left-to-right), a dot,
then the decimal value of the second byte, etc.

So, in theory, the lowest possible IP address is `0.0.0.0` (all bits are
0) and the highest possible IP address is `255.255.255.255` (all bits
are 1).

## Subnetting

Open up a terminal and run

```sh
ip a
```

You should see many names, such as `wlan*` or `wlp*` for wireless
interfaces or something like `eth*` or `enp*` for ethernet interfaces.
I\'ve used a new word here: \"interfaces\", we\'ll talk more about what
those are later.

Here\'s my WiFi interface:

{{< img alt="wifi interface" src="/pix/networking-wlan0.png" link="/pix/networking-wlan0.png" >}}

We can see an IP address, `192.168.1.221`, and another one which we\'ll
ignore for now. Did I just leak my IP address? No, it is only my local
IP, it could even be that yours is the same as mine!

There are two reasons for this:

1.  There is a [list of IP address
    ranges](https://en.wikipedia.org/wiki/Reserved_IP_addresses#IPv4)
    reserved for you to use however you want, here in local networking.
    You will not find a server on the internet that has an IP in one of
    those ranges.
2.  The hack to get around the limitations of IPv4 I mentioned earlier
    is [NAT (Network Address
    Translation)](https://en.wikipedia.org/wiki/Network_address_translation).
    Your router gives every device in your local network one of those
    reserved IPs and manages one public IP towards the internet for all
    of them. So instead of every device needing one of those 4 Billions
    IPs, only every house needs one. And some ISPs take this a level
    further and again put multiple houses under one NAT, so multiple
    houses can share one IP towards the internet (Carrier-Grade NAT).

If you followed the link for reserved IP address ranges or looked closer
at my screenshot, you will see IP addresses followed by a slash and then
some number, here `/24`. This is how we denote IP ranges in networking,
the so-called CIDR-Notation. The first ip address in the range is the
**Network ID** and the number after the slash is the **subnet mask**. It
might look strange at first, but makes a lot of sense: The subnet mask
is the amount of bits **fixed**. So here in my case the first 24 bits (3
bytes) are fixed and my local network\'s IP range, also called
**subnet**, goes from `192.168.1.0` to `192.168.1.255`.

Here are two popular reserved subnets and their IP ranges:

```
192.168.0.0/16: 192.168.0.0 – 192.168.255.255
10.0.0.0/8:     10.0.0.0    – 10.255.255.255
```

Here\'s another popular one, but note that the subnet mask isn\'t
divisible by 8, so it is a bit less easy to deal with:

```
172.16.0.0/12: 172.16.0.0 – 172.31.255.255
```

The way this works is the first byte is fully fixed, and then the first
4 bits of the second byte are fixed too, the rest is usable by us. So in
the second byte the last `8-4 = 4` bits are free. <code>2<sup>4</sup> = 16</code>, giving us
the actual highest number 15. We add this to the \"starting point\", the
current value of the second byte, and arrive at `16+15 = 31`!

Don\'t worry if that last part about uneven subnet-masks was confusing
to you, you won\'t have to deal with them as a regular user.
Additionally there are websites where you can enter subnets and they do
the maths for you.

## Interfaces

I\'ve mentioned interfaces a few times now without really explaining
what they are. Generally you can think of interfaces as physical
networking devices. If you have a WiFi-Card in your computer, it will
get an interface. If you have an ethernet card, it will get another one.
If you now plug in something like a USB WiFi dongle, it will get another
interface.

There are also virtual interfaces. For example if you run a virtual
machine with something like virt-manager, use containers with docker or
connect to a VPN through OpenVPN or WireGuard, all those get virtual
interfaces.

We can assign IP addresses to interfaces and Linux then knows that when
it receives a packet who\'s recipient is that IP, it is meant for us.
Then later with routing we can tell Linux to send packets destined to,
say, `192.168.3.0/24`, to our ethernet interface, which will make Linux
send that data to the ethernet card, which will in turn send it through
the actual physical cable!

Here\'s a bigger picture of the full output of `ip a` on my machine:

{{< img alt="output of ip a" src="/pix/networking-interfaces.png" link="/pix/networking-interfaces.png" >}}

We can see a few interfaces here:

-   `lo`: The loopback interface. A virtual interface that makes packets
    to `127.0.0.1` go straight back to your own machine.
-   `wlan0`: My WiFi interface. We can see its state is `UP`, I have the
    IP `192.168.1.221` on the network and the subnet mask is `/24`.
-   `virbr0`: My KVM interface. We can see its state is `DOWN`, I have
    the IP `192.168.122.1` on the network and the subnet mask is `/24`.
-   `wgpi`: An interface for the WireGuard connection I have to my
    Raspberry Pi. I have the IP `10.91.0.2` on the network and the
    subnet mask is `/24`.
-   `wgnord`: An interface for the WireGuard connection I have to a
    remote VPN server. I have the IP `10.5.0.2` on the network and the
    subnet mask is `/32`.

## Routing

Okay, so we\'ve learned about interfaces now. Those don\'t do much by
themselves though, since right now Linux will never really use them. To
make use of them we need to use routing to tell Linux which packets it
should put into those interfaces. These definitions of what outgoing
traffic to put into which interfaces are called routes!

To view the routes set up on your machine, run this command:

```sh
ip r
```

Here\'s the command\'s output on my server:

{{< img alt="output of ip r" src="/pix/networking-server-routes.png" link="/pix/networking-server-routes.png" >}}

And here\'s an excerpt of the interfaces on my server:

{{< img alt="network interface" src="/pix/networking-server-interfaces.png" link="/pix/networking-server-interfaces.png" >}}

The first route containing `default via` is special: All packets that
don\'t match other routes are automatically sent to this interface
(`ens3`). Now you might remember `172.31.1.1` is in one of those
reserved subnets, so this isn\'t another machine on the internet! This
is my server\'s \"gateway\". At home your gateway probably is your
router: You send everything to it and it then forwards those packets to
the internet (or another device on your local network, if you\'re
speaking to another IP within your subnet).

Note also that my server\'s `ens3` interface has an IP address assigned
which is not one of the reserved ones. Therefore my server isn\'t behind
NAT and this is the actual IP my server can be reached at on the
internet! Also note that the subnet mask is `/32`, or \"all bits in this
IP are fixed\".

The second line is for the virtual interface created by docker. All
containers get assigned an IP within the subnet `172.17.0.0/16`, and
this route tells Linux to put packets destined for said subnet into the
`docker0` virtual interface, which then ends up at the container having
that IP. We can see some additional info too: The IP packet\'s source
will be set to `172.17.0.1` and the `linkdown` state signifies that we
have a route set up, but the interface for that route is in `DOWN`
state.

## Putting it all into practice

Now it might be interesting and all to know how Linux does networking,
but as a regular user you\'ve probably never had to touch the `ip`
command in the past: Your server comes set up out of the box and if you
connect to a WiFi, the interface and routes are configured automatically
for you. This is done by your network manager through
[DHCP](https://en.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol).

Recently I\'ve had a use case where I had to configure networking
manually: I wanted to move around 200GB of data from one laptop to
another. Now there are a few ways I could go about this: I could look
for a big enough USB-Drive and move the data that way. Or I could
connect both devices to the same WiFi (they already were) and move the
data over the network using rsync, or sshfs, or scp, or nfs, \... But
the problem here is that my local WiFi is only about 100Mbit/s fast,
moving 200GB at that speed would take over 4 hours, if my math is
correct, and would congest the WiFi for all that time. But your standard
ethernet can do a stable 1Gbit/s, which would drop the time down to 26
minutes!

So I take an ethernet cable and directly connect both laptops with that.
On both machines `ip a` now shows something like this:

{{< img alt="new output of ip a" src="/pix/networking-ethernet-unconfigured.png" link="/pix/networking-ethernet-unconfigured.png" >}}

There is no DHCP-Server running on either machine, so we\'ll have to do
the configuring ourselves! From here on we\'ll have Computer A with
interface `eth0` and Computer B with interface `eth1`, for clarity.

First we must choose what subnet our ethernet interface should use. We
can freely choose from the list of reserved subnets here, as long as the
subnet isn\'t occupied by another interface on either machine. We\'ll
say `192.168.50.0/24`.

Note also that the first and last address on each subnet, here
`192.168.50.0` and `192.168.50.255`, respectively, can\'t actually be
assigned to any device. The first is called \"Network ID\", as mentioned
previously, and the last is called \"broadcast IP\".

So we\'ll give Computer A the IP `192.168.50.1` and Computer B the IP
`192.168.50.2`. To do that we use the `ip` command aswell.

Computer A:

```sh
ip addr add 192.168.50.1/24 dev eth0
```

Computer B:

```sh
ip addr add 192.168.50.2/24 dev eth1
```

It should look something like this now:

{{< img alt="new ip addresses" src="/pix/networking-ethernet-ip.png" link="/pix/networking-ethernet-ip.png" >}}

Now we change the interface\'s state to `UP`:

Computer A:

```sh
ip link set eth0 up
```

Computer B:

```sh
ip link set eth1 up
```

It should look something like this now:

{{< img alt="ethernet output" src="/pix/networking-ethernet-ip-up.png" link="/pix/networking-ethernet-ip-up.png" >}}

Are we done? You can try pinging one IP from another. It won\'t work,
because we don\'t have routes set up yet. So lets\'s do that:

Computer A:

```sh
ip route add 192.168.50.0/24 dev eth0
```

Computer B:

```sh
ip route add 192.168.50.0/24 dev eth1
```

You should see something like this in `ip r`:

{{< img alt="ip routes final" src="/pix/networking-ethernet-route.png" link="/pix/networking-ethernet-route.png" >}}

They are now able to talk to each other!

## Contribution
-   [phire](https://phire.cc)
