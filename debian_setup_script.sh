#!/bin/bash

# Debian 13 Trixie Development & Gaming Setup Script
# Run with: bash setup_debian_trixie.sh

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    error "This script should not be run as root. Please run as a regular user."
    exit 1
fi

# Check if running Debian 13
if ! grep -q "trixie" /etc/debian_version 2>/dev/null && ! grep -q "13" /etc/debian_version 2>/dev/null; then
    warn "This script is designed for Debian 13 Trixie. Continuing anyway..."
fi

log "Starting Debian 13 Trixie setup..."

# Update system and clean package cache
log "Updating system packages..."
sudo apt update && sudo apt upgrade -y
sudo apt autoremove -y
sudo apt autoclean

# Install essential packages first
log "Installing essential packages..."
sudo apt install -y \
    curl \
    wget \
    git \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    build-essential \
    unzip \
    flatpak \
    gnome-software-plugin-flatpak \
    zsh

# Add Flathub repository
log "Adding Flathub repository..."
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install Intel Graphics drivers for Alder Lake Iris Xe
log "Installing Intel graphics drivers and firmware..."
sudo apt install -y \
    intel-media-va-driver-non-free \
    i965-va-driver \
    mesa-va-drivers \
    firmware-misc-nonfree \
    intel-microcode \
    vainfo

# Install development tools
log "Installing development tools..."

# Install PHP and required extensions
sudo apt install -y \
    php \
    php-cli \
    php-fpm \
    php-json \
    php-common \
    php-mysql \
    php-zip \
    php-gd \
    php-mbstring \
    php-curl \
    php-xml \
    php-pear \
    php-bcmath \
    php-dev

