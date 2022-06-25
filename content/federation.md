---
title: "Federation"
draft: true
tags: ['concepts','activity-pub']
---
The internet was supposed to be a place where everyone was an internet
LandChad. Everyone had their own website and email and own services.
Obviously, this site is all about getting back to that ideal.

That\'s why it\'s important to understand the concept of
<dfn>Federation</dfn> in technology. It\'s the idea that instead of one
central \"node\" or site that everyone uses, like Facebook, Twitter,
Insta, R\*ddit, people can run their own sites that can nonetheless
*interact* with othersites as easily as if they were the same.

You already know one federated technology: email. There is no one site
for email, but many sites, and all people on all those sites can use
email to talk to one another. You can get censored on Facebook. You
can\'t get censored on \"email.\" You could have a Gmail account
deleted, but you are not blocked out of the system, as you can go to any
number of sites and get a new account or [make your own server](/email) and you can still talk to all your friends via
email.

## \"Federated\" Social Media

The idea of Federated Social Media is using that principle used in
email, but for other things, like chatting or social media.

Here\'s an example. There is some software [you can install on your
server](/pleroma) called [Pleroma](https://pleroma.social/). It can
be installed on your site just like a web or email server, but what it
does is creates a Twitter-like microblogging site. You can then have
your friends join and use it just like you use Twitter, with you as the
admin and deciding policy and you can even format and decorate the site
how you want.

### It gets even better\...

**But here is the clincher.** Federated social media like Pleroma can
interact with other Pleroma servers on the internet in the same way that
Gmail\'s servers can send messages to any other email server. So you
might have 2 people on your Pleroma site, but you can interact with the
many thousands of other Pleroma sites.

There is seamless interaction. You can view, like, share and respond to
their posts as if they were part of your own site.

### And it gets even betterer\...

Pleroma is based on a protocol called [Activity
Pub](https://activitypub.rocks/). This is also used by other software
like [PeerTube](https://joinpeertube.org/) (which is a self-hosted
YouTube-equivalent), [Friendica](https://friendi.ca/) (Facebook
equivalent).

Accounts on *all* of these platforms can view, interact with and participate with accounts on other platforms.
You can do the equivalent of posting a comment on a "YouTube" video from your "Twitter" account.
