# mitsutaka/armv7-plexmediaserver

[Plex](https://plex.tv/) organizes video, music and photos from personal media libraries and streams them to smart TVs, streaming boxes and mobile devices.

[![plex](http://the-gadgeteer.com/wp-content/uploads/2015/10/plex-logo-e1446990678679.png)][plexurl]
[plexurl]: https://plex.tv

Tested on Raspberry Pi 3

## Usage

```
docker run \
--name=plex \
--net=host \
-v </path/to/library>:/media/video \
-v <path/to/resource>:/var/lib/plex \
mitsutaka/armv7-plexmediaserver
