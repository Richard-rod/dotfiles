picom &
xset s 300 5
xset -dpms
xss-lock --transfer-sleep-lock -- $HOME/dotfiles/scripts/lock &
nm-applet &
exec dwm
