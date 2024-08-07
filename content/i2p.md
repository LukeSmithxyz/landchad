---
title: "i2p"
date: 2021-07-01
img: 'i2p.svg'
icon: 'itoopie.svg'
tags: ['service']
short_desc: "A private and uncensorable web-layer similar to Tor."
---

Now you have a website, why not offer it in a private alternative such as the Invisible Internet?

## Setting up I2P

There are 2 main I2P implementations, I2P and i2pd, we are using i2pd in this guide because it's easier to use on servers.

### Installing I2P

We need to [add the i2pd repos to our system](https://repo.i2pd.xyz/) to get the latest version of i2pd:

Install apt-transport-https and gpg package:

```sh
apt install apt-transport-https gpg
```

Automatically add the repository with a script:

```sh
wget -q -O - https://repo.i2pd.xyz/.help/add_repo | bash -s -
```

After that you can install i2pd as any other software package:

```sh
apt update
apt install i2pd
```

### Enabling I2P

Next we have to configure the i2pd daemon, the configuration is located at `/etc/i2pd/`.

Edit the `tunnels.conf` file and add the following configuration to the file:

```systemd
[example]
type = http
host = 127.0.0.1
port = 8080
keys = example.dat
```

You can comment or remove the tunnels that are added by default in the configuration file.

#### Optional: Generating a Vanity Address

If you run `i2pd` with the configuration above, it will generate a random private key (`example.dat`) for your website at `/var/lib/i2pd/` with a matching address made up of 52 random characters, derived from this same key.

If you instead pre-generate a private key for your website, you can use brute-force computation to make a "vanity" address, such as the following:
```
{{<hl>}}chad{{</hl>}}aor3jc08ht340c30mg5cf340j395gj095kuazj5tokipr34f.32.i2p
```

To accomplish this, a set of tools named `i2pd-tools` can be installed.

Begin by cloning their repository:
```sh
git clone --recursive https://github.com/purplei2p/i2pd-tools
```

The repository comes with a dependency installation script included. Run this to list the compilation dependencies you'll need, and install them:
```sh
cd i2pd-tools
sh dependencies.sh
```

Then compile using the `make` command:
```sh
make
```

This will build a variety of useful tools for i2p, with `vain` being the command of interest to generate an address:
```sh
./vain {{<hl>}}chad{{</hl>}}
```
This command will begin running and output a new set of private keys named `private.dat` to the same directory it's ran from. Copy this file to your i2p configuration and you'll have your vanity address:

```sh
cp private.dat /var/lib/i2pd/example.dat
```

#### Optional: Authentication Strings for Registrars

I2P has various **registrars** that let users link their long I2P addresses to shorter, more memorable ones, like `example.i2p`. To actually register your site on one of these registrars, you will need an **authentication string.** Luckily, `i2pd-tools` includes such a tool in their repository:

```sh
./regaddr private.dat {{<hl>}}example.2ip{{</hl>}} > {{<hl>}}auth_string.txt{{</hl>}}
```

The command above will save the string to a file named `auth_string.txt`. You will have to place the text contained in that file on a registration page like [http://reg.i2p/add](http://reg.i2p/add) or [http://stats.i2p/i2p/addkey.html](http://stats.i2p/i2p/addkey.html).

### Getting your I2P Hostname

Then, run the command `systemctl start i2pd` to start i2pd and `systemctl enable i2pd` to enable i2pd at startup, this will automatically generate our I2P hostname which we will now see.

This can be done in lynx or a command-line browser by going to `http://127.0.0.1:7070/?page=i2p_tunnels` to get your I2P hostname.

You can also run these commands to find your hostname:

```sh
printf "%s.b32.i2p
" $(head -c 391 /var/lib/i2pd/example.dat | sha256sum | xxd -r -p | base32 | sed s/=//g | tr A-Z a-z)
```

*(If you've generated your own keys to obtain a vanity address, now's a good time to make sure i2pd is properly reading those keys by verifying the address is the same as the one generated with the `vain` command.)*

## Adding the Nginx Config

From here, the steps are almost identical to setting up a normal website configuration file. Follow the steps as if you were making a new website on the webserver [tutorial](/basic/nginx) up until the server block of code. Instead, paste this:

```nginx
server {
	listen 127.0.0.1:8080 ;
	root /var/www/{{<hl>}}example{{</hl>}} ;
	index index.html ;
}
```

#### Clarifications

Nginx will listen on port 8080, but i2pd will forward your port 8080 to the i2p site port 80. This way you don't have to deal with server names or anything like that.

From here we are almost done, all we have to do is enable the site and reload nginx which is also covered in [the webserver tutorial](/basic/nginx#enable).

### Update regularly!

Make sure to update I2P on a regular basis by running:

```sh
apt update && apt upgrade
```

**Contributors** 
- [qorg11](https://qorg11.net)
- [David Uhden](https://github.com/daviduhden)
