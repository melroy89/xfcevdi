#!/usr/bin/env bash
# Change some settings of XFCE4 look & feel

if [ ! -f /home/$USER/.local/.xfce_settings_done ]; then
  # Panels are getting created wait before xfce setup is completed
  sleep 1.5

  # Additional changes to XFCE settings (xsettings.xml)
  xfconf-query -c xsettings -p /Net/ThemeName -s "Breeze-Dark"
  xfconf-query -c xsettings -p /Net/IconThemeName -s "Papirus-Dark"
  xfconf-query -c xsettings -p /Gtk/FontName -s "Ubuntu 10"

  # Change window style manager
  # TODO: Change theme, like: Mint-y-dark-blue
  xfconf-query -c xfwm4 -p /general/theme -s "Moheli"
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

  # TODO: Add PulseAudio plugin to panel

  # Change browser icon to Firefox
  launchName="launcher-11"
  filename=$(ls /home/$USER/.config/xfce4/panel/$launchName/ | head -1)
  sed -i "s/Icon=.*/Icon=firefox/" /home/$USER/.config/xfce4/panel/$launchName/$filename

  # Reset panel(s) once
  xfce4-panel -r

  touch /home/$USER/.local/.xfce_settings_done
fi