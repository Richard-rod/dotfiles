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
4. Follow the prompts on screen. On this machine, choose **nouveau** at the NVIDIA
   prompt: the packaged NVIDIA driver no longer supports this GPU (Pascal).
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

The repo must live at exactly `~/dotfiles`: the lock script and power menu use
that path, and `install.sh` refuses to run anywhere else.

```sh
git clone https://github.com/Richard-rod/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

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

### Install drops back to the boot menu

If choosing Arch from the firmware boot menu returns to the menu after a few seconds on
a reinstall, a leftover firmware entry from a previous install may point at a partition
that no longer exists. From the live ISO:

1. Run `efibootmgr`, find the stale entry, and delete it with `efibootmgr -B -b <number>`.
2. Find the partitions with `lsblk -f`, then mount the root partition on `/mnt` and the
   EFI partition on `/mnt/boot`.
3. Run `arch-chroot /mnt`, then:
   - `grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch --recheck`
   - the same command with `--removable` instead of `--bootloader-id=Arch` (this adds a
     fallback copy)
   - `grub-mkconfig -o /boot/grub/grub.cfg`
4. Run `exit`, then `umount -R /mnt` and reboot.

## T480 notes

- **Fn Lock:** the Fn Lock state decides whether the top-row keys act as
  media/brightness keys or as plain F1-F12. If the brightness, volume or mic keys do
  nothing, check Fn Lock first.
- **Lid:** the lid does not suspend the laptop (the lid magnet is missing). Suspend with
  `Super+Ctrl+Shift+S` or the power menu.
- **Brightness:** needs `acpilight` and membership in the `video` group. `install.sh`
  handles both, but log out and back in (or reboot) for the group to apply.
- **First boot hangs (nouveau):** if the first boot after the base install hangs or
  crashes in the kernel log (nouveau), press `e` at the GRUB menu, add
  `module_blacklist=nouveau` to the end of the line starting with `linux`, press
  `Ctrl+X`, log in, and run `install.sh`, which makes the setting permanent.
- **Shutdown watchdog message:** the installer disables the Intel hardware watchdog
  modules to silence the "watchdog did not stop" message at shutdown. To undo, delete
  `/etc/modprobe.d/blacklist-watchdog.conf` and run `sudo mkinitcpio -P`.
- **nouveau blacklist:** the installer blacklists nouveau on this machine because it
  crashed at boot on kernel 6.18.64 at the time of writing. To retest later, press `e` at
  the GRUB menu, delete the parameter, and boot.

## Credits

[ChrisTitusTech/dwm-titus](https://github.com/ChrisTitusTech/dwm-titus) ·
[suckless dwm](https://dwm.suckless.org/) and [slstatus](https://tools.suckless.org/slstatus/) ·
[ChrisTitusTech/linutil](https://github.com/ChrisTitusTech/linutil)
