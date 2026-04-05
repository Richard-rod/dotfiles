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

# ─────────────────────────────────────────────
# 1. Install yay (AUR helper)
# ─────────────────────────────────────────────
if ! command -v yay &>/dev/null; then
    info "Installing yay..."
    sudo pacman -S --needed --noconfirm git base-devel
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
    xf86-input-libinput

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
    fastfetch unzip xclip libnotify gnome-keyring xdg-user-dirs
    firefox neovim zoxide starship
    xdg-desktop-portal-gtk dex

    # Fonts
    noto-fonts-emoji
)

AUR_PACKAGES=(
    ttf-meslo-nerd
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

info "Enabling NetworkManager..."
sudo systemctl enable --now NetworkManager
success "NetworkManager enabled"

echo ""
echo "────────────────────────────────────────"
echo "  Install complete. Run 'startx' to launch dwm."
echo "────────────────────────────────────────"
