#!/usr/bin/env bash
USERNAME=${USERNAME:-"user"}
USER_ID=${USER_ID:-"1000"}
PASS=${PASS:-$(pwgen -s 12 1)}
ROOT_PASS=${ROOT_PASS:-$(pwgen -s 12 1)}
ALLOW_ROOT_SSH=${ALLOW_ROOT_SSH:-false}
ENTER_PASS=${ENTER_PASS:-false}

sed -i "s/#PasswordAuthentication/PasswordAuthentication/g" /etc/ssh/sshd_config
sed -i 's/#HostKey/HostKey/g' /etc/ssh/sshd_config
if [ "$ALLOW_ROOT_SSH" = true ]; then
  sed -i "s/#PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config
fi

# Change root password
echo "root:$ROOT_PASS" | chpasswd

# add new user
useradd -ms /bin/bash -u $USER_ID $USERNAME
echo "$USERNAME:$PASS" | chpasswd

# Add user to groups
usermod -a -G sudo,x2gouser $USERNAME

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

# Allow sudo without entering the password
if [ "$ENTER_PASS" = false ]; then
  echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
fi

cat <<-EOT > "/root/.bashrc"
echo -e "Thank you for using Melroy's VDI docker image!\n"
echo "Info: Root password is: $ROOT_PASS"
echo "Info: New user ($USERNAME) has password: $PASS"
EOT
unset ROOT_PASS
unset PASS

# su $SPICE_USER -c tmux
echo "set -g mouse on" >> /root/.tmux.conf

touch /app/.setup_done
