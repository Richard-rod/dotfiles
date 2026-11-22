picom &
xset s 300 5
xset -dpms
export GDK_DPI_SCALE=1.4
xss-lock --transfer-sleep-lock -- $HOME/dotfiles/scripts/lock &
gnome-keyring-daemon --start --components=secrets &
nm-applet &
batsignal -b -n BAT0,BAT1 -w 20 -c 10 -d 5 -D "$HOME/dotfiles/scripts/battery-shutdown"
exec dwm