# Install Composer
log "Installing Composer..."
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === file_get_contents('https://composer.github.io/installer.sig')) { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer

# Install Docker Desktop
log "Installing Docker Desktop..."
# Download Docker Desktop for Linux
wget -O /tmp/docker-desktop-amd64.deb https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb
sudo dpkg -i /tmp/docker-desktop-amd64.deb || sudo apt install -f -y
rm /tmp/docker-desktop-amd64.deb

# Add user to docker group
sudo usermod -aG docker $USER

# Install Node.js and npm
log "Installing Node.js and npm..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

# Verify Node.js installation
node --version
npm --version

# Install VSCode
log "Installing Visual Studio Code..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt update
sudo apt install -y code

# Install terminal and system tools
log "Installing terminal and system tools..."
sudo apt install -y \
    kitty \
    cava \
    fastfetch

# Install fonts
log "Installing fonts..."
sudo apt install -y \
    fonts-liberation \
    fonts-liberation2 \
    ttf-mscorefonts-installer

# Install JetBrains Mono and Fira Code Nerd Fonts
log "Installing Nerd Fonts..."
mkdir -p ~/.local/share/fonts

# JetBrains Mono Nerd Font
wget -O /tmp/JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -o /tmp/JetBrainsMono.zip -d ~/.local/share/fonts/
rm /tmp/JetBrainsMono.zip

# Fira Code Nerd Font
wget -O /tmp/FiraCode.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip
unzip -o /tmp/FiraCode.zip -d ~/.local/share/fonts/
rm /tmp/FiraCode.zip

# Refresh font cache
fc-cache -fv

# Install GNOME extensions manager
log "Installing GNOME extension manager..."
sudo apt install -y gnome-shell-extension-manager

# Install OnlyOffice
log "Installing OnlyOffice..."
wget -O /tmp/onlyoffice-desktopeditors_amd64.deb https://download.onlyoffice.com/install/desktop/editors/linux/onlyoffice-desktopeditors_amd64.deb
sudo dpkg -i /tmp/onlyoffice-desktopeditors_amd64.deb || sudo apt install -f -y
rm /tmp/onlyoffice-desktopeditors_amd64.deb

# Install Flatpak applications
log "Installing Flatpak applications..."

# Gaming applications
flatpak install -y flathub com.heroicgameslauncher.hgl      # Heroic Games Launcher
flatpak install -y flathub com.valvesoftware.Steam         # Steam
flatpak install -y flathub org.libretro.RetroArch         # RetroArch
flatpak install -y flathub net.lutris.Lutris              # Lutris

# Media and communication
flatpak install -y flathub com.obsproject.Studio          # OBS Studio
flatpak install -y flathub com.discordapp.Discord         # Discord
flatpak install -y flathub com.spotify.Client             # Spotify

# Sober (Roblox client)
flatpak install -y flathub org.vinegarhq.Sober            # Sober

# Install GNOME extensions
log "Installing GNOME extensions..."
# These need to be installed manually through the extension manager or browser
# We'll install the necessary packages for common extensions

sudo apt install -y \
    gnome-shell-extension-appindicator \
    gnome-shell-extension-gsconnect

# Remove GNOME bloatware
log "Removing GNOME bloatware..."
sudo apt remove -y \
    gnome-games \
    gnome-music \
    gnome-photos \
    gnome-weather \
    gnome-maps \
    gnome-contacts \
    gnome-documents \
    evolution \
    totem \
    cheese \
    rhythmbox \
    shotwell \
    simple-scan \
    gnome-mahjongg \
    gnome-mines \
    gnome-sudoku \
    aisleriot \
    four-in-a-row \
    gnome-chess \
    gnome-klotski \
    gnome-nibbles \
    gnome-robots \
    gnome-tetravex \
    hitori \
    iagno \
    lightsoff \
    five-or-more \
    quadrapassel \
    gnome-taquin \
    swell-foop \
    tali 2>/dev/null || true

# Clean up
log "Cleaning up..."
sudo apt autoremove -y
sudo apt autoclean
flatpak uninstall --unused -y

# Create Laravel Sail project structure
log "Setting up Laravel Sail environment..."
mkdir -p ~/Development/laravel-projects
cd ~/Development/laravel-projects

# Create a sample Laravel project with Sail
log "Creating sample Laravel project..."
composer create-project laravel/laravel example-app
cd example-app
composer require laravel/sail --dev
php artisan sail:install
cd ~

# Configure Git (optional)
log "Configuring Git..."
read -p "Enter your Git username (or press Enter to skip): " git_username
read -p "Enter your Git email (or press Enter to skip): " git_email

if [[ -n "$git_username" ]]; then
    git config --global user.name "$git_username"
fi

if [[ -n "$git_email" ]]; then
    git config --global user.email "$git_email"
fi

# Install and configure Zsh with Oh My Zsh
log "Installing and configuring Zsh with Oh My Zsh..."

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install essential Oh My Zsh plugins
log "Installing Oh My Zsh plugins..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
git clone https://github.com/marlonrichert/zsh-autocomplete.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autocomplete

# Install Nord Extended theme
log "Installing Nord Extended Zsh theme..."
git clone https://github.com/fxbrit/nord-extended.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/nord-extended
ln -sf ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/nord-extended/nord-extended.zsh-theme ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/nord-extended.zsh-theme

# Configure .zshrc
log "Configuring Zsh..."
cat > ~/.zshrc << 'EOF'
# Path to your oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme
ZSH_THEME="nord-extended"

# Uncomment the following line to use case-sensitive completion
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion
# Case-sensitive completion must be off. _ and - will be interchangeable
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days)
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Which plugins would you like to load?
plugins=(
    git
    docker
    docker-compose
    node
    npm
    composer
    laravel
    zsh-autosuggestions
    zsh-syntax-highlighting
    fast-syntax-highlighting
    colored-man-pages
    extract
    web-search
    history-substring-search
    sudo
    z
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.

# Custom aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias sail='./vendor/bin/sail'
alias ff='fastfetch'
alias update='sudo apt update && sudo apt upgrade'
alias install='sudo apt install'
alias search='apt search'
alias clean='sudo apt autoremove && sudo apt autoclean'

# Docker aliases
alias dps='docker ps'
alias dpa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlog='docker logs'
alias dcp='docker-compose'
alias dcup='docker-compose up -d'
alias dcdown='docker-compose down'
alias dcps='docker-compose ps'
alias dclogs='docker-compose logs'

# Laravel aliases
alias artisan='php artisan'
alias tinker='php artisan tinker'
alias serve='php artisan serve'
alias migrate='php artisan migrate'
alias rollback='php artisan migrate:rollback'
alias seed='php artisan db:seed'
alias fresh='php artisan migrate:fresh --seed'

# Node.js aliases
alias ni='npm install'
alias ns='npm start'
alias nr='npm run'
alias nt='npm test'
alias nb='npm run build'
alias nw='npm run watch'

# Add ~/.local/bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# Add composer global bin to PATH
export PATH="$HOME/.config/composer/vendor/bin:$PATH"

# Add node_modules/.bin to PATH
export PATH="./node_modules/.bin:$PATH"

# Enable history search with arrow keys
bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down

# History configuration
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE
setopt HIST_NO_STORE
setopt HIST_EXPIRE_DUPS_FIRST

# Auto-completion settings
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{cyan}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}No matches for: %d%f'
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Load fastfetch on terminal start
if command -v fastfetch &> /dev/null; then
    fastfetch
fi
EOF

# Change default shell to zsh
chsh -s $(which zsh)

