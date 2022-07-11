---
title: "Gemini"
date: 2021-07-01
tags: ['server']
short_desc: "A minimalist alternative to HTTP with a modern twist."
---
## What is Gemini? {#whatis}

[Gemini](https://gemini.circumlunar.space) is a new
internet protocol which is different from the HTTP and Gopher. It\'s
much cleaner and has a growing community and audience of hackers.

### Why use gemini protocol?

-   Gemini capsules (webpages of gemini) are lightweight, minimal, and
    don\'t use many resources to operate.
-   It can run along with your websites. Gemini capsules use port 1965
    by default. Your webserver can run at port 80 or 443 along with
    gemini server at port 1965.
-   By exploring an alternative protocol, you can check different ways
    to serve data and blogs.

To access any gemini urls i.e. `gemini://example.org`, you can use any
gemini client such as
[amfora](https://github.com/makeworld-the-better-one/amfora),
[lagrange](https://gmi.skyjake.fi/lagrange),
[elpher](https://thelambdalab.xyz/elpher/), etc.

## Instructions

### Create a gemini user

It is most secure and clean to have a separate `gemini` user, so let\'s
create one:

```sh
useradd -m -s /bin/bash gemini
```

Now log in as `gemini` with the following command:

```sh
su -l gemini
```

To create and serve a gemini capsule, we need three basic steps:

1.  Content -- the webpages in our capsule
2.  TLS certificate -- Gemini requires encrypted connection.
3.  Gemini server -- the program that makes our capsule available
    (similar to Nginx for HTTP)

As the gemini user, we can create three different directories to
simplify the process:

```sh
mkdir -p ~/gemini/{content,certificate,server}
```

### Content

This will be the directory where your capsule files will be contained.
Gemini uses text/gemini markup (in place of HTTP\'s equivalent HTML). It
heavily borrows from Markdown. Similar to .html or .md, gemini uses .gmi
as its extension.

To create one gemini file, go inside the `content` directory and create
one `index.gmi` file.

```sh
nano gemini/content/index.gmi
```

We can add the content we want in our Gemini capsule here:

```yaml
# This is Sample Gemini page
## With header 1 and header 2
And a short paragraph like this.
=> /index.gmi Link to the same page
```

### TLS certificate

Go to the `certificate` directory which we created earlier and generate
a TLS certificate using OpenSSL.

```sh
cd ~/gemini/certificate/
openssl req -new -subj "/CN=example.org" -x509 -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -days 3650 -nodes -out cert.pem -keyout key.pem
```

### Gemini server

#### Download and prepare the server

There are [many gemini server software choices
available](https://gemini.circumlunar.space/software). We will use
`agate` server for now. This is a simple gemini server written in Rust.

It\'s a good idea to always get the most recent version, which you can
see [on the agate releases
page](https://github.com/mbrubeck/agate/releases). At the time of this
writing, that is agate v3.1.0 which we will now download. We will
download it to the `server` directory we made.

```sh
cd ~/gemini/server
wget https://github.com/mbrubeck/agate/releases/download/v3.1.0/agate.x86_64-unknown-linux-gnu.gz
```

Unzip the gz, then rename and make it executable:

```sh
gunzip agate.x86_64-unknown-linux-gnu.gz
mv agate.x86_64-unknown-linux-gnu agate-server
chmod +x agate-server
```

#### Create a system service

Now we need to create a systemd service to autostart and manage agate.
The gemini user does not have permission to do this, so press <kbd>ctrl-d</kbd>
to log out of the gemini user and return to root. As root, create the
file below by opening it in your text editor (nano, vim, etc.):

```sh
nano /etc/systemd/system/agate.service
```

Add the following content to the file **customizing highlighted text**
to your use.

```systemd
[Unit]
Description=agate
After=network.target

[Service]
User=gemini
Type=simple
ExecStart=/home/gemini/gemini/server/agate-server --content /home/gemini/gemini/content --certs /home/gemini/gemini/certificate/ --hostname example.org --lang en-US

[Install]
WantedBy=default.target
```

Now we are ready to run server. Enable and run agate server.

```sh
systemctl enable agate
systemctl start agate
```

#### Firewall

Lastly, if you have a firewall running, remember to open port 1965,
which is the port number used by gemini:

```sh
ufw allow 1965
```

## Finalization

Now your server should be running. If everything went okay, you can
access your gemini capsule via any gemini client with a url like this:

```txt
gemini://example.org
```

Sample gemini site for reference:

```txt
gemini://gemini.circumlunar.space
```

Enjoy your first gemini capsule.

For information about how to write in \"gemtext\" the markup language in
Gemini, see this site:
<https://gemini.circumlunar.space/docs/gemtext.gmi>. As you might guess,
it also has an analogous gemini capsule here:
gemini://gemini.circumlunar.space/docs/gemtext.gmi

------------------------------------------------------------------------

*Written by [nihar.page](https://nihar.page)*
