#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

# Syslog could be enabled to diagnose issues or debug
#service rsyslog start

if [ ! -f /app/.setup_done ]; then
  /app/setup.sh
fi

## Start-up our services below (since Docker container will not invoke all init scripts)

# Start SSH daemon
service ssh start

# Start dbus system daemon
service dbus start

# Start bash
bash