---
title: "Image compression"
date: 2021-07-17
---
Image files will usually have the most impact on the speed of your
websites (aside from Ad/tracker scripts). Learn to slim down your images
using the ubiquitous *ImageMagick* to make your websites faster on slow
internet connections.

{{< img alt="Image network speed" src="/pix/imgcompress-network.png" link="/pix/imgcompress-network.png" >}}

For the examples, I decided to use
[this](https://commons.wikimedia.org/wiki/File:Tabby_cat_with_blue_eyes-3336579.jpg)
public domain image.

{{< img alt="Compressed image of a cat" src="/pix/imgcompress-cat.png" link="/pix/imgcompress-cat.png" >}}

There are many ways to decrease image size using ImageMagick, the
simplest is to use the `-quality` option, which will compress the image
without changing the resolution. This option takes the value you want to
compress by (between 1 and 100, the lower the value, the lower the file
size). For example:

    convert in.jpg -quality 50 out.jpg

Compressing the example image above results in the following file size
changes:

```
  Quality    Size
  ---------- ------
  Original   2.1M
  90         1.7M
  80         844K
  70         588K
  60         448K
  50         368K
  40         308K
  30         248K
  20         184K
  10         116K
```

Due to the images high resolution, it is usable in this website even
when highly compressed (30% quality, still looks decent in my opinion).

## Contribution

-   [Musse](https://na20a.neocities.org/)
-   Monero:
    `83is3y69Xv4fkFsTpZhw5c3bfxtimupfgTdpERHM1WtMNAwSqFjTCJm3VabyBKXKnL873dWPmqj4bRcgkm9oCktgQrzmhHd`{.crypto}
