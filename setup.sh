#!/usr/bin/env bash
USERNAME=${USERNAME:-"user"}
USER_ID=${USER_ID:-"1000"}
PASS=${PASS:-$(pwgen -s 12 1)}
ROOT_PASS=${ROOT_PASS:-$(pwgen -s 12 1)}

sed -i "s/#PasswordAuthentication/PasswordAuthentication/g" /etc/ssh/sshd_config
sed -i "s/#PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config
sed -i 's/#HostKey/HostKey/g' /etc/ssh/sshd_config

# Change root password
echo "root:$ROOT_PASS" | chpasswd

# add new user
useradd -ms /bin/bash -u $USER_ID $USERNAME
echo "$USERNAME:$PASS" | chpasswd

# Add user to groups
groupadd fuse
usermod -a -G sudo,adm,audio,video,plugdev,x2gouser,fuse $USERNAME

# Allow sudo without entering the password
echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

cat <<-EOT > "/root/.bashrc"
    if [ -z "$TMUX" ]; then
      echo "Root password is: $ROOT_PASS"
      echo "New user ($USERNAME) has password: $PASS"
    fi
EOT
unset ROOT_PASS
unset PASS

# su $SPICE_USER -c tmux
echo "set -g mouse on" >> /root/.tmux.conf

touch /app/.setup_done
