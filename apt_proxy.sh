#!/usr/bin/env bash
# Enable apt proxy, when using for example apt-cacher on the host

if [ -n "$APT_PROXY" ]; then
  sed -i 's,'PROXY_URL','"$APT_PROXY"',' /app/apt.conf
  cp /app/apt.conf /etc/apt
fi
