---
title: "Setup rDNS"
tags: ['mail']
date: 2022-12-02
---

While [DNS records](/basic/dns) refer a domain name to the IP address
where the the website is hosted, there is also rDNS (reverse DNS) and
specifically PTR (pointer) records which do the reverse: link a
server\'s IP to a domain name.

This is important for many things, but especially email. Many email
servers require that other servers that send them mail have PTR records
to prevent spam.

## Setting your PTR Record

DNS settings are set with your registrar, while rDNS settings are set
with your server or VPS provider. **Remember to set records for both
IPv4 and IPv6!**

In [Vultr](https://www.vultr.com/?ref=8384069-6G) we want to set the
IPv4 record, click on the server, then \"Settings,\" and make sure the
\"IPv4\" tab is selected. We can then edit the \"Reverse DNS\" blank
shown below.

{{< img alt="IPv4 rDNS PTR record set in Vultr" src="/pix/rdns-01.png" >}}

The setting for IPv6 is obviosuly under the IPv6 tab. Note here that we
copy the full IPv6 address from above and create a new rDNS entry by
pasting that and the domain name in the blanks below. Then just select
\"Add.\"

{{< img alt="IPv6 rDNS PTR record set in Vultr" src="/pix/rdns-02.png" >}}

That\'s it!
