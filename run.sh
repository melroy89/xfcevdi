#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

if [ ! -f /app/.setup_done ]; then
  /app/setup.sh
fi

# Start syslog and SSH daemon
#service rsyslog start
service ssh start

# Enter tmux terminal
tmux