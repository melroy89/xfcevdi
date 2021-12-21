#!/usr/bin/env bash
USERNAME=${USERNAME:-"user"}
USER_ID=${USER_ID:-"1000"}
PASS=${PASS:-$(pwgen -s 12 1)}
ROOT_PASS=${ROOT_PASS:-$(pwgen -s 12 1)}
ALLOW_ROOT_SSH=${ALLOW_ROOT_SSH:-false}
ENTER_PASS=${ENTER_PASS:-false}

## Change SSH settings
# Enable password auth, enable hostkeys and optionally permit root user login
sed -i "s/#PasswordAuthentication/PasswordAuthentication/g" /etc/ssh/sshd_config
sed -i 's/#HostKey/HostKey/g' /etc/ssh/sshd_config
if [ "$ALLOW_ROOT_SSH" = true ]; then
  sed -i "s/#PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config
fi

## Create D-bus daemon runtime directory
mkdir -p /run/dbus

## Change rsyslog settings
# Disable kernel logging
sed -i "s/module(load=\"imklog\")/#module(load=\"imklog\")/g" /etc/rsyslog.conf

## PulseAudio?
# Should I create a /run/pulse maybe?
# Should I create a /run/user/1000 (is that normal under Debian?)
# Should I set XDG_RUNTIME_DIR env var to /run/user/1000

## Additional Firefox settings
# Enable xrender in Firefox ESR (very useful for X2Go performance)
echo 'pref("gfx.xrender.enabled", true);' >> /etc/firefox-esr/firefox-esr.js
# Enable Google by default as homepage
echo 'pref("browser.startup.homepage", "https://google.com");' >> /etc/firefox-esr/firefox-esr.js
# Start homepage directly
echo 'pref("browser.startup.firstrunSkipsHomepage", false);' >> /etc/firefox-esr/firefox-esr.js
# Do not show 'what is new'
echo 'pref("browser.startup.homepage_override.mstone", "ignore");' >> /etc/firefox-esr/firefox-esr.js
# Empty welcome URL
echo 'pref("startup.homepage_welcome_url", "");' >> /etc/firefox-esr/firefox-esr.js
# Disable first run infobar
echo 'pref("toolkit.telemetry.reportingpolicy.firstRun", false);' >> /etc/firefox-esr/firefox-esr.js
# No reports will be send (won't ask for privacy policy as well anymore)
echo 'pref("datareporting.policy.dataSubmissionEnabled", false);' >> /etc/firefox-esr/firefox-esr.js
# Empty firstRun URL
echo 'pref("datareporting.policy.firstRunURL", "");' >> /etc/firefox-esr/firefox-esr.js


## Setting access control
# Change root password
echo "root:$ROOT_PASS" | chpasswd
# Add new user
useradd -ms /bin/bash -u $USER_ID $USERNAME
echo "$USERNAME:$PASS" | chpasswd
# Add user to groups
usermod -a -G sudo,x2gouser $USERNAME
# Allow sudo command without entering a password
if [ "$ENTER_PASS" = false ]; then
  echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
fi

# Print hello in start-up, including VERSION number
cat <<-EOT > "/root/.bashrc"
echo -e "Thank you for using Melroy's VDI Docker image v1.5!\n"
echo "Info: Root password is: $ROOT_PASS"
echo "Info: New user ($USERNAME) has password: $PASS"
EOT
unset ROOT_PASS
unset PASS

# su $SPICE_USER -c tmux
echo "set -g mouse on" >> /root/.tmux.conf

touch /app/.setup_done
