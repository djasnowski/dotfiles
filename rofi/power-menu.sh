#!/bin/bash

# Power menu options
options="Lock\nLogout\nSuspend\nReboot\nShutdown\nCancel"

# Show menu
chosen="$(echo -e "$options" | rofi -dmenu -p "Power Menu" -theme-str 'window {width: 250px;} listview {lines: 6;}')"

case $chosen in
    Lock)
        i3lock -c 000000
        ;;
    Logout)
        confirm="$(echo -e "Yes\nNo" | rofi -dmenu -p "Logout?" -theme-str 'window {width: 200px;} listview {lines: 2;}')"
        if [ "$confirm" = "Yes" ]; then
            i3-msg exit
        fi
        ;;
    Suspend)
        confirm="$(echo -e "Yes\nNo" | rofi -dmenu -p "Suspend?" -theme-str 'window {width: 200px;} listview {lines: 2;}')"
        if [ "$confirm" = "Yes" ]; then
            systemctl suspend
        fi
        ;;
    Reboot)
        confirm="$(echo -e "Yes\nNo" | rofi -dmenu -p "Reboot?" -theme-str 'window {width: 200px;} listview {lines: 2;}')"
        if [ "$confirm" = "Yes" ]; then
            systemctl reboot
        fi
        ;;
    Shutdown)
        confirm="$(echo -e "Yes\nNo" | rofi -dmenu -p "Shutdown?" -theme-str 'window {width: 200px;} listview {lines: 2;}')"
        if [ "$confirm" = "Yes" ]; then
            systemctl poweroff
        fi
        ;;
    Cancel)
        exit 0
        ;;
esac