#!/usr/bin/env bash
# Additional changes to XFCE settings (xsettings.xml)
xfconf-query -c xsettings -p /Net/ThemeName -s "Breeze-Dark"
xfconf-query -c xsettings -p /Net/IconThemeName -s "Papirus-Dark"
xfconf-query -c xsettings -p /Gtk/FontName -s "Ubuntu 10"

# Change window style manager
xfconf-query -c xfwm4 -p /general/theme -s "Moheli" # TODO: Mint-y-dark-blue
xfconf-query -c xfwm4 -p /general/title_font -s "Ubuntu Medium 10"

# Move terminalrc config to correct location
mkdir -p /home/$USER/.config/xfce4/terminal/
cp -rf /app/terminalrc /home/$USER/.config/xfce4/terminal/

# Use custom whisker menu settings
mkdir -p /home/$USER/.config/xfce4/panel/
cp -rf /app/whiskermenu-1.rc /home/$USER/.config/xfce4/panel/

# Change default menu to whisker menu
xfconf-query -c xfce4-panel -p /plugins/plugin-1 -s "whiskermenu"

# Change bottom-panel to intelligently-hide
xfconf-query -c xfce4-panel -p /panels/panel-2/autohide-behavior -n -t int -s 1

# Change Splash engine
xfconf-query -c xfce4-session -p /splash/Engine -n -t string -s "mice"

# Reset panel(s)
xfce4-panel -r

# Be sure XFCE4 session is restarted fully
sleep 1

# TODO: Use Mice Splash (session and startup)
# TODO: Use whiskermenu menu as default menu (add plugin to panel) 
# TODO: Maybe disable compositor (if not already)?
# TODO: Add PulseAudio plugin to panel
# TODO: Remove screen locker from autostart and check Clipman to actually autostart

# Change browser icon to Firefox
launchName="launcher-11"
filename=$(ls /home/$USER/.config/xfce4/panel/$launchName/ | head -1)
sed -i "s/Icon=.*/Icon=firefox/" /home/$USER/.config/xfce4/panel/$launchName/$filename