# Set Kitty as default terminal and configure it
log "Setting up Kitty configuration..."
mkdir -p ~/.config/kitty
cat > ~/.config/kitty/kitty.conf << 'EOF'
# Font configuration
font_family JetBrainsMono Nerd Font
font_size 12.0

# Nord color scheme
background #2e3440
foreground #d8dee9
cursor #d8dee9

# Black
color0 #3b4252
color8 #4c566a

# Red
color1 #bf616a
color9 #bf616a

# Green
color2 #a3be8c
color10 #a3be8c

# Yellow
color3 #ebcb8b
color11 #ebcb8b

# Blue
color4 #81a1c1
color12 #81a1c1

# Magenta
color5 #b48ead
color13 #b48ead

# Cyan
color6 #88c0d0
color14 #8fbcbb

# White
color7 #e5e9f0
color15 #eceff4

# Window
window_padding_width 10
background_opacity 0.95

# Tabs
tab_bar_style powerline
tab_powerline_style slanted

# Performance
repaint_delay 10
input_delay 3
sync_to_monitor yes

# Nord theme for tabs
active_tab_foreground #2e3440
active_tab_background #88c0d0
inactive_tab_foreground #d8dee9
inactive_tab_background #4c566a
EOF

# Final system update
log "Performing final system update..."
sudo apt update && sudo apt upgrade -y
sudo apt autoremove -y
sudo apt autoclean

# Create desktop entries for quick access
log "Creating desktop shortcuts..."
mkdir -p ~/.local/share/applications

# VSCode with Laravel project
cat > ~/.local/share/applications/vscode-laravel.desktop << 'EOF'
[Desktop Entry]
Name=VSCode Laravel
Comment=Open VSCode with Laravel project
Exec=code ~/Development/laravel-projects/example-app
Icon=code
Type=Application
Categories=Development;
EOF

log "Setup completed successfully!"
echo
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Setup Summary:${NC}"
echo -e "${GREEN}========================================${NC}"
echo "✓ System updated and cleaned"
echo "✓ Zsh with Oh My Zsh installed and configured"
echo "✓ Nord Extended theme installed"
echo "✓ Essential Zsh plugins installed"
echo "✓ Node.js and npm installed"
echo "✓ PHP and Composer installed"
echo "✓ Docker Desktop installed"
echo "✓ VSCode installed"
echo "✓ Laravel Sail project created at ~/Development/laravel-projects/example-app"
echo "✓ OnlyOffice installed"
echo "✓ Fonts installed (JetBrains Mono, Fira Code Nerd Fonts, MS Fonts)"
echo "✓ Gaming apps installed (Heroic, Steam, RetroArch, Lutris)"
echo "✓ Media apps installed (OBS, Discord, Spotify, Sober)"
echo "✓ Terminal tools installed (Kitty, Cava, Fastfetch)"
echo "✓ Intel graphics drivers installed"
echo "✓ GNOME extensions support installed"
echo "✓ GNOME bloatware removed"
echo "✓ System cleaned up"
echo
echo -e "${YELLOW}Important Notes:${NC}"
echo "• Please log out and log back in for all changes to take effect"
echo "• Zsh is now your default shell with Oh My Zsh and Nord Extended theme"
echo "• Docker Desktop provides a GUI interface for Docker management"
echo "• Run 'newgrp docker' to apply Docker group changes immediately"
echo "• Flatpak applications can be found in your application menu"
echo "• GNOME extensions can be managed via the Extension Manager"
echo "• AppIndicator and GSConnect extensions are installed but need to be enabled"
echo "• Laravel Sail project is ready at ~/Development/laravel-projects/example-app"
echo "• Use 'cd ~/Development/laravel-projects/example-app && ./vendor/bin/sail up' to start Laravel"
echo "• Node.js and npm are ready for JavaScript/TypeScript development"
echo "• Fastfetch will run automatically when opening a new terminal"
echo
echo -e "${GREEN}Zsh Plugins Installed:${NC}"
echo "• zsh-autosuggestions - Command suggestions based on history"
echo "• zsh-syntax-highlighting - Syntax highlighting for commands"
echo "• fast-syntax-highlighting - Fast syntax highlighting"
echo "• git - Git aliases and functions"
echo "• docker - Docker command completion"
echo "• node/npm - Node.js and npm completion"
echo "• composer/laravel - PHP Composer and Laravel completion"
echo "• colored-man-pages - Colored manual pages"
echo "• extract - Universal archive extraction"
echo "• web-search - Search the web from terminal"
echo "• history-substring-search - Search history with arrow keys"
echo "• sudo - Double ESC to add sudo to previous command"
echo "• z - Smart directory jumping"
echo
echo -e "${GREEN}Setup completed! Enjoy your new development environment!${NC}"