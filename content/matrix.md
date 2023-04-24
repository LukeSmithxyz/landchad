---
title: "Matrix Synapse"
date: 2021-07-16
icon: 'element.svg'
tags: ['service']
short_desc: "An encrypted chat server sleek and accessible even to normies."
---

Matrix is easy-to-use, decentralized and encrypted private chat software. Matrix is federated, meaning that with a Matrix account on any server, including your own, you can talk to any other Matrix account on
the internet, similar to email. Matrix also allows fully end-to-end encrypted group chats.

**Synapse** is the name of the default Matrix server. It is written in Python. While it is requires somewhat more system resources than [an XMPP server](/prosody), it makes up for that in being very accessible to non-technical users.

## Installation

The latest version of Synapse is not in the Debian package repositories by default, but we can easily add Matrix's repository including it:

```sh
apt install -y lsb-release wget apt-transport-https
wget -O /usr/share/keyrings/matrix-org-archive-keyring.gpg https://packages.matrix.org/debian/matrix-org-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/matrix-org-archive-keyring.gpg] https://packages.matrix.org/debian/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/matrix-org.list
```

After we update our packages lists, we will be able to install Synapse with `apt`.

```sh
apt update
apt install matrix-synapse-py3
```

When prompted, give your main domain name (not a subdomain). This will be the domain appended to your Matrix address, e.g. `@chad:{{<hl>}}landchad.net{{</hl>}}`. (*If you want to run Synapse under a different subdomain than the actual server name,* then you must set up [delegation.](https://matrix-org.github.io/synapse/latest/delegate.html))

## Nginx configuration

Create an Nginx configuration file for Matrix, say `/etc/nginx/sites-available/matrix` and add the content below:

```nginx
server {
        server_name {{<hl>}}matrix.example.org{{</hl>}};

        listen 80;
        listen [::]:80;

        listen 443 ssl http2 default_server;
        listen [::]:443 ssl http2 default_server;
       
        listen 8448 ssl http2 default_server;
        listen [::]:8448 ssl http2 default_server; 
    
        location ~* ^(\/_matrix|\/_synapse|\/_client) {
                proxy_pass http://localhost:8008;
                proxy_set_header X-Forwarded-For $remote_addr;
                client_max_body_size {{<hl>}}50M{{</hl>}};
        }

        # These sections are required for client and federation discovery
        # (AKA: Client Well-Known URI)
        location /.well-known/matrix/client {
                return 200 '{"m.homeserver": {"base_url": "https://{{<hl>}}matrix.example.org{{</hl>}}"}}';
                default_type application/json;
                add_header Access-Control-Allow-Origin *;
        }

        location /.well-known/matrix/server {
                return 200 '{"m.server": "{{<hl>}}matrix.example.org{{</hl>}}:443"}';
                default_type application/json;
                add_header Access-Control-Allow-Origin *;
        }
}
```

Note the `client_max_body_size` variable. By default, Nginx caps the size of files it can transfer. We increase that to 50M if needed by Matrix. (Note however that both Matrix and Nginx have seperate settings for this and to raise it to something much larger, you will have to increase the value in both configuration files.)

Now let's enable the Nginx Matrix site and run **certbot** to get an encryption certificate and restart Nginx.

```sh
ln -s /etc/nginx/sites-available/matrix /etc/nginx/sites-enabled
certbot --nginx -d {{<hl>}}matrix.example.org{{</hl>}}
```

## Configuration

### Read the config file

The configuration file for Matrix is in `/etc/matrix-synapse/homeserver.yaml`. It is well documented and
commented, so you can read about the settings, but let's change the essential ones here.

Make what changes you want and run `systemctl reload matrix-synapse` to make the system configuration active.

### Database Setup
Synapse, like [PeerTube](/peertube) and [Prosody](/prosody), supports **PostgreSQL** as a database backend. This can **significantly increase performance,** epsecially if you're already running PostgreSQL to run any other services.

Begin by installing PostgreSQL:

```sh
apt install postgresql
```

Then start the daemon:

```sh
systemctl restart postgresql
```

Now create a user named `synapse_user` to manage your database:
```sh
su -c "createuser --pwprompt synapse_user" postgres
```

And finally, create the actual database:
```sh
su -c "psql -c 'CREATE DATABASE synapse ENCODING 'UTF8' LC_COLLATE='C' LC_CTYPE='C' template=template0 OWNER synapse_user;'" postgres
```

Now edit the database configuration in `/etc/matrix-synapse/homeserver.yaml` and comment out the following lines for the previous SQLite configuration: 

```yml
# database:
  # name: sqlite3
  # args:
    # database: DATADIR/homeserver.db
```

*Note: The example above is how yours should look like after it's commented out.*

Then, uncomment the following configuration above, and set the appropriate entries:
```yaml
database:
  name: psycopg2
  args:
    user: {{<hl>}}synapse_user{{</hl>}}
    password: {{<hl>}}secretpassword{{</hl>}}
    database: {{<hl>}}synapse{{</hl>}}
    host: localhost
    cp_min: 5
    cp_max: 10
```

Ensure that `synapse` is set to your database name, `synapse_user` is set to that database's owner, and that `secretpassword` is set to that user's password. 

### Adding Users and Admins

If you allow open registration on your server in the configuration file, you can create an account through Element or another Matrix client, but you are probably going to want an official admin account to use. To make one, simply run the following command, which will then give you several choices for creating a user, among which will be the ability to make it an admin.

Before setting up the admin user, make sure to set a `registration_shared_secret` in `/etc/matrix-synapse/homserver.yaml`:

```yaml
registration_shared_secret: {{<hl>}}???{{</hl>}}
```

Then, run the following command to register a user:

```sh
cd /etc/matrix-synapse

register_new_matrix_user -c homeserver.yaml http://localhost:8008
```

This command will prompt you for a username, password and whether to make the user an admin or not.

### URL Previews

To enable server-generated previews of webpages, change this line to true in `/etc/matrix-synapse/homeserver.yaml`:

```yaml
url_preview_enabled: true
```

And make sure to uncomment the `url_preview_ip_range_blacklist:` section; Otherwise, Synapse will refuse to start up again! 

### Federation

Using the Nginx configuration provided with this guide, federation should work out of the box with Synapse. You can test whether it's working using the [Matrix Federation Tester.](https://federationtester.matrix.org/)

However, some extra features can be enabled to increase the usability of your homeserver over federation. In `/etc/matrix-synapse/homeserver.yaml`, the following lines can be edited:

```yaml
allow_public_rooms_over_federation: true
```

This can be un-commented to allow users to add your homserver to their list of servers (in a client like Element) and see a list of all the public rooms.

```yaml
allow_public_rooms_without_auth: true
```

This can be un-commented to enable guests to see public rooms without authenticating. 

## Using Matrix with ![Element Matrix logo](/pix/element.svg)Element

There are many different [clients](https://matrix.org/clients/) that can be used on desktops or phones to chat on your Matrix server, but the most popular and most widely vetted is ![Element logo](/pix/element.svg)Element.

Get Element to access your Matrix server:

-   Mobile:
    -   [F-droid](https://f-droid.org/packages/im.vector.app/)
    -   [Google Play](https://play.google.com/store/apps/details?id=im.vector.app)
    -   [Apple App Store](https://apps.apple.com/app/vector/id1083446067)
-   Real computer:
    -   GNU/Linux: You know how to install it.
    -   [Windows](https://packages.riot.im/desktop/install/win32/x64/Element%20Setup.exe)
    -   [Mac](https://packages.riot.im/desktop/install/macos/Element.dmg)

Note also that Element has a web client (i.e. a version that can be accessed on your own website) that is also easy to install on an Nginx server, although that will be covered in another article.
