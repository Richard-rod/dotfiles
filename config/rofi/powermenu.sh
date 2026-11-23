#!/usr/bin/env bash

## Author : Aditya Shakya (adi1090x)
## Github : @adi1090x
## Modified by Richard (Richard-rod), 2026. Licensed under GPL-3.0, see licenses/GPL-3.0-adi1090x-rofi.txt

# CMDs
uptime="`uptime -p | sed -e 's/up //g'`"

# Options
shutdown='󰐥'
reboot='󰜉'
lock=''
suspend=''
logout='󰍃'

# Rofi CMD
rofi_cmd() {
	rofi -dmenu \
		-p "" \
		-mesg "Uptime: $uptime" \
		-theme "$HOME/.config/rofi/themes/powermenu.rasi"
}

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

# Execute Command
run_cmd() {
	case $1 in
		--shutdown)
			systemctl poweroff
			;;
		--reboot)
			systemctl reboot
			;;
		--suspend)
			amixer set Master mute
			systemctl suspend
			;;
		--logout)
			pkill dwm
			;;
	esac
}

# Actions
chosen="$(run_rofi)"
case "${chosen}" in
    "${shutdown}")
		run_cmd --shutdown
        ;;
    "${reboot}")
		run_cmd --reboot
        ;;
    "${lock}")
		"$HOME/dotfiles/scripts/lock"
        ;;
    "${suspend}")
		run_cmd --suspend
        ;;
    "${logout}")
		run_cmd --logout
        ;;
esac
