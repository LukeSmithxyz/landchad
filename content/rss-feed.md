---
title: "Creating an RSS Feed"
tags: ['concepts']
date: 2022-07-02
draft: true
---

RSS feeds are an easy way to be notified about new content from various
websites, and they are easy to implement in your website.

## How an RSS Feed Works

Some websites with frequently changing content like blogs, podcasts, or
video sharing sites, will have a link to a file containing the RSS feed
and its items.

When there is new content, a new item can be added to the RSS feed, and
old items can optionally be removed from the RSS feed. A user\'s feed
reader can check an RSS feed for new items and notify the user about
them or organize them.

## Writing an RSS Feed

RSS feeds are written as XML (e**x**tensible **m**arkup **l**anguage)
files, so they can be written and served similar to HTML webpages.

We will start by creating a file for our RSS feed. Make sure the file
name ends with `.rss` or `.xml`. Then, write the following code in the
file:

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0">
    <channel>
    </channel>
</rss>
```

The `<rss>` tag specifies that there is an RSS feed in between the
`<rss>` and `</rss>` tags. `version="2.0"` specifies that version 2.0 of
RSS is used. The items in an RSS feed go in between the `<channel>` and
`</channel>` tags.

### Title, Description, and Link

Now we will write a title and description for our RSS feed, as well as a
link to the webpage that the RSS feed goes with. In this example, we
will be writing an RSS feed for a blog called **LandChad\'s Blog**.

In between the `<channel>` and `</channel>` tags, the `<title>` tag will
be used to label the feed as **LandChad\'s Blog**. The `<description>`
and `<link>` tags are used for the description of the feed and a link to
the corresponding webpage.

 ```xml
 <channel>
	<title>LandChad's Blog</title>
	<description>LandChad's writings and ideas</description>
	<link>https://example.org/blog</link>
 </channel>
 ```

{{< img src="/pix/rss-01.png" alt="LandChad's blog feed" link="/pix/rss-01.png" >}}

### Feed Items

Now we will add items to the RSS feed. These items are listed in the
user\'s feed reader and can represent different content on a page such
as blog posts or videos. In this example, there is a blog post called
**RSS is Amazing!**.

The `<item>` tag is used to add items to the RSS feed. An item is given
a title using the `<title>` tag to label the item. The item will have a
link to its webpage using the `<link>` tag and an item description using
the `<description>` tag.

The date and time of an item can be specified using the `<pubDate>` tag.
The date and time **must follow a specific format**. In the example
below, the item was posted on **Friday, October 1, 2021 at 2:27 PM in
the -0400 time zone**.

```xml
<item>
	<title>RSS is Amazing!</title>
	<link>https://example.org/blog/2021-10-1-rss</link>
	<description>RSS is a good notification system.</description>
	<pubDate>Fri, 1 Oct 2021 14:27:00 -0400</pubDate>
 </item>
 ```

{{< img src="/pix/rss-02.png" alt="LandChad's Blog feed with an item" link="/pix/rss-02.png" >}}

## Contributor

[ClosedGL](https://closedgl.xyz)
