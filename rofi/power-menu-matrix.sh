#!/bin/bash

# Power menu options with Matrix-style icons
options=" sleep\n lock\n logout\n reboot\n shutdown\n cancel"

# Show menu with Matrix theme
chosen="$(echo -e "$options" | rofi -dmenu -p "system" -theme /home/dan/.local/share/rofi/themes/matrix.rasi -theme-str 'window {width: 350px;} listview {lines: 6;}')"

case $chosen in
    *lock)
        i3lock -c 000000
        ;;
    *logout)
        confirm="$(echo -e " confirm\n cancel" | rofi -dmenu -p "logout?" -theme /home/dan/.local/share/rofi/themes/matrix.rasi -theme-str 'window {width: 250px;} listview {lines: 2;} prompt {text-color: #FF0000;}')"
        if [[ "$confirm" == *"confirm" ]]; then
            i3-msg exit
        fi
        ;;
    *sleep)
        confirm="$(echo -e " confirm\n cancel" | rofi -dmenu -p "suspend?" -theme /home/dan/.local/share/rofi/themes/matrix.rasi -theme-str 'window {width: 250px;} listview {lines: 2;} prompt {text-color: #FFFF00;}')"
        if [[ "$confirm" == *"confirm" ]]; then
            systemctl suspend
        fi
        ;;
    *reboot)
        confirm="$(echo -e " confirm\n cancel" | rofi -dmenu -p "reboot?" -theme /home/dan/.local/share/rofi/themes/matrix.rasi -theme-str 'window {width: 250px;} listview {lines: 2;} prompt {text-color: #FF8800;}')"
        if [[ "$confirm" == *"confirm" ]]; then
            systemctl reboot
        fi
        ;;
    *shutdown)
        confirm="$(echo -e " confirm\n cancel" | rofi -dmenu -p "shutdown?" -theme /home/dan/.local/share/rofi/themes/matrix.rasi -theme-str 'window {width: 250px;} listview {lines: 2;} prompt {text-color: #FF0000;}')"
        if [[ "$confirm" == *"confirm" ]]; then
            systemctl poweroff
        fi
        ;;
    *cancel)
        exit 0
        ;;
esac