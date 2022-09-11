---
title: "Page Quality"
date: 2022-03-21
tags: ['server']
---
After you\'ve deployed your website, you may want to consider improving
its performance, accessibility, and search-engine optimization (SEO).
Doing so can help make your website more user-friendly and increase its
page rank in search results. Luckily, Google provides a [measurement
tool](https://web.dev/measure) to help you improve these aspects. Start by
entering your website\'s URL and click the *Run Audit* button (it will
take 5-10 seconds to generate the report).

Once the report has finished, you\'ll be greeted by a score for four
different categories: *Performance*, *Accessibility*, *Best Practices*,
and *SEO*. A lot of the tests listed are self-explanatory, and Google
provides you with articles to help you pass them. Below are some easy
ways to improve your scores, some specific to the nginx configuration
used in the [landchad website tutorial.](/basic/nginx)

## Performance

### Serving static assets with an efficient cache policy

Serving your files with an efficient cache policy will allow the user\'s
browser to cache files such as pictures and CSS so that the browser doesn\'t
need to fetch these files each time the page is visited.

It\'s very easy to set this up in nginx. Just paste the following within the
server block of your website\'s configuration file:

```nginx
# Media: images, icons, video, audio, HTC
location ~* \.(?:jpg|jpeg|gif|png|ico|svg|webp)$ {
    expires 1M;
    access_log off;
    # max-age must be in seconds
    add_header Cache-Control "max-age=2629746, public";
}

# CSS and Javascript
location ~* \.(?:css|js)$ {
    expires 1y;
    access_log off;
    add_header Cache-Control "max-age=31556952, public";
}
```

You can add more types of file extensions (mp3, mp4, ogg) as you see
fit.

If you\'re changing your CSS files a lot, caching could keep repeat
users from getting the most up-to-date stylesheet. To combat this, you
can version your stylesheets like so:

```html
<link rel="stylesheet" type="text/css" href="style.css?v=1.0.0">
```

Just increase the version number whenever you update your stylesheet,
and the browser will re-update its cache.

### Enable text compression

Another easy addition to your websites configuration file. Enabling text
compression is easy and will save bandwidth for users. Simply paste the
following within the server block of your website\'s configuration file:

```nginx
gzip on;
gzip_min_length 1100;
gzip_buffers 4 32k;
gzip_types text/plain application/x-javascript text/xml text/css;
gzip_vary on;
```

After reloading nginx, you can test if compression is working by opening
your browsers developer tools and going to the network tab. Refresh your
website with the network tab, click on the item with your URL and look
at the response headers. You should see `Content-Encoding: gzip` as one
of the headers displayed.

### Properly sizing images

If you\'ve put images on your webpage, you\'ve most definitely gotten
this warning. To pass this audit, you\'ll need to scale your images down
using a tool like gimp or imagemagick to a size appropriate for your
website. It doesn\'t make much sense to serve a high-res image for
images that are rendered much smaller on a webpage.

Once you\'ve scaled your image down, you can use a tool like `cwebp` to
convert your images into the .webp format, a format specifically created
for serving bandwidth concious images.

First, you\'ll have to install the webp package:

```sh
apt install webp
```

Now you can easily convert your images to webp (keep in mind that it\'s
much more effective to first size your images appropriately before
this). Using the below command, you can specify the quality of the photo
with the `q` option. I typically shoot for a quality in the range of
60-80, depending on the image and how large it will be displayed on the
webpage.

```sh
cwebp -q 80 your-photo.png -o your-photo.webp
```

You can now check the difference in size of the images using `ls`.

```sh
ls -lh your-photo*
```

After utilizing webp images, the audit typically goes away, but if you
didn\'t scale your image properly before hand, it may still linger.

## Accessibility

### Image elements do not have \[alt\] attributes

It may seem silly to add `alt` attributes to images, but it helps screen
readers convey images to users and can help page rank as a result. The
`alt` attribute should simply describe the image being displayed.

```html
<img src="img/cabin.webp" alt="A cabin nestled between pine trees">
```

## SEO

### Document does not have a meta description

Adding meta descriptions to your webpage allow for web-crawlers and bots
to easily determine what content your website contains. Just like on
other online platforms, you can give your webpage a long list of
keywords to help increase the chance someone stumbles upon your site
from a search engine. You don\'t need to add all of the below meta tags
to pass the audit, only add what\'s necessary.

```html
<!--- Instructions for web scrapers --->
<meta name="robots" content="index, follow">

<meta name="description" content="your website description">
<meta name="keywords" content="your, keywords, here">
<meta name="author" content="your name">

<!--- Facebook specific standard, but many websites use this so it has become almost standard to include --->
<meta property="og:site_name" content="Site Name">
<meta name="twitter:domain" property="twitter:domain" content="example.org">
<meta name="og:title" property="og:title" content="Site Name">
<meta property="og:description" content="your website description">
<meta name="twitter:description" property="twitter:description" content="your website description">
<meta name="og:image" content="https://link-to-an-image-that-represents-your-site">

<!--- below is for twitter sharing previews
you can test this at cards-dev.twitter.com --->
<meta property="twitter:card" content="https://link-to-an-image-that-represents-your-site">
<meta name="twitter:image:src" property="twitter:image:src" content="https://link-to-an-image-that-represents-your-site">
<meta name="twitter:image" property="twitter:image" content="https://link-to-an-image-that-represents-your-site">
<meta name="og:image:alt" property="og:image:alt" content="alt text for your image">

<meta property="og:url" content="example.org">
<meta property="og:type" content="website">

<!--- If you have accounts on twitter or facebook that are relevant to your site --->
<meta property="fb:admins" content="facebook group" >
<meta name="twitter:site" property="twitter:site" content="@yourTwitterHandle">
<meta name="twitter:creator" property="twitter:creator" content="@yourTwitterHandle">
```


------------------------------------------------------------------------

*Written by [Jacob.](https://mccor.xyz) Donate Monero
[here.](https://mccor.xyz)*
