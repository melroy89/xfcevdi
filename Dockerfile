FROM debian:buster

LABEL maintainer="melroy@melroy.org"

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_PROXY

WORKDIR /app

# Enable APT proxy (if APT_PROXY is set)
COPY ./configs/apt.conf ./
COPY ./apt_proxy.sh ./
RUN ./apt_proxy.sh

RUN apt-get update && apt-get install -y --no-install-recommends \
    dirmngr gnupg gnupg-l10n \
    gnupg-utils gpg gpg-agent \
    gpg-wks-client gpg-wks-server gpgconf \
    gpgsm libassuan0 libksba8 \
    libldap-2.4-2 libldap-common libnpth0 \
    libreadline7 libsasl2-2 libsasl2-modules \
    libsasl2-modules-db libsqlite3-0 libssl1.1 \
    lsb-base pinentry-curses readline-common \
    apt-transport-https ca-certificates curl \
    software-properties-common apt-utils net-tools

# Add X2Go apt list
RUN apt-key adv --recv-keys --keyserver keys.gnupg.net E1F958385BFE2B6E
COPY ./configs/x2go.list /etc/apt/sources.list.d/x2go.list

# Add contrib and non-free
RUN apt-add-repository contrib && apt-add-repository non-free
RUN apt-get update && apt-get install -y x2go-keyring && apt-get update
RUN apt-get install -y x2goserver x2goserver-xsession
RUN apt-get install -y --no-install-recommends \
    rsyslog \
    locales \
    pulseaudio \
    pavucontrol \
    git \
    wget \
    bzip2 \
    sudo \
    zip \
    unzip \
    unrar \
    tmux \
    ffmpeg \
    pwgen \
    openssh-server \
    nano \
    file \
    dialog \
    coreutils \
    xdg-utils \
    xz-utils \
    util-linux \
    x11-utils \
    x11-xkb-utils
RUN apt-get upgrade -y && apt-get install -y \
    xfce4-session xfwm4 xfce4-panel \
    xfce4-terminal xfce4-appfinder \
    thunar tumbler xfce4-clipman-plugin \
    xfce4-screenshooter xfce4-notifyd xfce4-pulseaudio-plugin \
    xfce4-statusnotifier-plugin
# TODO: Don't install xfce4-goodies, but only install a sub-part of some useful plugins only!
# Like: Notes, xarchiver, bulk rename, window manager tweaks, ?

# Add Papirus icons
RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com E58A9D36647CAE7F
COPY ./configs/papirus-ppa.list /etc/apt/sources.list.d/papirus-ppa.list
RUN apt-get update \
    && apt-get install -y --no-install-recommends fonts-ubuntu fonts-dejavu-core breeze-gtk-theme papirus-icon-theme

RUN apt-get install -y --no-install-recommends firefox-esr htop gnome-calculator mousepad ristretto

RUN update-locale
RUN rm -rf /etc/ssh/ssh_host_* \
    && ssh-keygen -A
EXPOSE 22

COPY ./setup.sh ./
COPY ./run.sh ./
CMD ./run.sh