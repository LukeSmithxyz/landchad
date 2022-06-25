---
title: "BTCPay"
icon: 'btcpay.svg'
tags: ['service']
short_desc: "Host your own payment processor, powered by Bitcoin."
draft: true
---

```sh
apt install nginx python3-certbot-nginx tor postgresql postgresql-contrib iptables iptables-persistent
```

    *filter
    :INPUT ACCEPT [0:0]
    :FORWARD ACCEPT [0:0]
    :OUTPUT ACCEPT [0:0]
    -A INPUT -i lo -j ACCEPT
    -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT     # SSH
    -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT     # BTCPay HTTP
    -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT    # BTCPay HTTPS
    -A INPUT -p tcp -m tcp --dport 8333 -j ACCEPT   # Bitcoind P2P
    -A INPUT -p tcp -m tcp --dport 9735 -j ACCEPT   # Lightning P2P
    -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    COMMIT

`iptables-restore > iptables.txt` netfilter-persistent save

    echo "ControlPort 9051
    CookieAuthentication 1" >> /etc/tor/torrc

certbot \--nginx -d pay.cedars.xyz \--agree-tos
\--register-unsafely-without-email vim /etc/nginx/sites-available/btcpay

## Building Bitcoin

Now we can install the Bitcoin node and daemon software. For safety\'s
sake, we will install it from source.

First, we install the build dependencies:

    apt install build-essential libtool autotools-dev automake pkg-config bsdmainutils python3 libevent-dev libboost-dev libboost-system-dev libboost-filesystem-dev libboost-test-dev git

Now we can download the Bitcoin source code from the official
repository:

    git clone https://github.com/bitcoin/bitcoin
        cd bitcoin

Now, we compile, then install it. Compiling the software will take some
time.

    ./autogen.sh
    ./configure
    make
    make install

[[Next:\<++\>](%3C++%3E)]{.next}
