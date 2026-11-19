#!/usr/bin/env bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────
info()    { echo "[INFO]  $*"; }
success() { echo "[OK]    $*"; }
error()   { echo "[ERROR] $*" >&2; exit 1; }

[[ "$EUID" -eq 0 ]] && error "Do not run this script as root. sudo will be used where needed."

if [[ "$DOTFILES_DIR" != "$HOME/dotfiles" ]]; then
    error "Repo is at $DOTFILES_DIR but must be at ~/dotfiles. The wallpaper, lock script and power menu expect the repo at ~/dotfiles."
fi

# Keep sudo credentials alive for the whole run
sudo -v
while kill -0 "$$" 2>/dev/null; do sudo -n true; sleep 50; done &
SUDO_KEEPALIVE_PID=$!
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null' EXIT

# ─────────────────────────────────────────────
# 0. System update
# ─────────────────────────────────────────────
info "Updating system..."
sudo pacman -Syu --noconfirm
success "System updated"

# ─────────────────────────────────────────────
# 1. Install yay (AUR helper)
# ─────────────────────────────────────────────
if ! command -v yay &>/dev/null; then
    info "Installing yay..."
    sudo pacman -S --needed --noconfirm git base-devel
    rm -rf /tmp/yay
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
    rm -rf /tmp/yay
    success "yay installed"
else
    success "yay already installed"
fi

# ─────────────────────────────────────────────
# 2. Install packages
# ─────────────────────────────────────────────
PACMAN_PACKAGES=(
    # Build dependencies
    base-devel libx11 libxft libxinerama libxcb xcb-util freetype2 fontconfig imlib2

    # Xorg
    xorg-server xorg-xinit xorg-xrandr xorg-xsetroot xorg-xset xorg-xprop
    xf86-input-libinput mesa

    # Window manager extras
    picom rofi dunst feh flameshot

    # Terminal & shell
    alacritty

    # File manager
    thunar gvfs tumbler thunar-archive-plugin

    # Audio
    pipewire pipewire-pulse alsa-utils pavucontrol

    # Network
    networkmanager network-manager-applet

    # Utilities
    fastfetch unzip strace unrar 7zip xarchiver xclip libnotify gnome-keyring xdg-user-dirs
    firefox neovim zoxide starship
    xdg-desktop-portal-gtk dex xss-lock mate-polkit
    trash-cli bat tree
    bash-completion fzf

    # Fonts
    noto-fonts-emoji
)

AUR_PACKAGES=(
    ttf-meslo-nerd acpilight i3lock-color github-desktop-bin
)

info "Installing pacman packages..."
sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"
success "Pacman packages installed"

info "Installing AUR packages..."
yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"
success "AUR packages installed"

# ─────────────────────────────────────────────
# 3. Copy config files → ~/.config/
# ─────────────────────────────────────────────
info "Copying config files..."

CONFIG_DIRS=(alacritty rofi flameshot fastfetch)
for dir in "${CONFIG_DIRS[@]}"; do
    if [[ -d "$DOTFILES_DIR/config/$dir" ]]; then
        mkdir -p "$HOME/.config/$dir"
        cp -r "$DOTFILES_DIR/config/$dir/." "$HOME/.config/$dir/"
        success "Copied config/$dir → ~/.config/$dir"
    fi
done

if [[ -f "$DOTFILES_DIR/config/starship.toml" ]]; then
    cp "$DOTFILES_DIR/config/starship.toml" "$HOME/.config/starship.toml"
    success "Copied config/starship.toml → ~/.config/starship.toml"
fi

# ─────────────────────────────────────────────
# 4. Copy home files → ~/
# ─────────────────────────────────────────────
info "Copying home files..."

HOME_FILES=(.xinitrc .bash_profile .bashrc)
for file in "${HOME_FILES[@]}"; do
    if [[ -f "$DOTFILES_DIR/home/$file" ]]; then
        cp "$DOTFILES_DIR/home/$file" "$HOME/$file"
        success "Copied home/$file → ~/$file"
    else
        info "Skipping $file (not found in dotfiles/home/)"
    fi
done

# ─────────────────────────────────────────────
# 5. Copy xorg config → /etc/X11/xorg.conf.d/
# ─────────────────────────────────────────────
info "Copying xorg config..."
sudo mkdir -p /etc/X11/xorg.conf.d
sudo cp "$DOTFILES_DIR/xorg/30-touchpad.conf" /etc/X11/xorg.conf.d/30-touchpad.conf
success "Copied xorg/30-touchpad.conf → /etc/X11/xorg.conf.d/"

# ─────────────────────────────────────────────
# 5b. Blacklist Intel hardware watchdog modules
# ─────────────────────────────────────────────
# Silences the "watchdog did not stop" message at shutdown. The boot image
# includes modprobe settings, so it is rebuilt when the file changes.
WDT_SRC="$DOTFILES_DIR/system/modprobe.d/blacklist-watchdog.conf"
WDT_DST="/etc/modprobe.d/blacklist-watchdog.conf"

