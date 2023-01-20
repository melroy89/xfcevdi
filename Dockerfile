FROM debian:bullseye

LABEL maintainer="melroy@melroy.org"

# Default (run-time) environment variables
# Used during initial setup
ENV USERNAME=user
ENV USER_ID=1000
ENV ALLOW_APT=yes
ENV ENTER_PASS=no
ENV ALLOW_SUDO=yes

# Build arguments, _only_ used during Docker build
ARG DEBIAN_FRONTEND=noninteractive
ARG APT_PROXY

WORKDIR /app

# Enable APT proxy (if APT_PROXY is set)
COPY ./configs/apt.conf ./
COPY ./scripts/apt_proxy.sh ./
RUN ./apt_proxy.sh

## First install basic required packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    dirmngr gnupg gnupg-l10n \
    gnupg-utils gpg gpg-agent \
    gpg-wks-client gpg-wks-server gpgconf \
    gpgsm libassuan0 libksba8 \
    libldap-2.4-2 libldap-common libnpth0 \
    libreadline8 libsasl2-2 libsasl2-modules \
    libsasl2-modules-db libsqlite3-0 libssl1.1 \
    lsb-base pinentry-curses readline-common \
    apt-transport-https ca-certificates curl \
    software-properties-common apt-utils net-tools

## Add additional repositories/components (software-properties-common is required to be installed)
# Add contrib and non-free distro components (deb822-style format)
RUN apt-add-repository -y contrib && apt-add-repository -y non-free
# Add Debian backports repo for XFCE thunar-font-manager
RUN add-apt-repository -y "deb http://deb.debian.org/debian bullseye-backports main contrib non-free"

# Retrieve third party GPG keys from keyserver
RUN gpg --keyserver keyserver.ubuntu.com --recv-keys 302F0738F465C1535761F965A6616109451BBBF2 972FD88FA0BAFB578D0476DFE1F958385BFE2B6E

# Add Linux Mint GPG keyring file (for the Mint-Y-Dark theme)
RUN gpg --export 302F0738F465C1535761F965A6616109451BBBF2 | tee /etc/apt/trusted.gpg.d/linuxmint-archive-keyring.gpg >/dev/null

# Add Linux Mint Debbie repo source file
COPY ./configs/linuxmint-debbie.list /etc/apt/sources.list.d/linuxmint-debbie.list

# Add X2Go GPG keyring file
RUN gpg --export 972FD88FA0BAFB578D0476DFE1F958385BFE2B6E | tee /etc/apt/trusted.gpg.d/x2go-archive-keyring.gpg >/dev/null

# Add X2Go repo source file
COPY ./configs/x2go.list /etc/apt/sources.list.d/x2go.list

## Install X2Go server and session
RUN apt update && apt-get install -y x2go-keyring && apt-get update
RUN apt-get install -y x2goserver x2goserver-xsession
## Install important (or often used) dependency packages
RUN apt-get install -y --no-install-recommends \
    openssh-server \
    pulseaudio \
    pavucontrol \
    dbus-x11 \
    locales \
    rsyslog \
    git \
    wget \
    sudo \
    zip \
    bzip2 \
    unzip \
    unrar \
    ffmpeg \
    pwgen \
    nano \
    file \
    dialog \
    at-spi2-core \
    util-linux \
    coreutils \
    xdg-utils \
    xz-utils \
    x11-utils \
    x11-xkb-utils

## Add themes & fonts
RUN apt-get install -y --no-install-recommends fonts-ubuntu breeze-gtk-theme mint-themes
# Don't add papirus icons (can be comment-out if you want)
#RUN apt install -y papirus-icon-theme

# Add LibreOffice
RUN apt install -y libreoffice-base libreoffice-base-core libreoffice-common libreoffice-core libreoffice-base-drivers \
    libreoffice-nlpsolver libreoffice-script-provider-bsh libreoffice-script-provider-js libreoffice-script-provider-python libreoffice-style-colibre \
    libreoffice-writer libreoffice-calc libreoffice-impress libreoffice-draw libreoffice-math

## Install XFCE4
# Install XFCE4, including XFCE panels, terminal, screenshooter, task manager, notify daemon, dbus, locker and plugins.
# ! But we do NOT install xfce4-goodies; since this will install xfburn (not needed) and xfce4-statusnotifier-plugin (deprecated) !
RUN apt-get upgrade -y && apt-get install -y --no-install-recommends \
    xfwm4 xfce4-session default-dbus-session-bus xfdesktop4 light-locker \
    xfce4-panel xfce4-terminal librsvg2-common \
    xfce4-dict xfce4-screenshooter xfce4-appfinder \
    xfce4-taskmanager xfce4-notifyd xfce4-whiskermenu-plugin \
    xfce4-pulseaudio-plugin xfce4-clipman-plugin xfce4-indicator-plugin

# Install additional apps including recommendations, mainly: file manager, archive manager and image viewer
RUN apt-get install -y \
    ristretto tumbler xarchiver \
    thunar thunar-archive-plugin thunar-media-tags-plugin

## Add more applications
# Most importanly: browser, calculator, file editor, video player, profile manager
RUN apt-get install -y --no-install-recommends \
    firefox-esr htop gnome-calculator \
    mousepad celluloid mugshot

# Update locales, generate new SSH host keys and clean-up (keep manpages)
RUN update-locale
RUN rm -rf /etc/ssh/ssh_host_* && ssh-keygen -A
RUN apt-get clean -y && rm -rf /usr/share/doc/* /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apk/*

# Update timezone to The Netherlands
RUN echo 'Europe/Amsterdam' >/etc/timezone
RUN unlink /etc/localtime && ln -s /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime

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

# Disable root shell
RUN usermod -s /usr/sbin/nologin root

## Create worker user (instead of root user)
RUN useradd -G sudo -ms /bin/bash -u 1001 worker
RUN echo "Defaults!/app/setup.sh setenv" >>/etc/sudoers
# Limit the execute of the following commands of the worker user
RUN echo "worker ALL=(root) NOPASSWD:/usr/sbin/service ssh start, /usr/sbin/service dbus start, /usr/sbin/service rsyslog start, /app/setup.sh" >>/etc/sudoers
# Copy worker scripts
COPY ./scripts/setup.sh ./
COPY ./configs/terminalrc ./
COPY ./configs/whiskermenu-1.rc ./
COPY ./scripts/xfce_settings.sh ./
COPY ./scripts/run.sh ./
# Print hello during worker bash start-up
RUN echo 'echo "Info: Thank you for using Melroys VDI XFCE Docker image!"' >>/home/worker/.bashrc

# Run as worker
USER worker
# Change default working directory
WORKDIR /home/worker

EXPOSE 22

CMD ["/bin/bash", "/app/run.sh"]
