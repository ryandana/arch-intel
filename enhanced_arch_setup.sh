#!/bin/bash

# Enhanced Arch Linux Developer Setup Script
# Post-minimal installation script for clean development environment
# Supports Intel Alder Lake with Iris Xe graphics + Gaming Tools
# Author: Optimized setup for minimal desktop experience

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   error "This script should not be run as root"
fi

# Check if sudo is available
if ! command -v sudo &> /dev/null; then
    error "sudo is required but not installed"
fi

log "Starting Enhanced Arch Linux Developer Environment Setup"

# Request sudo password upfront and keep it alive
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# ============================================================================
# SYSTEM UPDATE AND ESSENTIAL PACKAGES
# ============================================================================

log "Updating system packages..."
sudo pacman -Syu --noconfirm

log "Installing essential base packages..."
sudo pacman -S --needed --noconfirm \
    base-devel \
    git \
    wget \
    curl \
    unzip \
    vim \
    neovim \
    nano \
    btop \
    fastfetch \
    tree \
    rsync \
    man-db \
    man-pages \
    bash-completion \
    net-tools \
    libxcrypt-compat \
    kitty \
    cava \
    imagemagick

# ============================================================================
# INTEL HARDWARE SUPPORT (Alder Lake + Iris Xe)
# ============================================================================

log "Installing Intel CPU and GPU support for Alder Lake..."

# Intel microcode and graphics drivers (minimal set)
sudo pacman -S --needed --noconfirm \
    intel-ucode \
    mesa \
    vulkan-intel \
    intel-media-driver \
    libva-intel-driver \
    libva-utils \
    intel-gpu-tools \
    intel-compute-runtime \
    vpl-gpu-rt

# Network tools
log "Installing network tools..."
sudo pacman -S --needed --noconfirm \
    networkmanager \
    network-manager-applet \
    wireless_tools \
    wpa_supplicant

# Enable NetworkManager
sudo systemctl enable NetworkManager

# ============================================================================
# AUR HELPER INSTALLATION (PARU)
# ============================================================================

log "Installing Paru AUR helper..."
if ! command -v paru &> /dev/null; then
    cd /tmp
    git clone https://aur.archlinux.org/paru-bin.git
    cd paru-bin
    makepkg -si --noconfirm
    cd ~
    rm -rf /tmp/paru-bin
    log "Paru installed successfully"
else
    log "Paru already installed"
fi

# Power management
sudo pacman -S --needed --noconfirm power-profiles-daemon
sudo systemctl enable power-profiles-daemon

# ============================================================================
# GAMING TOOLS AND STEAM
# ============================================================================

log "Installing gaming tools and Steam..."

# Enable multilib repository for 32-bit support
sudo sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf

# Update package database after enabling multilib
sudo pacman -Sy

# Install Steam and gaming tools
sudo pacman -S --needed --noconfirm \
    steam \
    gamemode \
    lib32-gamemode \
    mangohud \
    lib32-mangohud \
    goverlay

# Install ProtonPlus from AUR
paru -S --needed --noconfirm protonplus

# ============================================================================
# FLATPAK SUPPORT (Install early for GNOME extensions)
# ============================================================================

log "Installing Flatpak support..."
sudo pacman -S --needed --noconfirm flatpak

# Add Flathub repository
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# ============================================================================
# DEVELOPMENT TOOLS
# ============================================================================

log "Installing development tools..."

# Visual Studio Code
log "Installing Visual Studio Code..."
paru -S --needed --noconfirm visual-studio-code-bin

