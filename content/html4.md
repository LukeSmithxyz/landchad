---
title: "Doing HTML Right"
draft: true
---
We\'ve noted that HTML is very forgiving

## A look at a decent template

I have a template file that I use for this website that includes all the
basics. When I make a new page, I just copy the template and add the
content. Here is what the template looks like:

``

    <!DOCTYPE html>
    <html lang=en>
        <head>
            <title>Your page title</title>
            <meta charset="utf-8"/>
            <link rel="shortcut icon" href="favicon.ico" type="image/x-icon" />
            <link rel='stylesheet' type='text/css' href='style.css'>
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <link rel='alternate' type='application/rss+xml' title='Site Title RSS' href='/rss.xml'>
        </head>
    <body>
        <header><h1>Your page title</h1></header>

        <nav></nav>

        <main>

        Put all your page content here in the <main> tag.
