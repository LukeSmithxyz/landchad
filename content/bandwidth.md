---
title: "Loading Fast and Saving Bandwidth"
draft: true
---
## Images

Image files will usually have the most impact on the speed of your
websites (aside from Ad/tracker scripts). Learn to slim down your images
using the ubiquitous *ImageMagick* to make your websites faster on slow
internet connections.

![Image network speed](pix/imgcompress-network.png)

There are some rules of thumb to keep in mind with images:

1.  Only use images as large as you need on the webpage.
2.  Use the proper containers. E.g. a photograph should never be a
    `.png`, but a `.jpg`, or even better, a `.webp`.
3.  Where it will not be visible, reduce image quality.

### webp vs. png vs. svg

`png` images are best for accurately recording images **without color
gradients**. A `png` photograph will be massive in size, but a `png`
cartoon without color

#### An imagemagick experiment

We can illustrate this difference with imagemagick. Run the following
two commands. They will create two png files containing nothing by the
color red. The first will create a 100x100 pixel image, and the second
will create a massive 10,000x10,000 image. (The second command will take
a few seconds to finish.)

    magick -size 100x100 canvas:red red-small.png
    magick -size 10000x10000 canvas:red red-large.png

Once we\'ve done that, let\'s rerun the same commands, except for let\'s
output them into `jpg` containers:

    magick -size 100x100 canvas:red red-small.jpg
    magick -size 10000x10000 canvas:red red-large.jpg

Once we\'ve run all those commands, you will see that `red-large.jpg` is
a massive 1.2M, while `red-large.png`, despite still being 10,000 square
pixels like the jpg, is a mere 13K in filesize.

------------------------------------------------------------------------

For the examples, I decided to use
[this](https://commons.wikimedia.org/wiki/File:Tabby_cat_with_blue_eyes-3336579.jpg)
public domain image.

![Compressed image of a
cat](https://upload.wikimedia.org/wikipedia/commons/thumb/c/c7/Tabby_cat_with_blue_eyes-3336579.jpg/499px-Tabby_cat_with_blue_eyes-3336579.jpg){style="width: 50%;"}

There are many ways to decrease image size using ImageMagick, the
simplest is to use the `-quality` option, which will compress the image
without changing the resolution. This option takes the value you want to
compress by (between 1 and 100, the lower the value, the lower the file
size). For example:

    convert in.jpg -quality 50 out.jpg

Compressing the example image above results in the following file size
changes:

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

Due to the images high resolution, it is usable in this website even
when highly compressed (30% quality, still looks decent in my opinion).

## Contribution

-   [Musse](https://na20a.neocities.org/)
-   Monero:
    `83is3y69Xv4fkFsTpZhw5c3bfxtimupfgTdpERHM1WtMNAwSqFjTCJm3VabyBKXKnL873dWPmqj4bRcgkm9oCktgQrzmhHd`{.crypto}
