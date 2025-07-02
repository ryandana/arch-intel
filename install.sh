#!/bin/bash

# Arch Linux Developer Setup Script
# Post-minimal installation script for development environment
# Supports Intel Alder Lake with Iris Xe graphics
# Author: Custom setup for development workflow

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

log "Starting Arch Linux Developer Environment Setup"

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
    nano \
    btop \
    fastfetch \
    tree \
    rsync \
    man-db \
    cava \
    man-pages

# ============================================================================
# INTEL HARDWARE SUPPORT (Alder Lake + Iris Xe)
# ============================================================================

log "Installing Intel CPU and GPU support for Alder Lake..."

# Intel microcode for CPU updates
sudo pacman -S --needed --noconfirm intel-ucode

# Intel graphics drivers and compute runtime (Latest packages for Alder Lake)
sudo pacman -S --needed --noconfirm \
    mesa \
    lib32-mesa \
    vulkan-intel \
    lib32-vulkan-intel \
    intel-media-driver \
    libva-intel-driver \
    libva-utils \
    intel-gpu-tools \
    xf86-video-intel

# Intel compute runtime for OpenCL
sudo pacman -S --needed --noconfirm intel-compute-runtime

# Intel VPL (Video Processing Library) GPU RT
sudo pacman -S --needed --noconfirm \
    intel-media-sdk \
    vpl-gpu-rt

# Network tools and compatibility libraries
log "Installing network tools and compatibility libraries..."
sudo pacman -S --needed --noconfirm \
    networkmanager \
    network-manager-applet \
    wireless_tools \
    wpa_supplicant \
    netctl \
    dhcpcd \
    libxcrypt-compat

# Enable NetworkManager
sudo systemctl enable NetworkManager

# ============================================================================
# AUR HELPER INSTALLATION (PARU)
# ============================================================================

log "Installing Paru AUR helper..."
if ! command -v paru &> /dev/null; then
    cd /tmp
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
    cd ~
    rm -rf /tmp/paru
    log "Paru installed successfully"
else
    log "Paru already installed"
fi

# ============================================================================
# DESKTOP ENVIRONMENT SELECTION
# ============================================================================

echo ""
echo "Select Desktop Environment:"
echo "1) GNOME (full group)"
echo "2) KDE Plasma (full group)"
echo "3) Cinnamon (full experience)"
echo -n "Enter your choice (1-3): "
read de_choice

case $de_choice in
    1)
        log "Installing GNOME (full group)..."
        sudo pacman -S --needed --noconfirm \
            gnome \
            gnome-extra \
            power-profiles-daemon
        
        # Enable GDM
        sudo systemctl enable gdm
        log "GNOME installed successfully"
        ;;
    2)
        log "Installing KDE Plasma (full group)..."
        sudo pacman -S --needed --noconfirm \
            plasma \
            kde-applications \
            power-profiles-daemon
        
        # Enable SDDM
        sudo systemctl enable sddm
        log "KDE Plasma installed successfully"
        ;;
    3)
        log "Installing Cinnamon (full group)..."
        sudo pacman -S --needed --noconfirm \
            cinnamon \
            cinnamon-translations \
            lightdm \
            lightdm-gtk-greeter \
            power-profiles-daemon \
            xdg-desktop-portal-xapp \
            nemo-fileroller \
            file-roller \
            gnome-screenshot \
            gnome-calculator \
            gedit
        
        # Enable LightDM
        sudo systemctl enable lightdm
        log "Cinnamon installed successfully"
        ;;
    *)
        error "Invalid choice. Please run the script again and select 1, 2, or 3."
        ;;
esac

# Enable power-profiles-daemon
sudo systemctl enable power-profiles-daemon

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

# Docker for Laravel Sail
log "Installing Docker..."
sudo pacman -S --needed --noconfirm \
    docker \
    docker-compose

# Enable Docker service
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Docker Desktop (optional)
echo ""
echo -n "Do you want to install Docker Desktop? (y/N): "
read install_docker_desktop
if [[ $install_docker_desktop =~ ^[Yy]$ ]]; then
    log "Installing Docker Desktop..."
    paru -S --needed --noconfirm docker-desktop
fi

# ============================================================================
# PRODUCTIVITY SOFTWARE
# ============================================================================

log "Installing OnlyOffice with Microsoft fonts..."
paru -S --needed --noconfirm onlyoffice-bin

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

# Install Zsh plugins
log "Installing Zsh plugins..."

# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# you-should-use
git clone https://github.com/MichaelAquilina/zsh-you-should-use.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/you-should-use

# Install bat for zsh-bat plugin
sudo pacman -S --needed --noconfirm bat

# Configure .zshrc with specified plugins
cat > ~/.zshrc << 'EOF'
# Oh My Zsh configuration
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

# Plugins configuration
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    you-should-use
    zsh-bat
    nvm
    docker
    python
    archlinux
)

source $ZSH/oh-my-zsh.sh

# NVM configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Custom aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias bat='batcat'

# Laravel Sail alias
alias sail='[ -f sail ] && bash sail || bash vendor/bin/sail'
EOF

