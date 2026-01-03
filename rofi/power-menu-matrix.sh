#!/bin/bash

options="Suspend\nLock\nLogout\nReboot\nShutdown"

chosen=$(echo -e "$options" | rofi -dmenu -i -p "Power" -theme ~/.local/share/rofi/themes/matrix.rasi -lines 5)

case "$chosen" in
    "Suspend")
        systemctl suspend
        ;;
    "Lock")
        i3lock -c 0D0208
        ;;
    "Logout")
        i3-msg exit
        ;;
    "Reboot")
        systemctl reboot
        ;;
    "Shutdown")
        systemctl poweroff
        ;;
    *)
        exit 0
        ;;
esac
