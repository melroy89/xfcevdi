# XFCE VDI (using X2Go)

Docker image for running [Debian](https://hub.docker.com/_/debian) and [XFCE](https://www.xfce.org/) by leveraging the [X2Go protocol](https://wiki.x2go.org/doku.php/download:start).

## Purpose

This docker image enables you to start one or more instances of a Virtual Desktop Infrastructure (VDI). Without the need of VM's!

- By utilizing [Docker containers](https://www.docker.com/resources/what-container), there will be **NO** boot of whole operating system (like VMs do), instead docker will use the OS kernel resources and shares them with the docker container. Resulting in much faster start-up times than VMs can every do.

- By using the [X2Go protocol](https://wiki.x2go.org/) it's easy to connect/share sessions between the client and the server. Which allows remote working or any other task you might want do remotely in a windowing system.

- The image contains a [docker GNU/Linux Debian](https://hub.docker.com/_/debian) (bullseye) operating system, together with XFCE4 desktop environment. The required X2Goserver/X2Gosession are already pre-installed.

- In fact, this Docker image has alot of packages pre-installed you probably want anyway, including but not limited to: `Firefox`, `LibreOffice`, `gnome-calculator`, `archiver`, `file manager`, `text editor`, `image viewer`, `htop`, `clipboard manager` and much more.

- Last but not least, the image is preconfigured with a nice dark-theme (Breeze-Dark), window theme (Mint-Y-Dark) as well as a nice looking icon set (Mint-Y-Dark-Aqua) and uses Ubuntu fonts by default. See below an preview:

![Preview 1](preview.png)

Or an example with Papirus icons:

![Preview 2](preview_papirus.png)

_Note 1:_ You can always remove/install additional packages. By using the Docker container and apt command line (this won't be permanent). Or ideally, by changing [Dockerfile](Dockerfile) or extending the Docker image instead via: `FROM danger89/xfcevdi_x2go` in your own Dockerfile.

_Note 2:_ Optionally adapt the [XFCE settings script](xfce_settings.sh) to your needs. Eg. when you installed the Papirus icon theme and you want to use use the Papirus icons instead Mint-Y-Dark-Aqua icons.

## Usage

You could use the `docker` CLI or Docker Compose (`docker compose`).

_Note:_ The Docker image will be retrieved automatically from [DockerHub](https://hub.docker.com/r/danger89/xfcevdi_x2go).

### Docker

Start the docker container using (with default username: `user`, password: _is auto-generated_, port: `2222`):

```sh
docker run --shm-size 2g -it --rm -p 2222:22 danger89/xfcevdi_x2go:latest
```

Or with the username `melroy` with password `abc` on port: `2222`:

```sh
docker run --shm-size 2g -it --rm -p 2222:22 -e USERNAME=melroy -e PASS=abc danger89/xfcevdi_x2go:latest
```

Or make the default `user` home folder persistent between restarts:

```sh
docker run --shm-size 2g -it --rm -v $(pwd)/user_home:/home/user -p 2222:22 danger89/xfcevdi_x2go:latest
```

See "X2Go Clients" section below how to connect.

## Docker Compose

You can also use of [Docker Compose](https://docs.docker.com/compose/)!

**Adapt** the [compose.yaml](compose.yaml) file to your needs, and start the Docker container using: `docker compose up`

See "X2Go Clients" section below how to connect.

_Note:_ If you installed Docker Compose manually using the script, then the script name is: `docker-compose` iso `docker compose`.

## Environment variables

_Important:_ By default the newly created user is added to the `sudo` group, allowing to execute commands as root within the container.
_Important:_ By default the user can install new software using `apt` (eg. `sudo apt install`), without providing it's password.

You can either change the environment variables using `-e` flag during `docker run` _or_ by changing just the `environment` section in the `compose.yaml` file.

Docker run example, which disables both APT and sudo group: `docker run --shm-size 2g -it -e ALLOW_APT=no -e ALLOW_SUDO=no -p 2222:22 danger89/xfcevdi_x2go:latest`

Available environment variables::

| Env. variable | Type   | Description                                 | Default value         |
| ------------- | ------ | ------------------------------------------- | --------------------- |
| `USERNAME`    | string | New username                                | `user`                |
| `USER_ID`     | string | New User/Group ID                           | `1000`                |
| `PASS`        | string | Change password for user                    | _auto-generated pass_ |
| `ALLOW_APT`   | string | User is allowed to use APT commands         | `yes`                 |
| `ENTER_PASS`  | string | Require to enter password for sudo commands | `no`                  |
| `ALLOW_SUDO`  | string | Add user to `sudo` group                    | `yes`                 |

**NOTE 1:** Since [XFCE VDI v2.0](https://hub.docker.com/r/danger89/xfcevdi_x2go/tags), the new user is _only allowed_ to execute `apt` commands as root user. What can be changed on line 60 & 62 in [setup.sh script](scripts/setup.sh) and build your own Docker image.

**NOTE 2:** Since [XFCE VDI v2.0](https://hub.docker.com/r/danger89/xfcevdi_x2go/tags) we disabled the root user completely for safety reasons. You can still use `sudo` command with the default user (called: `user`), but only allowed to execute `apt`. Since v2.0 booleans are also converted to 'yes' or 'no' strings to avoid YAML syntax confusion.

## Update Docker Image

Leveraging Docker Compose, use:

1. Stop: `docker compose down`
2. Update: `docker compose pull xfcevdi`
3. Start again: `docker compose up -d` (runs in detached mode)

_Note:_ If you installed Docker Compose manually using the script, then the script name is: `docker-compose` iso `docker compose`.

Using Docker CLI:

1. Stop docker container: `docker stop <container_id>`
2. Update: `docker pull danger89/xfcevdi_x2go`
3. Start again: `docker run`

## X2Go Clients

X2Go has two clients available to choose from:

- X2Go Client (recommended)
- PyHoca-GUI

Which can both be [downloaded from their site](https://wiki.x2go.org/doku.php/download:start). Clients are available for Windows/Mac and/or GNU/Linux operating systems.

Once you open the client, create a new session by providing the following settings (default settings):

- Host: host IP addresss (or domain name or `localhost`)
- Login: `user` (default username)
- SSH port: `2222` (default port)
- Session type: `XFCE` (select from drop-down menu)

Once you try to connect, accept the new SSH host key and you'll require to enter a password (by default the **passwords are auto-generated**!).

## Build

You do _not_ need to build the image yourself, instead try to use the pre-build [Docker image](https://hub.docker.com/r/danger89/xfcevdi_x2go). See also "Usage" above.

If you want, you could build the image locally, using the command:

```sh
docker build --tag danger89/xfcevdi_x2go .
```

### Apt-Cacher (OPTIONAL!)

When you have [apt-cacher](http://manpages.ubuntu.com/manpages/jammy/man8/apt-cacher.8.html) or [apt-cacher-ng](http://manpages.ubuntu.com/manpages/jammy/en/man8/apt-cacher-ng.8.html) proxy installed, use `APT_PROXY` parameter to set the proxy URL; where `melroy-pc` is _your_ hostname:

**Important:** Be sure you configured `apt-cacher` correctly to accept incoming connections from Docker. Set: `allowed_hosts = *` in `/etc/apt-cacher/apt-cacher.conf` file.

```sh
docker build --build-arg APT_PROXY=http://melroy-pc:3142 --tag danger89/xfcevdi_x2go .
```

## Common issues

### Host key verification failed

This error means that you are using an old SSH host key.

**Solution:** Try not to terminate the session and when X2Go client ask you to update the host key, choose 'yes'. This will replace the old host key with the new key.

**Root-cause:** Each time you setup a new VDI Docker container, a new SSH host key is generated for you.
