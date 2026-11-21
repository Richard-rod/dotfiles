picom &
xset s 300 5
xset -dpms
export GDK_DPI_SCALE=1.4
xss-lock --transfer-sleep-lock -- $HOME/dotfiles/scripts/lock &
gnome-keyring-daemon --start --components=secrets &
nm-applet &
exec dwm
