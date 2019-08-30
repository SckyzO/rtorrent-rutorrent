# RuTorrent Image

Based on [xataz/rutorrent](https://github.com/xataz/docker-rtorrent-rutorrent) image, but my image is up to date with last version of rtorrent, libtorrent, mediainfo, nginx & php.

## Features
* Based on Alpine Linux.
* rTorrent and libtorrent are compiled from source.
* Provides by default a solid configuration.
* Filebot is included, and creates symlinks in /data/Media.
* No **ROOT** process.
* Persitance custom configuration for rutorrent and rtorrent.
* Add your own plugins and themes


## Tag available
* latest [(Dockerfile)](https://github.com/sckyzo/rtorrent-rutorrent)
* latest-filebot, filebot [(Dockerfile)](https://github.com/sckyzo/rtorrent-rutorrent)

## Description
What is [RuTorrent](https://github.com/Novik/ruTorrent) ?

ruTorrent is a front-end for the popular Bittorrent client rtorrent.
This project is released under the GPLv3 license, for more details, take a look at the LICENSE.md file in the source.

What is [rtorrent](https://github.com/rakshasa/rtorrent/) ?

rtorrent is the popular Bittorrent client.

**This image not contains root process**

## BUILD IMAGE
### Build arguments
* BUILD_CORES : Number of cpu's core for compile (default : empty for use all cores)
* MEDIAINFO_VER : Mediainfo version (default : 0.7.99)
* RTORRENT_VER : rtorrent version (default : 0.9.7)
* LIBTORRENT_VER : libtorrent version (default : 0.13.7)
* WITH_FILEBOT : Choose if install filebot (default : no)
* FILEBOT_VER : filebot version (default : 4.7.9)

### simple build
```shell
docker build -t sckyzo/rtorrent-rutorrent github.com/sckyzo/dockerfiles.git#master:rtorrent-rutorrent
```

### Build with arguments
```shell
docker build -t sckyzo/rtorrent-rutorrent:custom --build-arg WITH_FILEBOT=YES --build-arg RTORRENT_VER=0.9.4 github.com/sckyzo/dockerfiles.git#master:rtorrent-rutorrent
```


## Configuration
### Environments
* UID : Choose uid for launch rtorrent (default : 1000)
* GID : Choose gid for launch rtorrent (default : 998)
* WEBROOT : (default : /)
* PORT_RTORRENT : (default : 45000)
* DHT_RTORRENT : (default : off)
* FILEBOT_RENAME_METHOD : Method for rename media (default : symlink)
* FILEBOT_RENAME_MOVIES : Regex for rename movies (default : "{n} ({y})")
* FILEBOT_RENAME_MUSICS : Regex for rename musics (default : "{n}/{fn}")
* FILEBOT_RENAME_SERIES : Regex for rename series (default : "{n}/Season {s.pad(2)}/{s00e00} - {t}")
* FILEBOT_RENAME_ANIMES : Regex for rename animes (default : "{n}/{e.pad(3)} - {t}")
* FILEBOT_LANG : (default : fr)
* FILEBOT_CONFLICT : (default : skip)
* DISABLE_PERM_DATA : (default : false)

### Volumes
* /data : Folder for download torrents
* /config : Folder for rtorrent and rutorrent configuration

#### data Folder tree
* /data/.watch : Rtorrent watch directory
* /data/.session : Rtorrent save statement here
* /data/torrents : Rtorrent download torrent here
* /data/Media : If filebot version, rtorrent create a symlink
* /config/rtorrent : Path of .rtorrent.rc
* /config/rutorrent/conf : Global configuration of rutorrent
* /config/rutorrent/share : rutorrent user configuration and cache
* /config/custom_plugins : Add your own plugins
* /config/custom_themes : Add your own themes

### Ports
* 8080
* $PORT_RTORRENT

## Usage
### Simple launch
```shell
docker run -dt -p 8080:8080 sckyzo/rtorrent-rutorrent
```
URI access : http://XX.XX.XX.XX:8080

### Advanced launch
Add custom plugin :
```shell
$ mkdir -p /docker/config/custom_plugins
$ cd /docker/config/custom_plugins
$ git clone https://github.com/Gyran/rutorrent-ratiocolor.git ./ratiocolor
```

Run container :
```shell
docker run -dt 
  -p 9080:8080 \
  -p 6881:6881 \
  -p 6881:6881/udp \
  -p 127.0.0.1:5000:5000 \
  -e WEBROOT=/rutorrent  \
  -e DHT_RTORRENT=on     \
  -e PORT_RTORRENT=6881  \
  -e FILEBOT_RENAME_METHOD=move \
  -e FILEBOT_RENAME_SERIES="{n}/Season {s}/{n} - {s00e00} - {t}" \
  -e UID=1001 \
  -e GID=1001 \
  -v rutorrent-data-volume:/data   \
  -v /docker/config:/config        \
  sckyzo/rtorrent-rutorrent:filebot
```
URI access : http://XX.XX.XX.XX:9080/rutorrent

### Use with Traefik proxy
```yaml

```

## Contributing
Any contributions, are very welcome !


# rtorrent-rutorrent
