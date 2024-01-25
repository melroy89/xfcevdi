#!/usr/bin/env bash
# Change some settings of XFCE4 look & feel

if [ ! -f /home/$USER/.local/.xfce_settings_done ]; then
  # Using the gsettings comand to change the GTK, Icon & Windows theme + font
  gsettings set org.gnome.desktop.interface gtk-theme "Mint-Y-Dark-Aqua"
  gsettings set org.gnome.desktop.interface icon-theme "Mint-Y-Aqua"
  gsettings set org.gnome.desktop.wm.preferences theme "Mint-Y-Dark-Aqua"
  gsettings set org.gnome.desktop.interface font-name "Ubuntu 10"

  # Additional changes to XFCE settings (xsettings.xml)
  # Change again the themes & font, maybe a bit redundant
  xfconf-query -c xsettings -p /Net/ThemeName -s "Mint-Y-Dark-Aqua"
  xfconf-query -c xsettings -p /Net/IconThemeName -s "Mint-Y-Aqua"
  xfconf-query -c xsettings -p /Gtk/FontName -s "Ubuntu 10"
  # Change window style manager
  xfconf-query -c xfwm4 -p /general/theme -s "Mint-Y-Dark-Aqua"
  xfconf-query -c xfwm4 -p /general/title_font -s "Ubuntu Medium 10"

  # Disable XFCE Compositor
  xfconf-query -c xfwm4 -p /general/use_compositing -t bool -s false

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
  # Set the row size to exactly 52 pixels (to get a sharp icons)
  xfconf-query -c xfce4-panel -p /panels/panel-2/size -s 52
  
  # TODO: Change background image?
  # TODO: Add Dict plugin to xfce4 panel?

  # Reset panel(s) once (can all this be done, without the need of restarting?)
  xfce4-panel -r

  # Change browser icon to Firefox
  declare -i MAX_TRIES=25
  declare -i COUNTER=0
  while true; do
    sleep 0.2
    # Check if panel is started
    PID_ID=$(pidof xfce4-panel)
    if [ -n "$PID_ID" ]; then
      launchName="launcher-19"
      filename=$(ls /home/$USER/.config/xfce4/panel/$launchName/ | head -1)
      filepath="/home/$USER/.config/xfce4/panel/$launchName/$filename"
      # Check if file is already present
      if [ -f "$filepath" ]; then
        sed -i "s/Icon=.*/Icon=firefox/" "$filepath"
        # Exit loop
        break
      fi

      # Time-out (0.2 secs * 25), also break
      if [ "$COUNTER" -gt "$MAX_TRIES" ]; then
        break
      fi
      # Increase timer
      let COUNTER++
    fi
  done

  touch /home/$USER/.local/.xfce_settings_done
fi