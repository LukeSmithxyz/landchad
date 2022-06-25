---
title: "Server-Side Scripting with CGI"
date: 2021-07-25
tags: ['server']
---
The basic website tutorial here describes how to set up a static website
--- one that just serves HTML files saved on your server, and until you
change something manually, the same content will be served each time a
given page is requested. This is perfectly enough for most personal
website needs. This is how blogs should be implemented, instead of
relying on bloatware like WordPress!

But sometimes you genuinely *do* need something more. You need your
website to serve different contents depending on the time, on who the
requester is, on the contents of a database, or maybe process user input
from a form.

## CGI

CGI, or the Common Gateway Interface, is a specification to allow you,
the server owner, to program your web server using pretty much any
programming language you might know. The specification is almost as old
as the Internet itself and for a long time CGI scripting was the primary
method of creating dynamic websites.

CGI is a very simple specification indeed. You write a script in your
favorite language, the script receives input about the request in
environment variables, and whatever you print to the standard output
will be the response. Most likely, though, you will want to use a
library for your language of choice that makes a lot of this
request/response handling simpler (e.g. parsing query parameters for
you, setting appropriate headers, etc.).

### Limitations of CGI

While in theory you could implement any sort of functionality with CGI
scripts, it\'s going to get difficult managing a lot of separate scripts
if they\'re supposed to be working in tandem to implement a dynamic
website. If you want to build a full out web application, you\'d
probably be better off learning a web framework than gluing together
Perl scripts.

That said, just as most of the web could be replaced with static
websites, much of the remaining non-static web could be replaced with a
few simple scripts, rather than bloated Ruby on Rails or Django
applications.

## Let\'s write a CGI script!

We\'ll implement a simple example CGI script. I\'ll use Ruby for this
tutorial, but you\'ll be able to follow along even if you don\'t know
Ruby, just treat it as pseudocode then find a CGI library for your
language.

### The working example

Our working example will be the Lazy Calculator. Yeah, you\'re probably
tired of seeing calculator examples in every programming tutorial, but
have you ever implemented one that takes the weekends off?

Here\'s how it will work. When in a browser you submit a request to your
website like

```txt
example.com/calculator.html?a=10&b=32
```

you will receive a page with the result of the addition of 10 and 32:
42.

*Unless* you send your request on a weekend. Then the website will
respond with

```txt
I don't get paid to work on weekends! Come back Monday.
```

This example will show a few things that CGI scripts can do that you
wouldn\'t have been able to get using just file hosting in your web
server:

-   getting inputs from the user;
-   getting external information (here just the system time, but you
    could imagine instead connecting to a database);
-   using the above to create dynamic output.

### The code

Here\'s an implementation of the lazy calculator as a Ruby CGI script:

```ruby
#!/bin/env ruby

require 'cgi'
require 'date'

cgi = CGI.new
today = Date::today

a = cgi["a"].to_i
b = cgi["b"].to_i

if today.saturday? || today.sunday?
  cgi.out do
    "I don't get paid to work on weekends! Come back Monday."
  end
else
  cgi.out do
    (a + b).to_s
  end
end
```

Let\'s go through what\'s happening here.

### The shebang line

CGI works by pointing your web server to an executable program. A Ruby
or Python script by itself is not immediately executable by a computer.
But on Unix-like systems you can specify the program that will be able
to execute your file in its first line if it starts with `#!` (known as
the shebang; read more about it on
[Wikipedia](https://en.wikipedia.org/wiki/Shebang_(Unix))).

So if you\'re going to be using a scripting language, you\'ll probably
need the appropriate shebang line at the top of your script. If you use
a compiled language, you\'ll just point your web server to the compiled
executable binary.

### Query parameters

The next interesting lines of code are where we set the variables `a`
and `b`. Here we are getting user inputs from the request.

In the example request we mentioned above
(`example.com/calculator.html?a=10&b=32`), the part starting from the
question mark, `?a=10&b=32`, is the *query string*. This is how users
can submit parameters with their web requests. Usually these parameters
are set by e.g. a form on your website, but in our simple example we\'ll
be just manually manipulating the URL.

The query string contains key-value pairs. The Ruby CGI library makes
them available in the `CGI` object it provides. We just need to index it
with the desired key, and we\'ll get the corresponding value.

### Wrapping it up

The remaining parts of the code should be pretty self-explanatory. We
get today\'s date, check if it\'s a Saturday or a Sunday, and depending
on that, we instruct the CGI library to output either the answer, or a
\"come back later\" message.

The Ruby library by default returns an HTML response, so we really
should have wrapped our outputs in some `html`, `body`, etc. tags.
Alternatively, we could have specified that the response is just plain
text with

```txt
cgi.out 'text/plain' do
```

In general, your CGI library will probably have ways of specifying all
sorts of HTTP response headers, like status code, content type, etc.

## Making it work

We have a CGI script, now let\'s point our web server to it.

### Installing FastCGI

If you\'re using Nginx, install `fcgiwrap`:

```sh
apt install fcgiwrap
```

This installs the necessary packages for Nginx to use FastCGI --- a
layer between your web server and CGI script that allows for faster
handling of scripts than if the web server had to handle it all by
itself.

Other web servers will probably have a similarly simple way of enabling
FastCGI, or you can look into other methods for launching CGI scripts.

### Nginx configuration

In the configuration file for your website, add something like the
following:

```nginx
location /calculator.html {
  include fastcgi_params;
  fastcgi_param SCRIPT_FILENAME /usr/local/bin/lazy-calculator.rb;
  fastcgi_param QUERY_STRING $query_string;
  fastcgi_pass unix:/run/fcgiwrap.socket;
}
```

`fastcgi_param` directives specify various parameters for FastCGI.
`SCRIPT_FILENAME` should point to your executable. For `QUERY_STRING`,
we just copy Nginx\'s `$query_string` variable. You might want to pass
other information to your CGI script as well, see for example [the
Debian wiki](https://wiki.debian.org/nginx/FastCGI) for a more detailed
example, including pointing to an entire directory of CGI scripts,
rather than adding each one by hand to your web server config.

## Contribution

-   Martin Chrzanowski \-- [website](https://m-chrzan.xyz),
    [donate](https://m-chrzan.xyz/donate.html)
