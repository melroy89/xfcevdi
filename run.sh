#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

if [ ! -f /app/.setup_done ]; then
  /app/setup.sh
fi

## Start-up our services manually (since Docker container will not invoke all init scripts).
## However, some service do start automatically, when placed and NOT-hidden in: /etc/xdg/autostart folder.

# Start SSH daemon
service ssh start
# Start dbus system daemon
service dbus start
# Start syslog (for debugging reasons)
service rsyslog start

## Start bash and idle
bash