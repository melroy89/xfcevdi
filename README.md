# XFCE VDI (X2Go)

Docker image for running Debian and XFCE by using the [X2Go protocol](https://wiki.x2go.org/doku.php/download:start).

## Build

Build the image locally, via:

```sh
docker build --tag vdi .
```

Or when you have [apt-cacher](http://manpages.ubuntu.com/manpages/focal/man8/apt-cacher.8.html) proxy installed, use `APT_PROXY` parameter to set the proxy URL: `docker build --build-arg APT_PROXY=http://melroy-pc:3142 --tag vdi .`


## Usage

Start the docker container using:

```sh
docker run --shm-size 2g -it -p 2222:22 vdi:latest
```

Or with the username `melroy` with password `abc`:

```sh
docker run --shm-size 2g -it -p 2222:22 -e USERNAME=melroy -e PASS=abc vdi:latest
```

## TODOs / Questions

* See TODOs in `xfce_settings.sh`