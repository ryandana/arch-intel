#!/bin/bash

# Enhanced Minimal Arch Linux Developer Setup Script
# Post-minimal installation script for clean development environment
# Supports Intel Alder Lake with Iris Xe graphics
# Author: Optimized setup for minimal desktop experience with enhanced tooling

set -e  # Exit on any error

# Enhanced colors and styling
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Enhanced logging functions with better formatting
print_header() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE} $1${CYAN} ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

log() {
    echo -e "${GREEN}✓${NC} ${WHITE}[$(date +'%H:%M:%S')]${NC} $1"
}

warning() {
    echo -e "${YELLOW}⚠${NC} ${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} ${RED}[ERROR]${NC} $1"
    exit 1
}

info() {
    echo -e "${BLUE}ℹ${NC} ${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}🎉${NC} ${GREEN}$1${NC}"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   error "This script should not be run as root"
fi

# Check if sudo is available
if ! command -v sudo &> /dev/null; then
    error "sudo is required but not installed"
fi

# Welcome banner
clear
echo -e "${PURPLE}"
cat << "EOF"
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║                                                                           ║
    ║    ╔═╗┬─┐┌─┐┬ ┬  ╦  ┬┌┐┌┬ ┬─┐ ┬  ╔═╗┌─┐┌┬┐┬ ┬┌─┐                        ║
    ║    ╠═╣├┬┘│  ├─┤  ║  ││││││ │┌┴┬┘  ╚═╗├┤  │ │ │├─┘                        ║
    ║    ╩ ╩┴└─└─┘┴ ┴  ╩═╝┴┘└┘└─┘┴ └─  ╚═╝└─┘ ┴ └─┘┴                          ║
    ║                                                                           ║
    ║                    Enhanced Developer Environment                         ║
    ║                                                                           ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

print_header "Starting Enhanced Arch Linux Developer Environment Setup"

# Request sudo password upfront and keep it alive
info "Requesting sudo privileges..."
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# ============================================================================
# SYSTEM UPDATE AND ESSENTIAL PACKAGES
# ============================================================================

print_header "SYSTEM UPDATE AND ESSENTIAL PACKAGES"

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
    man-pages \
    bash-completion \
    net-tools \
    libxcrypt-compat \
    yt-dlp \
    zenity \
    cava \
    amberol

success "Essential packages installed successfully"

# ============================================================================
# INTEL HARDWARE SUPPORT (Alder Lake + Iris Xe)
# ============================================================================

print_header "INTEL HARDWARE SUPPORT (ALDER LAKE + IRIS XE)"

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

# Power management
log "Installing power management tools..."
sudo pacman -S --needed --noconfirm power-profiles-daemon
sudo systemctl enable power-profiles-daemon

success "Intel hardware support configured"

# ============================================================================
# AUR HELPER INSTALLATION (PARU)
# ============================================================================

print_header "AUR HELPER INSTALLATION"

log "Installing Paru AUR helper..."
if ! command -v paru &> /dev/null; then
    cd /tmp
    git clone https://aur.archlinux.org/paru-bin.git
    cd paru-bin
    makepkg -si --noconfirm
    cd ~
    rm -rf /tmp/paru-bin
    success "Paru installed successfully"
else
    log "Paru already installed"
fi

# ============================================================================
# FLATPAK SUPPORT
# ============================================================================

print_header "FLATPAK SUPPORT"

log "Installing Flatpak support..."
sudo pacman -S --needed --noconfirm flatpak

# Add Flathub repository
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

success "Flatpak support configured"

# ============================================================================
# DEVELOPMENT TOOLS
# ============================================================================

print_header "DEVELOPMENT TOOLS"

# Visual Studio Code
log "Installing Visual Studio Code..."
paru -S --needed --noconfirm visual-studio-code-bin

# Google Chrome
log "Installing Google Chrome..."
paru -S --needed --noconfirm google-chrome

# Node.js via NVM
log "Installing NVM for Node.js management..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Source NVM for current session
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Install latest LTS Node.js
log "Installing Node.js LTS..."
nvm install --lts
nvm use --lts
nvm alias default lts/*

# Python via Pyenv
log "Installing Pyenv for Python management..."
curl https://pyenv.run | bash

# Add pyenv to PATH for current session
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Install dependencies for Python compilation
sudo pacman -S --needed --noconfirm \
    make \
    openssl \
    zlib \
    bzip2 \
    readline \
    sqlite \
    llvm \
    ncurses \
    xz \
    tk \
    libxml2 \
    libxslt \
    libffi

log "Pyenv installed - use 'pyenv install <version>' to install Python versions"

# Docker for Laravel Sail
log "Installing Docker..."
sudo pacman -S --needed --noconfirm \
    docker \
    docker-compose \
    docker-buildx

# Enable Docker service and add user to docker group
sudo systemctl enable docker
sudo usermod -aG docker $USER

success "Development tools installed successfully"

# ============================================================================
# FONTS INSTALLATION
# ============================================================================

print_header "FONTS INSTALLATION"

log "Installing essential fonts..."
sudo pacman -S --needed --noconfirm \
    ttf-liberation \
    ttf-dejavu \
    noto-fonts \
    noto-fonts-emoji \
    noto-fonts-cjk \
    noto-fonts-extra \
    ttf-jetbrains-mono-nerd

# Microsoft fonts for better compatibility
log "Installing Microsoft fonts..."
paru -S --needed --noconfirm ttf-ms-fonts

success "Font installation completed"

# ============================================================================
# SHELL SETUP (ZSH + OH-MY-ZSH + STARSHIP)
# ============================================================================

print_header "SHELL CONFIGURATION"

log "Installing Zsh..."
sudo pacman -S --needed --noconfirm zsh

# Install Oh-My-Zsh
log "Installing Oh-My-Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Starship prompt
log "Installing Starship prompt..."
curl -sS https://starship.rs/install.sh | sh -s -- --yes

# Install essential Zsh plugins
log "Installing essential Zsh plugins..."

# zsh-autosuggestions
if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

# zsh-syntax-highlighting
if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

# you-should-use
if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/you-should-use" ]; then
    git clone https://github.com/MichaelAquilina/zsh-you-should-use.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/you-should-use
fi

# Configure Starship with Catppuccin theme
log "Configuring Starship with Catppuccin theme..."
mkdir -p ~/.config
cat > ~/.config/starship.toml << 'EOF'
# Catppuccin Mocha theme for Starship
format = """
[](#cba6f7)\
$os\
$username\
[](bg:#89b4fa fg:#cba6f7)\
$directory\
[](fg:#89b4fa bg:#94e2d5)\
$git_branch\
$git_status\
[](fg:#94e2d5 bg:#fab387)\
$c\
$elixir\
$elm\
$golang\
$gradle\
$haskell\
$java\
$julia\
$nodejs\
$nim\
$rust\
$scala\
$python\
[](fg:#fab387 bg:#f38ba8)\
$docker_context\
[](fg:#f38ba8 bg:#a6e3a1)\
$time\
[ ](fg:#a6e3a1)\
"""

# Disable the blank line at the start of the prompt
add_newline = false

# You can also replace your username with a neat symbol like   or disable it
[username]
show_always = true
style_user = "bg:#cba6f7"
style_root = "bg:#cba6f7"
format = '[$user ]($style)'
disabled = false

# An alternative to the username module which displays a symbol that
# represents the current operating system
[os]
style = "bg:#cba6f7"
disabled = true # Disabled by default

[directory]
style = "bg:#89b4fa"
format = "[ $path ]($style)"
truncation_length = 3
truncation_symbol = "…/"

# Here is how you can shorten some long paths by text replacement
# similar to mapped_locations in Oh My Posh:
[directory.substitutions]
"Documents" = "󰈙 "
"Downloads" = " "
"Music" = " "
"Pictures" = " "

[c]
symbol = " "
style = "bg:#fab387"
format = '[ $symbol ($version) ]($style)'

[docker_context]
symbol = " "
style = "bg:#f38ba8"
format = '[ $symbol $context ]($style) $path'

[elixir]
symbol = " "
style = "bg:#fab387"
format = '[ $symbol ($version) ]($style)'

[elm]
symbol = " "
style = "bg:#fab387"
format = '[ $symbol ($version) ]($style)'

[git_branch]
symbol = ""
style = "bg:#94e2d5"
format = '[ $symbol $branch ]($style)'

[git_status]
style = "bg:#94e2d5"
format = '[$all_status$ahead_behind ]($style)'

[golang]
symbol = " "
style = "bg:#fab387"
format = '[ $symbol ($version) ]($style)'

[gradle]
style = "bg:#fab387"
format = '[ $symbol ($version) ]($style)'

[haskell]
symbol = " "
style = "bg:#fab387"
format = '[ $symbol ($version) ]($style)'

[java]
symbol = " "
style = "bg:#fab387"
format = '[ $symbol ($version) ]($style)'

[julia]
symbol = " "
style = "bg:#fab387"
format = '[ $symbol ($version) ]($style)'

[nodejs]
symbol = ""
style = "bg:#fab387"
format = '[ $symbol ($version) ]($style)'

[nim]
symbol = "󰆥 "
style = "bg:#fab387"
format = '[ $symbol ($version) ]($style)'

[python]
symbol = " "
style = "bg:#fab387"
format = '[ $symbol ($version) ]($style)'

[rust]
symbol = ""
style = "bg:#fab387"
format = '[ $symbol ($version) ]($style)'

[scala]
symbol = " "
style = "bg:#fab387"
format = '[ $symbol ($version) ]($style)'

[time]
disabled = false
time_format = "%R" # Hour:Minute Format
style = "bg:#a6e3a1"
format = '[ ♥ $time ]($style)'
EOF

# Configure .zshrc with enhanced setup
log "Configuring enhanced .zshrc..."
cat > ~/.zshrc << 'EOF'
# Oh My Zsh configuration
export ZSH="$HOME/.oh-my-zsh"

# Use Starship instead of Oh My Zsh themes
ZSH_THEME=""

# Essential plugins
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    nvm
    docker
    docker-compose
    archlinux
    you-should-use
    pyenv
)

source $ZSH/oh-my-zsh.sh

# Initialize Starship prompt
eval "$(starship init zsh)"

# NVM configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Essential aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias cat='bat --style=plain'
alias ls='exa --icons'

# Pacman aliases
alias pacup='sudo pacman -Syu'                    # Update system
alias pacin='sudo pacman -S'                      # Install package
alias pacrem='sudo pacman -Rns'                   # Remove package with dependencies
alias pacsearch='pacman -Ss'                      # Search packages
alias pacinfo='pacman -Si'                        # Package info
alias paclist='pacman -Q'                         # List installed packages
alias pacorphan='sudo pacman -Rns $(pacman -Qtdq)' # Remove orphaned packages
alias pacclean='sudo pacman -Sc'                  # Clean package cache
alias pacupgrade='sudo pacman -Syu && paru -Sua'  # Full system upgrade (official + AUR)

# Laravel Sail alias
alias sail='[ -f sail ] && bash sail || bash vendor/bin/sail'

# Docker aliases
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias di='docker images'

# Python aliases
alias python='python3'
alias pip='pip3'

# Show fastfetch on terminal startup
fastfetch

EOF

# Install additional shell tools
log "Installing additional shell tools..."
sudo pacman -S --needed --noconfirm bat exa

# Change default shell to zsh
chsh -s $(which zsh)

success "Shell configuration completed with Starship and Catppuccin theme"

# ============================================================================
# CLEANUP AND OPTIMIZATION
# ============================================================================

print_header "CLEANUP AND OPTIMIZATION"

log "Cleaning up system..."

# Remove orphaned packages
sudo pacman -Rns $(pacman -Qtdq) --noconfirm 2>/dev/null || true

# Clear AUR cache
paru -Sc --noconfirm

# Update font cache
fc-cache -fv

success "System cleanup completed"

# ============================================================================
# COMPLETION MESSAGE
# ============================================================================

clear
echo -e "${PURPLE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════════════════════╗
║                                                                               ║
║  ██████╗ ██████╗ ███╗   ███╗██████╗ ██╗     ███████╗████████╗███████╗       ║
║ ██╔════╝██╔═══██╗████╗ ████║██╔══██╗██║     ██╔════╝╚══██╔══╝██╔════╝       ║
║ ██║     ██║   ██║██╔████╔██║██████╔╝██║     █████╗     ██║   █████╗         ║
║ ██║     ██║   ██║██║╚██╔╝██║██╔═══╝ ██║     ██╔══╝     ██║   ██╔══╝         ║
║ ╚██████╗╚██████╔╝██║ ╚═╝ ██║██║     ███████╗███████╗   ██║   ███████╗       ║
║  ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝     ╚══════╝╚══════╝   ╚═╝   ╚══════╝       ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

print_header "INSTALLATION SUMMARY"

echo ""
success "Enhanced Arch Linux Developer Environment Setup Complete!"
echo ""
echo -e "${CYAN}Installed Components:${NC}"
echo -e "  ${GREEN}✓${NC} Intel Alder Lake CPU/GPU support"
echo -e "  ${GREEN}✓${NC} Essential system tools (btop, fastfetch, yt-dlp, cava, zenity, amberol)"
echo -e "  ${GREEN}✓${NC} Development tools:"
echo -e "    ${BLUE}•${NC} VS Code, Google Chrome"
echo -e "    ${BLUE}•${NC} Node.js via NVM"
echo -e "    ${BLUE}•${NC} Python via Pyenv"
echo -e "    ${BLUE}•${NC} Docker with official CE plugins"
echo -e "  ${GREEN}✓${NC} Enhanced shell environment:"
echo -e "    ${BLUE}•${NC} Zsh with Oh-My-Zsh"
echo -e "    ${BLUE}•${NC} Starship prompt with Catppuccin theme"
echo -e "    ${BLUE}•${NC} Essential plugins and aliases"
echo -e "  ${GREEN}✓${NC} Fonts: JetBrains Mono Nerd Font + system fonts"
echo -e "  ${GREEN}✓${NC} Media: Amberol music player"
echo -e "  ${GREEN}✓${NC} Flatpak support ready for additional applications"
echo -e "  ${GREEN}✓${NC} System optimized and cleaned"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo -e "  ${BLUE}1.${NC} Reboot your system: ${WHITE}sudo reboot${NC}"
echo -e "  ${BLUE}2.${NC} Your new shell (Zsh) will load with Starship + Catppuccin theme"
echo -e "  ${BLUE}3.${NC} Docker group membership will be active after reboot"
echo -e "  ${BLUE}4.${NC} Use ${WHITE}nvm list${NC} to see installed Node.js versions"
echo -e "  ${BLUE}5.${NC} Pyenv is ready - use ${WHITE}pyenv install 3.12.7${NC} to install Python"
echo -e "  ${BLUE}6.${NC} Try ${WHITE}cava${NC} for audio visualization"
echo -e "  ${BLUE}7.${NC} Launch ${WHITE}amberol${NC} for music playback"
echo ""
echo -e "${YELLOW}⚠ ${WHITE}Reboot now?${NC} [${GREEN}Y${NC}/${RED}n${NC}]: "
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]] || [[ -z "$response" ]]; then
    echo -e "${GREEN}✓${NC} Rebooting system..."
    sudo reboot
else
    echo -e "${BLUE}ℹ${NC} Reboot skipped. Please reboot manually when ready: ${WHITE}sudo reboot${NC}"
    echo -e "${YELLOW}Note:${NC} Docker group membership and shell changes require a reboot to take effect."
fi