# Change default shell to zsh
chsh -s $(which zsh)

# ============================================================================
# FLATPAK SUPPORT
# ============================================================================

log "Installing Flatpak support..."
sudo pacman -S --needed --noconfirm flatpak

# Add Flathub repository
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# ============================================================================
# MULTIMEDIA PACKAGES SELECTION
# ============================================================================

echo ""
echo "Select Multimedia Packages to Install:"
echo "1) GIMP (Image Editor)"
echo "2) Inkscape (Vector Graphics)"
echo "3) Kdenlive (Video Editor)"
echo "4) OBS Studio (Streaming/Recording)"
echo "5) Blender (3D Creation)"
echo "6) Audacity (Audio Editor)"
echo "7) VLC Media Player"
echo "8) Krita (Digital Painting)"
echo "9) All multimedia packages"
echo "10) Skip multimedia packages"
echo ""
echo "Enter your choices separated by spaces (e.g., 1 3 4 7): "
read -a multimedia_choices

multimedia_packages=()

for choice in "${multimedia_choices[@]}"; do
    case $choice in
        1)
            multimedia_packages+=(gimp)
            ;;
        2)
            multimedia_packages+=(inkscape)
            ;;
        3)
            multimedia_packages+=(kdenlive)
            ;;
        4)
            multimedia_packages+=(obs-studio)
            ;;
        5)
            multimedia_packages+=(blender)
            ;;
        6)
            multimedia_packages+=(audacity)
            ;;
        7)
            multimedia_packages+=(vlc)
            ;;
        8)
            multimedia_packages+=(krita)
            ;;
        9)
            multimedia_packages+=(gimp inkscape kdenlive obs-studio blender audacity vlc krita)
            break
            ;;
        10)
            log "Skipping multimedia packages..."
            multimedia_packages=()
            break
            ;;
    esac
done

if [ ${#multimedia_packages[@]} -gt 0 ]; then
    log "Installing selected multimedia packages: ${multimedia_packages[*]}"
    sudo pacman -S --needed --noconfirm "${multimedia_packages[@]}"
fi

# ============================================================================
# GAMING PACKAGES (OPTIONAL)
# ============================================================================

echo ""
echo -n "Do you want to install gaming packages? (y/N): "
read install_gaming

if [[ $install_gaming =~ ^[Yy]$ ]]; then
    log "Installing gaming packages..."

    # Wine and dependencies
    sudo pacman -S --needed --noconfirm \
        wine \
        wine-mono \
        wine-gecko \
        winetricks \
        lib32-libpulse \
        lib32-alsa-plugins \
        lib32-libxml2 \
        lib32-mpg123 \
        lib32-lcms2 \
        lib32-giflib \
        lib32-libpng \
        lib32-gnutls \
        lib32-freetype2

    # Gaming utilities
    sudo pacman -S --needed --noconfirm \
        gamemode \
        lib32-gamemode \
        gamescope \
        mangohud \
        lib32-mangohud

    # Install gaming tools from AUR
    log "Installing gaming tools from AUR..."
    paru -S --needed --noconfirm \
        protontricks \
        goverlay \
        heroic-games-launcher-bin

    # Steam
    sudo pacman -S --needed --noconfirm steam
    
    log "Gaming packages installed successfully"
else
    log "Skipping gaming packages installation"
fi

# ============================================================================
# FINAL SYSTEM CONFIGURATION
# ============================================================================

log "Performing final system configuration..."

# Update font cache
fc-cache -fv

# Update desktop database
update-desktop-database ~/.local/share/applications/

# Update mime database
update-mime-database ~/.local/share/mime/

# Generate user directories
xdg-user-dirs-update

# ============================================================================
# COMPLETION MESSAGE
# ============================================================================

echo ""
echo "============================================================================"
log "Arch Linux Developer Environment Setup Complete!"
echo "============================================================================"
echo ""
echo "Installed components:"
echo "  ✓ Intel Alder Lake CPU/GPU support with latest drivers and compute runtime"
echo "  ✓ Selected Desktop Environment (full experience)"
echo "  ✓ Development tools: VS Code, Node.js (via NVM), PHP, Composer"
echo "  ✓ Docker for Laravel Sail development"
echo "  ✓ OnlyOffice with Microsoft fonts"
echo "  ✓ Selected multimedia applications"
echo "  ✓ Zsh with Oh-My-Zsh and configured plugins"
echo "  ✓ Flatpak support"
if [[ $install_gaming =~ ^[Yy]$ ]]; then
echo "  ✓ Gaming packages: Wine, Steam, Heroic, MangoHUD, GameScope"
fi
echo ""
echo "Next steps:"
echo "  1. Reboot your system: sudo reboot"
echo "  2. Log into your desktop environment"
echo "  3. Your shell is now Zsh with Oh-My-Zsh"
echo "  4. Docker group membership will be active after reboot"
echo "  5. Use 'nvm list' to see installed Node.js versions"
echo ""
warning "Please reboot your system to ensure all services start correctly!"
echo "============================================================================"