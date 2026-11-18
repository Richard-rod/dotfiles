# dotfiles

Arch Linux + [dwm](https://dwm.suckless.org/) setup for a ThinkPad T480, forked from
[ChrisTitusTech/dwm-titus](https://github.com/ChrisTitusTech/dwm-titus). This repo holds
the dwm and slstatus source, the config files, and an `install.sh` that sets up everything
on top of a fresh Arch install.

Keybindings: [docs/keybindings.md](docs/keybindings.md)

## Setup

### 1. Base install (from the Arch live ISO)

1. Boot the Arch live ISO and get online.
2. Run `curl -fsSL https://christitus.com/linux | sh`
   (add `--size-bypass` if your terminal is too small for the menu).
3. Choose **System Setup > Arch Linux > Arch Server Setup**.
4. Follow the prompts on screen.
5. Reboot when it finishes and remove the USB stick.

> **Warning:** the disk list can include the USB stick, and choosing a disk erases it
> with no second confirmation.

The script sets up linux-lts, GRUB, CPU microcode, NetworkManager, a user with `sudo`
(wheel) and a locked root account, and no swap on machines with 8 GB RAM or more.
Reviewed against Linutil release 2026.11.14; re-read the Arch Server Setup script if the
stable release changes.

### 2. First boot

Log in on the text console. If there is no network, run `nmtui`.

### 3. Clone and install

The repo must live at exactly `~/dotfiles`: the lock script, wallpaper and power menu use
that path, and `install.sh` refuses to run anywhere else.

```sh
git clone -b Clean-upv1 https://github.com/Richard-rod/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

(Drop `-b Clean-upv1` once that branch is merged into `main`.)

Do not run it as root. It asks for your sudo password once, the AUR builds take a few
minutes, and it is safe to re-run.

### 4. Reboot and log in

Reboot, then log in on tty1. dwm starts automatically from `.bashrc`.

## First-login checklist

- **Lock:** press `Super+Ctrl+L`, then enter your password to unlock.
- **Brightness:** the brightness keys change the screen brightness.
- **Mic key:** it toggles microphone mute.
- **Screenshot:** `Print` opens the Flameshot selector and copies to the clipboard.
- **Wi-Fi:** the nm-applet icon appears in the tray; connect from it.
- **GitHub Desktop:** the first launch asks you to set up a keyring password.

## After editing

| You changed | Do this |
|---|---|
| `dwm/` (including `config.h`) | `cd ~/dotfiles/dwm && sudo make clean install`, then restart dwm (`Super+Shift+Q`, log in again) |
| `slstatus/` | `cd ~/dotfiles/slstatus && sudo make clean install`, then restart dwm |
| `config/<folder>` or `config/starship.toml` | Copy it to `~/.config/`, then reopen the app |
| `home/` dotfiles | Copy to `~/`, then open a new shell (or log in again for `.xinitrc`) |
| `xorg/30-touchpad.conf` | `sudo cp` it to `/etc/X11/xorg.conf.d/`, then log in again |
| `scripts/lock`, `scripts/battery` | Nothing; they are used in place |

Re-running `./install.sh` also redoes all the copies and rebuilds.

## Recovery

- **Stuck on the lock screen:** press `Ctrl+Alt+F2`, log in, and run `pkill i3lock`.
  Switch back with `Ctrl+Alt+F1`.
- **Won't boot or locked out:** the root account is locked, so recover from the live ISO.
  Boot it, run `lsblk` to find the root and EFI partitions, mount the root partition on
  `/mnt` and the EFI partition on `/mnt/boot`, then run `arch-chroot /mnt` and fix things
  (for example `passwd <user>`).

## T480 notes

- **Fn Lock:** the Fn Lock state decides whether the top-row keys act as
  media/brightness keys or as plain F1-F12. If the brightness, volume or mic keys do
  nothing, check Fn Lock first.
- **Lid:** the lid does not suspend the laptop (the lid magnet is missing). Suspend with
  `Super+Ctrl+Shift+S` or the power menu.
- **Brightness:** needs `acpilight` and membership in the `video` group. `install.sh`
  handles both, but log out and back in (or reboot) for the group to apply.

## Credits

[ChrisTitusTech/dwm-titus](https://github.com/ChrisTitusTech/dwm-titus) ·
[suckless dwm](https://dwm.suckless.org/) and [slstatus](https://tools.suckless.org/slstatus/) ·
[ChrisTitusTech/linutil](https://github.com/ChrisTitusTech/linutil)
