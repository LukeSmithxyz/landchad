---
title: "MiniDLNA"
icon: 'minidlna.png'
tags: ['service']
date: 2025-10-31
short_desc: 'A very simple media server for DLNA and UPnP clients. Also known as ReadyMedia.'
---

[MiniDLNA](https://sourceforge.net/projects/minidlna/) (also known as ReadyMedia) is a very simple media server for the devices connected to the local network. It has the aim to be fully compliant with any DLNA and UPnP client. The daemon serves media (video, audio and pictures). Example clients for it are applications like [VLC Media Player](https://www.videolan.org/), [Kodi](https://kodi.tv/), and devices such as televisions, gaming consoles, media players and smartphones.

## Installation

The installation is done from the official Debian repositories.

```sh
apt install minidlna
```

## Configuration

The configuration file is very well documented. It is located at `/etc/minidlna.conf`.
The file is as follows:
```
# This is the configuration file for the MiniDLNA daemon, a DLNA/UPnP-AV media
# server.
#
# Unless otherwise noted, the commented out options show their default value.
#
# On Debian, you can also refer to the minidlna.conf(5) man page for
# documentation about this file.

# Specify the user name or uid to run as (root by default).
# On Debian system command line option (from /etc/default/minidlna) overrides this.
#user=minidlna


# Path to the directory you want scanned for media files.
#
# This option can be specified more than once if you want multiple directories
# scanned.
#
# If you want to restrict a media_dir to a specific content type, you can
# prepend the directory name with a letter representing the type (A, P or V),
# followed by a comma, as so:
#   * "A" for audio    (eg. media_dir=A,/var/lib/minidlna/music)
#   * "P" for pictures (eg. media_dir=P,/var/lib/minidlna/pictures)
#   * "V" for video    (eg. media_dir=V,/var/lib/minidlna/videos)
#   * "PV" for pictures and video (eg. media_dir=PV,/var/lib/minidlna/digital_camera)
media_dir=/var/lib/minidlna

# Set this to merge all media_dir base contents into the root container
# (The default is no.)
#merge_media_dirs=no

# Path to the directory that should hold the database and album art cache.
#db_dir=/var/cache/minidlna

# Path to the directory that should hold the log file.
# Not used when "systemd" mode is activated with -S switch.
#log_dir=/var/log/minidlna

# Type and minimum level of importance of messages to be logged.
#
# The types are "artwork", "database", "general", "http", "inotify",
# "metadata", "scanner", "ssdp" and "tivo".
#
# The levels are "off", "fatal", "error", "warn", "info" or "debug".
# "off" turns of logging entirely, "fatal" is the highest level of importance
# and "debug" the lowest.
#
# The types are comma-separated, followed by an equal sign ("="), followed by a
# level that applies to the preceding types. This can be repeated, separating
# each of these constructs with a comma.
#
# The default is to log all types of messages at the "warn" level.
#log_level=general,artwork,database,inotify,scanner,metadata,http,ssdp,tivo=warn

# Use a different container as the root of the directory tree presented to
# clients. The possible values are:
#   * "." - standard container
#   * "B" - "Browse Directory"
#   * "M" - "Music"
#   * "P" - "Pictures"
#   * "V" - "Video"
#   * Or, you can specify the ObjectID of your desired root container
#     (eg. 1$F for Music/Playlists)
# If you specify "B" and the client device is audio-only then "Music/Folders"
# will be used as root.
#root_container=.

# Network interface(s) to bind to (e.g. eth0), comma delimited.
# This option can be specified more than once.
#network_interface=

# Port number for HTTP traffic (descriptions, SOAP, media transfer).
# This option is mandatory (or it must be specified on the command-line using
# "-p").
port=8200

# URL presented to clients (e.g. http://example.com:80).
#presentation_url=/

# Name that the DLNA server presents to clients.
# Defaults to "hostname: username".
#friendly_name=

# Serial number the server reports to clients.
# Defaults to the MAC address of nework interface.
#serial=

# Model name the server reports to clients.
#model_name=Windows Media Connect compatible (MiniDLNA)

# Model number the server reports to clients.
# Defaults to the version number of minidlna.
#model_number=

# Automatic discovery of new files in the media_dir directory.
#inotify=yes

# List of file names to look for when searching for album art.
# Names should be delimited with a forward slash ("/").
# This option can be specified more than once.
album_art_names=Cover.jpg/cover.jpg/AlbumArtSmall.jpg/albumartsmall.jpg
album_art_names=AlbumArt.jpg/albumart.jpg/Album.jpg/album.jpg
album_art_names=Folder.jpg/folder.jpg/Thumb.jpg/thumb.jpg

# Strictly adhere to DLNA standards.
# This allows server-side downscaling of very large JPEG images, which may
# decrease JPEG serving performance on (at least) Sony DLNA products.
#strict_dlna=no

# Support for streaming .jpg and .mp3 files to a TiVo supporting HMO.
#enable_tivo=no

# Which method to use for registering in TiVo: 'bonjour' (default) or
# legacy 'beacon'
#tivo_discovery=bonjour

# SSDP notify interval, in seconds.
#notify_interval=895

# Path to the MiniSSDPd socket, for MiniSSDPd support.
#minissdpdsocket=/run/minissdpd.sock

# Always set SortCriteria to this value, regardless of the SortCriteria
# passed by the client
# e.g. force_sort_criteria=+upnp:class,+upnp:originalTrackNumber,+dc:title
#force_sort_criteria=

# Maximum number of simultaneous connections
# note: many clients open several simultaneous connections while streaming
#max_connections=50

# set this to yes to allow symlinks that point outside user-defined media_dirs.
#wide_links=no

# Enable subtitle support by default on unknown clients.
#enable_subtitles=yes

# Generate video's thumbnails.
# To use this option, thumbnail generation must be enable at compile time.
#enable_thumbnail=no

# The width of the thumbnail image. Large images takes more time to generate.
#thumbnail_width=160

# Thumbnail Image quality.
#thumbnail_quality=8

# Should the thumbnail have a film strip?
#enable_thumbnail_filmstrip=no
```

You should look at the following settings:
1. `media_dir` specifies where the media to be served is located. You can specify this more than once.
2. `friendly_name` specifies the name which will appear in the discovery list for DLNA devices. If not specified, it will show the hostname of the server.
3. `inotify` specifies whether or not to discover new files automatically.

After modifying the configuration, do not forget to reload the service.
```sh
systemctl restart minidlna
```

## Web interface for status and statistics

MiniDLNA runs a small web server to show statistics and information. It shows how many files are indexed, the devices that have discovered the server and how many are currently having connections to it. By default, it runs on the port `8200` but that can be changed in the configuration file in the `port` option.

Here is how the web page looks:

{{<img src="/pix/minidlna-status.png"
	alt="A picture of the MiniDLNA status page." >}}

---
Written by [Tudor Voie](https://tudorvoie.eu)

