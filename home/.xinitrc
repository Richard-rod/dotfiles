picom &
xset s 300 5
xset -dpms
xss-lock --transfer-sleep-lock -- $HOME/dotfiles/scripts/lock &
exec dwm