# Node.js via NVM
log "Installing NVM for Node.js management..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Source NVM for current session
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Install latest LTS Node.js
nvm install --lts
nvm use --lts
nvm alias default lts/*

# PHP and Composer for Laravel development
log "Installing PHP and Composer..."
sudo pacman -S --needed --noconfirm \
    php \
    php-intl \
    php-gd \
    php-sqlite \
    composer

# Docker for Laravel Sail (fixed conflict)
log "Installing Docker..."
sudo pacman -S --needed --noconfirm docker docker-compose docker-buildx

# Enable Docker service and add user to docker group
sudo systemctl enable docker
sudo usermod -aG docker $USER

log "Docker installed successfully (Docker Desktop can be installed separately if needed)"

# Essential fonts
sudo pacman -S --needed --noconfirm \
    ttf-liberation \
    ttf-dejavu \
    noto-fonts \
    noto-fonts-emoji \
    noto-fonts-cjk \
    noto-fonts-extra \
    ttf-jetbrains-mono \
    ttf-firacode-nerd

# Microsoft fonts for better compatibility
paru -S --needed --noconfirm ttf-ms-fonts

# ============================================================================
# SHELL SETUP (ZSH + OH-MY-ZSH)
# ============================================================================

log "Installing and configuring Zsh with Oh-My-Zsh..."

# Install Zsh
sudo pacman -S --needed --noconfirm zsh

# Install Oh-My-Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install essential Zsh plugins
log "Installing essential Zsh plugins..."

# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# you-should-use
git clone https://github.com/MichaelAquilina/zsh-you-should-use.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/you-should-use

# Install nord-extended theme
log "Installing nord-extended theme..."
git clone https://github.com/fxbrit/nord-extended.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/nord-extended

# Configure .zshrc with essential plugins only
cat > ~/.zshrc << 'EOF'
# Oh My Zsh configuration
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="nord-extended/nord-extended"

# Essential plugins only
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    nvm
    docker
    archlinux
    you-should-use
)

source $ZSH/oh-my-zsh.sh

# NVM configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Essential aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'

# Arch Linux package management aliases
alias install='sudo pacman -Sy'
alias update='sudo pacman -Syu'
alias remove='sudo pacman -Rns'
alias search='pacman -Ss'
alias info='pacman -Si'
alias orphan='sudo pacman -Rns $(pacman -Qtdq)'
alias cleanup='sudo pacman -Sc && paru -Sc'

# Laravel Sail alias
alias sail='[ -f sail ] && bash sail || bash vendor/bin/sail'

EOF

# Change default shell to zsh
chsh -s $(which zsh)

# ============================================================================
# CLEANUP AND OPTIMIZATION
# ============================================================================

log "Cleaning up system..."

# Remove orphaned packages
sudo pacman -Rns $(pacman -Qtdq) --noconfirm 2>/dev/null || true

# Clear package cache
sudo pacman -Sc --noconfirm

# Clear AUR cache
paru -Sc --noconfirm

# Update font cache
fc-cache -fv

# ============================================================================
# COMPLETION MESSAGE
# ============================================================================

echo ""
echo "============================================================================"
log "Enhanced Arch Linux Developer Environment Setup Complete!"
echo "============================================================================"
echo ""
echo "Installed components:"
echo "  ✓ Intel Alder Lake CPU/GPU support (minimal drivers)"
echo "  ✓ Gaming tools: Steam, GameMode, MangoHUD, GOverlay, ProtonPlus"
echo "  ✓ Development tools: VS Code, Node.js (NVM), PHP, Composer, Docker"
echo "  ✓ Terminal tools: Neovim, Kitty, Cava, ImageMagick"
echo "  ✓ Zsh with Oh-My-Zsh, nord-extended theme, and essential plugins"
echo "  ✓ Flatpak support"
echo "  ✓ System optimized and cleaned"
echo ""
echo "Available aliases:"
echo "  • install <package>  - Install package with pacman -Sy"
echo "  • update            - Update system with pacman -Syu"
echo "  • remove <package>  - Remove package with dependencies"
echo "  • orphan           - Remove orphaned packages"
echo "  • cleanup          - Clear package caches"
echo ""
echo "Next steps:"
echo "  1. Reboot your system to complete setup"
echo "  2. Log into your minimal desktop environment"
echo "  3. Your shell is now Zsh with nord-extended theme"
echo "  4. Docker group membership will be active after reboot"
echo "  5. Use 'nvm list' to see installed Node.js versions"
echo "  6. Steam and gaming tools are ready to use"
echo ""

# Ask user if they want to reboot
echo -n "Do you want to reboot now? (y/n): "
read -r answer
if [[ $answer =~ ^[Yy]$ ]]; then
    log "Rebooting system..."
    sudo reboot
else
    log "Setup complete! Please reboot manually when ready."
fi

echo "============================================================================"