if ! cmp -s "$WDT_SRC" "$WDT_DST"; then
    info "Installing watchdog blacklist..."
    sudo cp "$WDT_SRC" "$WDT_DST"
    info "Rebuilding initramfs (mkinitcpio -P)..."
    sudo mkinitcpio -P
    success "Watchdog modules blacklisted"
else
    info "Watchdog blacklist already in place, skipping mkinitcpio"
fi

# ─────────────────────────────────────────────
# 6. Compile and install dwm
# ─────────────────────────────────────────────
info "Compiling dwm..."
(cd "$DOTFILES_DIR/dwm" && sudo make clean install)
success "dwm installed"

# ─────────────────────────────────────────────
# 7. Compile and install slstatus
# ─────────────────────────────────────────────
info "Compiling slstatus..."
(cd "$DOTFILES_DIR/slstatus" && sudo make clean install)
success "slstatus installed"

# ─────────────────────────────────────────────
# 8. Misc setup
# ─────────────────────────────────────────────
info "Setting up XDG user directories..."
xdg-user-dirs-update
success "XDG directories created"

info "Creating ~/Pictures/Screenshots..."
mkdir -p "$HOME/Pictures/Screenshots"
success "Screenshots directory ready"

info "Enabling NetworkManager..."
sudo systemctl enable --now NetworkManager
success "NetworkManager enabled"

info "Enabling periodic TRIM (fstrim.timer)..."
if systemctl is-enabled --quiet fstrim.timer; then
    success "fstrim.timer already enabled"
else
    sudo systemctl enable --now fstrim.timer
    success "fstrim.timer enabled"
fi

info "Adding $USER to the video group (needed for xbacklight)..."
if id -nG "$USER" | tr ' ' '\n' | grep -qx video; then
    success "$USER already in video group"
else
    sudo usermod -aG video "$USER"
    success "Added $USER to video group"
fi

# ─────────────────────────────────────────────
# 9. Machine-specific fixes
# ─────────────────────────────────────────────
# nouveau crashes in udev-worker at boot on the T480 (Intel + NVIDIA MX150)
# with kernel 6.18.64-lts and hangs the session and reboot.
GRUB_DEFAULT_FILE="/etc/default/grub"
NOUVEAU_RE='module_blacklist=([^" ]*,)?nouveau([", ]|$)'

if grep -qs "T480" /sys/class/dmi/id/product_version && grep -qs '0x10de' /sys/bus/pci/devices/*/vendor; then
    info "T480 with NVIDIA GPU detected, blacklisting nouveau..."
    [[ -f "$GRUB_DEFAULT_FILE" ]] || error "$GRUB_DEFAULT_FILE not found, cannot blacklist nouveau."
    grep -q '^GRUB_CMDLINE_LINUX_DEFAULT="' "$GRUB_DEFAULT_FILE" \
        || error "GRUB_CMDLINE_LINUX_DEFAULT=\"...\" line not found in $GRUB_DEFAULT_FILE."

    [[ -f "$GRUB_DEFAULT_FILE.bak" ]] || sudo cp "$GRUB_DEFAULT_FILE" "$GRUB_DEFAULT_FILE.bak"

    if grep '^GRUB_CMDLINE_LINUX_DEFAULT=' "$GRUB_DEFAULT_FILE" | grep -qE "$NOUVEAU_RE"; then
        success "nouveau already in module_blacklist"
    elif grep '^GRUB_CMDLINE_LINUX_DEFAULT=' "$GRUB_DEFAULT_FILE" | grep -q 'module_blacklist='; then
        sudo sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/module_blacklist=\([^" ]*\)/module_blacklist=\1,nouveau/' "$GRUB_DEFAULT_FILE"
        success "Appended nouveau to existing module_blacklist"
    else
        sudo sed -i -e '/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/"$/ module_blacklist=nouveau"/' \
                    -e '/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/=" module_blacklist/="module_blacklist/' "$GRUB_DEFAULT_FILE"
        success "Added module_blacklist=nouveau"
    fi

    info "Regenerating GRUB config..."
    sudo grub-mkconfig -o /boot/grub/grub.cfg

    grep '^GRUB_CMDLINE_LINUX_DEFAULT=' "$GRUB_DEFAULT_FILE" | grep -qE "$NOUVEAU_RE" \
        || error "module_blacklist=nouveau is missing from $GRUB_DEFAULT_FILE after editing."
    success "nouveau blacklisted"
else
    info "Not a T480 with an NVIDIA GPU, skipping machine-specific fixes"
fi

echo ""
echo "────────────────────────────────────────"
echo "  Install complete. Reboot, then log in on tty1 and dwm starts"
echo "  automatically."
echo "  (Group changes and the acpilight udev rule only apply to new sessions.)"
echo "────────────────────────────────────────"
