---
title: "Self hosting"
date: 2020-08-19
tags: ['server']
---
## Introduction

When you have a(n old) computer lying around, and you have cheap
electricity and a good internet connection, self hosting might be a good
option for you.

### Why would you choose selfhosting?

-   You have control over the hardware, and you can upgrade your server
    in the future. For example: if you host a file server and your hard
    drive goes full, you can simply add another hard drive or upgrade
    it.
-   No bandwith limits, storage limits, etc. (some VPSes have this)
-   It **can** be cheaper than using a VPS. This only is the case if you
    got the server for really cheap and your electricity is cheap.
-   You can have a media server to consoom your content (for example
    with `Jellyfin`). You can technically do this on a VPS, but that
    will be more expensive than self hosting. If you have a media
    server, you can stream media from your server to more devices. (I
    recommend just downloading it on your device, but if you have
    multiple devices, this could be a good solution)

### Downsides

Some possible downsides of choosing to host at home could be:

-   Your ISP not approving of what you\'re doing. Some ISP\'s do not
    condone you hosting at home. Usually when this is the case, it could
    be harder if you want to forward ports, or it could be impossible to
    get a static IP address. Check your ISP\'s terms of service.
    Sometimes, it will say that hosting a webserver, email server, and
    more, is not allowed.
-   This can also include blocked ports. ISPs can block certain ports to
    the world. Sometimes ISPs only block 445/139 (which is for the
    better as Samba, using these ports isn\'t really secure and it\'s
    outdated). But some ISPs (sadly) block crucial ports like 80
    and/or 443. You need to check this before trying anything. If this
    is the case, a way to get around it is to get another ISP or use an
    alternative port. A great website to check this is:
    [canyouseeme.org](https://canyouseeme.org/). You can also check if
    you did the port forwaring correctly here.
-   Security. Opening your network to the public could bring security
    risks. For example, never open a Samba server to the public, because
    it\'s a pretty old protocol, and it has some security
    vulnerabilities. Be sure you are forwarding the right port, and
    don\'t just forward random ports to the internet. Also, if you are
    getting DDoSed, your ISP will temporarily shut down your whole
    internet connection.
-   When setting up an email server, it can be way harder to not have
    your email show up as spam in other\'s people email. If you use a
    VPS, this is way easier.
-   Space, power consumption and noise. Of course, this differs per
    server.

Your mileage may vary, go and check each of these points, and see if
selfhosting is the right choice for you. Try and calculate your power
consumption and see if your electricity cost is not too expensive.

For me, the upsides outweighed the downsides, which is why I chose to
host at home. But, this differs with each person and scenario. Go and
research what your exact situation is, before trying anything. Otherwise
you\'ll have to face some bad surprises.

## Hardware

### What kind of hardware should you choose?

If you pay your own electricity bill, power consumption is a big factor.
Most old laptop computers are ideal in the sense that they don\'t use a
lot of power, and if the battery still works, you have a built-in UPS!
The bad thing is, most old laptop computers aren\'t that powerful, and
they lack in upgradability. (you shouldn\'t really be using anything
older than 2006, and I recommend at least a performance equivalant of a
Core 2 CPU)

If you can find an energy efficient desktop (under 100W), that is a
great option. They are pretty upgradable and they don\'t use a lot of
power. They can also be pretty cheap, but old laptops are usually
cheaper. If you can afford new hardware, and are willing to build a PC,
you can find really power effecient CPU/motherboard combos, and they can
be cheap, for example the Celeron J3060. I recommend a low wattage power
supply or an effecient one for these kinds of builds. Pico PSUs are
pretty tiny and efficient solutions in these builds.

Of course, if you don\'t pay your electricity bill or cost is not a
problem for you, you can use just about any old desktop (as long as
it\'s not from the 90\'s, I recommend at least a Core 2 chip again, or
an Athlon 64 X2).

### Usecases

Of course, hardware choices depend on the usecase. The above
recommendations I gave you work fine for e-mail server, webserver and
fileserver types of applications, but they will struggle to transcode
video if you are going to host a media server. You\'ll need a faster
CPU, but also a faster GPU. As an example, the Athlon 200GE or 3000G are
good and efficient choices for these builds. They are decent CPUs, but
also have a built in GPU that will transcode video just fine.

If you need a lot of storage, go for a case with a lot of mounts for
hard drives, this way you can easily mount multiple hard drives. Pros of
multiple hard drives are redundancy and speed. Cons could be that they
create more heat and noise. You can\'t use a laptop if you want multiple
drives, except if you use a hard drive caddy for the CD/DVD drive bay.
Some business laptops even support RAID 1 (redundancy) and RAID 0 (speed
and more storage, but you lose your files if one hard drive breaks) this
way.

## Getting started

### Installing Debian

Once you have the machine, you can install the OS. I recommend Debian,
as all of the guides on this website are Debian specific. Debian just
werks as a server OS.

You\'ll need to burn a Debian install image onto a USB flash drive or a
CD. You can download the image
[here](https://www.debian.org/CD/netinst/), and you can also find
information on how to burn the image onto a USB flash drive or CD there.

While installing Debian, do not install any desktop environment. But
install an SSH server when you get the chance. Also leave webserver
unchecked, even if you want to use it as a webserver. You\'ll have a
chance to install this later.

### Port forwaring

Every time you are going to set up a new server program, you need to
forward a port corresponding to that program. For example, HTTP is port
80, HTTPS is 443, etc. You need to set this up on your router\'s NAT
settings (sometimes just called port forwarding, this differs per
router). These steps differ for each router. Refer to your routers
manual. A simple command to see what your servers IP address is, is to
run `ifconfig` on your server. This shows a lot of network info, but it
will also show your local IP address needed for port forwarding.

Basic ports:

-   SSH: port 22 (open this port if you want to admin your server
    outside your network)
-   HTTP: port 80 (open this port if you want basic webserver
    functionality)
-   HTTPS: port 443 (you should open this port if you are setting up a
    webserver because encryption)

### Static or dynamic IP address

If you want to host your server at home, make sure you have a static IP
address, or you can change your dynamic IP address to a static one.
Refer to your router settings, some ISPs will have options on this here.
If you can\'t find anything on this, get in touch with your ISP.

Once you\'ve made sure you have a static IP address, you can find out
what the IP address is with various websites. You can use a search
engine to easily find this out. Write this down as you\'ll need it
later.

Once you\'re done, you can pretty much follow every guide on this
website, the only difference is that you\'ll need to forward the ports
you\'ll be using for the server.

### Finding the ports you\'ll need to forward

If you need to know what port you\'ll need to forward, there\'s a
command for that. Just type `netstat -tulpn` in your servers command
line. If you want to see the name of the programs, you need to run it as
a root user. You can do this by putting `sudo` before the command.

```txt
Local Address                    State       PID/Program name
0.0.0.0:25                       LISTEN      887/master
0.0.0.0:1883                     LISTEN      22452/mosquitto
0.0.0.0:445                      LISTEN      798/smbd
0.0.0.0:993                      LISTEN      381/dovecot
127.0.0.1:3306                   LISTEN      560/mysqld
0.0.0.0:587                      LISTEN      887/master
0.0.0.0:139                      LISTEN      798/smbd
127.0.1.1:12301                  LISTEN      412/opendkim
0.0.0.0:143                      LISTEN      381/dovecot
0.0.0.0:465                      LISTEN      887/master
0.0.0.0:22                       LISTEN      472/sshd
:::25                            LISTEN      887/master
:::443                           LISTEN      1769/apache2
:::1883                          LISTEN      22452/mosquitto
:::445                           LISTEN      798/smbd
```

*Example output*

In this example, if you need to find the port number from `dovecot`, you
can look for it in the `Program name` column. Then you can see in the
local address column that the reported local address is `0.0.0.0:993`.
You need to look for the part after the semicolon. In this case it\'s
993. So you\'ll need to forward port 993.

*Written by [hiddej](https://github.com/hidde-j)*
