# Keybindings

Everything here comes from `dwm/config.h`. **Super** is the Windows key.

## dwm basics

- **Tags:** dwm has 5 tags (workspaces), shown in the bar and bound to `Super+1` to `Super+5`.
  A window can sit on one or more tags, and you can view several tags at once.
- **Master and stack:** in the tiling layout one window (the master) takes the left side
  (60% of the width), and the rest stack on the right. One master window by default.
- **Tile:** the default layout; windows never overlap.
- **Monocle:** every window fills the screen and you flip between them.
- **Floating:** windows overlap like a normal desktop and can be moved and resized freely.

## Apps

| Keys | What it does |
|---|---|
| `Super+R` | App launcher (rofi) |
| `Super+Enter` | Terminal (alacritty) |
| `Super+B` | Open the default web browser (`xdg-open https://`) |
| `Super+E` | File manager (Thunar) |
| `Super+Shift+W` | Set a random wallpaper from `~/dotfiles/wallpapers` |

## Screenshots

| Keys | What it does |
|---|---|
| `Super+P` | Full-screen screenshot, saved to `~/Pictures/Screenshots` |
| `Super+Shift+P` | Select an area, saved to `~/Pictures/Screenshots` |
| `Super+Ctrl+P` | Select an area, copied to the clipboard |
| `Print` | Select an area, copied to the clipboard |

## Brightness, volume, mic

| Keys | What it does |
|---|---|
| Brightness up / down | Change brightness by 5 (down stops at 1, never fully off) |
| Volume up / down | Change volume by 5% and unmute |
| Mute | Toggle speaker mute |
| Mic mute | Toggle microphone mute |

## Windows and focus

| Keys | What it does |
|---|---|
| `Super+J` / `Super+K` | Focus the next / previous window |
| `Super+Shift+J` / `Super+Shift+K` | Move the window down / up the stack |
| `Super+X` | Swap the focused window with the master |
| `Super+Q` | Close the window |
| `Super+M` | Toggle fullscreen |
| `Super+Shift+Y` | Toggle "fake" fullscreen (fills the window area, not the screen) |
| `Super+Shift+M` | Toggle floating for the window |
| `Super+Shift+B` | Show / hide the bar |

## Layout sizing

| Keys | What it does |
|---|---|
| `Super+H` / `Super+L` | Shrink / grow the master area |
| `Super+I` / `Super+D` | Add / remove a window in the master area |
| `Super+Shift+H` / `Super+Shift+L` | Make the focused window taller / shorter in its column |
| `Super+Shift+O` | Reset that window's height to normal |

## Layouts

| Keys | What it does |
|---|---|
| `Super+T` | Tile layout |
| `Super+F` | Floating layout |
| `Super+Space` | Swap between the current and the previous layout |

Monocle is defined in `config.h` but has no key or mouse binding, so it can't be
selected right now.

## Tags (workspaces)

| Keys | What it does |
|---|---|
| `Super+1` to `Super+5` | Go to that tag |
| `Super+Shift+1` to `5` | Move the window to that tag |
| `Super+Ctrl+1` to `5` | Also show that tag alongside the current one |
| `Super+Ctrl+Shift+1` to `5` | Also put the window on that tag |
| `Super+0` | Show all tags at once |
| `Super+Tab` | Go back to the previous tag |

## Monitors

| Keys | What it does |
|---|---|
| `Super+,` / `Super+.` | Focus the previous / next monitor |
| `Super+Shift+,` / `Super+Shift+.` | Send the window to the previous / next monitor |

## Session and power

| Keys | What it does |
|---|---|
| `Super+Ctrl+L` | Lock the screen |
| `Super+Ctrl+Q` | Power menu |
| `Super+Ctrl+Shift+S` | Suspend |
| `Super+Ctrl+Shift+R` | Reboot (no confirmation) |
| `Super+Shift+Q` | Quit dwm (back to the text console) |

## Mouse

| Action | What it does |
|---|---|
| `Super` + left-drag a window | Move it (or place it in the tiling order) |
| `Super` + right-drag a window | Resize it |
| Click a tag in the bar | Go to that tag |
| Right-click a tag | Show that tag alongside the current one |
| `Super` + click a tag | Move the focused window to that tag |
| `Super` + right-click a tag | Also put the window on that tag |
