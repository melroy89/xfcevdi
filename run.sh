#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

# Syslog could be enabled to diagnose issues or debug
#service rsyslog start

if [ ! -f /app/.setup_done ]; then
  /app/setup.sh
fi

# Start syslog and SSH daemon
service ssh start

# Enter tmux terminal
tmux