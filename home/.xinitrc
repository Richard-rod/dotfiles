picom &
xset s 300 5
xset -dpms
xss-lock --transfer-sleep-lock -- $HOME/dotfiles/scripts/lock &
gnome-keyring-daemon --start --components=secrets &
nm-applet &
exec dwm
