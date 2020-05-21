FROM debian:buster

LABEL maintainer="melroy@melroy.org"

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_PROXY

WORKDIR /app

# Enable APT proxy (if APT_PROXY is set)
COPY ./configs/apt.conf ./
COPY ./apt_proxy.sh ./
RUN ./apt_proxy.sh

## First install basic require packages
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

## Add additional repositories/components (software-properties-common is required to be installed)
# Add contrib and non-free distro components
RUN apt-add-repository contrib && apt-add-repository non-free
# Add Debian backports for LibreOffice and Papirus icons
RUN add-apt-repository -s "deb http://deb.debian.org/debian buster-backports main contrib non-free"
# Add X2Go apt list
RUN apt-key adv --recv-keys --keyserver keys.gnupg.net E1F958385BFE2B6E
COPY ./configs/x2go.list /etc/apt/sources.list.d/x2go.list

## Install X2Go server and session
RUN apt update && apt-get install -y x2go-keyring && apt-get update
RUN apt-get install -y x2goserver x2goserver-xsession
## Install important (and often used) dependency packages
RUN apt-get install -y --no-install-recommends \
    openssh-server \
    locales \
    rsyslog \
    pavucontrol \
    git \
    wget \
    sudo \
    zip \
    bzip2 \
    unzip \
    unrar \
    tmux \
    ffmpeg \
    pwgen \
    nano \
    file \
    dialog \
    util-linux \
    coreutils \
    xdg-utils \
    xz-utils \
    x11-utils \
    x11-xkb-utils
## Install XFCE4
RUN apt-get upgrade -y && apt-get install -y \
    xfce4-session xfwm4 xfce4-panel \
    xfce4-terminal xfce4-appfinder \
    thunar tumbler xfce4-clipman-plugin \
    xfce4-screenshooter xfce4-notifyd xfce4-pulseaudio-plugin \
    xfce4-statusnotifier-plugin xfce4-datetime-plugin xfce4-notes-plugin \
    xarchiver thunar-archive-plugin xfce4-whiskermenu-plugin
# TODO: request for buster-backports for mugshot

## Add themes & fonts
RUN apt-get install -y --no-install-recommends fonts-ubuntu fonts-dejavu-core breeze-gtk-theme
# Add Papirus icons from backports
RUN apt install -y -t buster-backports papirus-icon-theme

## Add additional applications
RUN apt-get install -y --no-install-recommends firefox-esr htop gnome-calculator mousepad ristretto
# Add Office
RUN apt install -y -t buster-backports libreoffice-base libreoffice-base-core libreoffice-common libreoffice-core libreoffice-base-drivers \
    libreoffice-nlpsolver libreoffice-script-provider-bsh libreoffice-script-provider-js libreoffice-script-provider-python libreoffice-style-colibre \
    libreoffice-writer libreoffice-calc libreoffice-impress libreoffice-draw libreoffice-math 

# Update locales, generate new SSH host keys and clean-up (keep manpages)
RUN update-locale
RUN rm -rf /etc/ssh/ssh_host_* \
    && ssh-keygen -A
RUN apt-get clean -y && rm -rf /usr/share/doc/* /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apk/*

EXPOSE 22

# Start default XFCE4 panels (don't ask for it)
RUN mv -f /etc/xdg/xfce4/panel/default.xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
# Use mice as default Splash
COPY ./configs/xfconf/xfce4-session.xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml
# Add XFCE4 settings to start-up
COPY ./configs/xfce4-settings.desktop /etc/xdg/autostart/
# Enable Clipman by default during start-up
RUN sed -i "s/Hidden=.*/Hidden=false/" /etc/xdg/autostart/xfce4-clipman-plugin-autostart.desktop
# Remove unnecessary existing start-up apps
RUN rm -rf /etc/xdg/autostart/light-locker.desktop /etc/xdg/autostart/xscreensaver.desktop
COPY ./setup.sh ./
COPY ./configs/terminalrc ./
COPY ./configs/whiskermenu-1.rc ./
COPY ./xfce_settings.sh ./
COPY ./run.sh ./
CMD ./run.sh