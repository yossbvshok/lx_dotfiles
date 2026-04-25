#!/bin/bash

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'

# Log functions
success() {
    echo -e "${GREEN}[✓]${NC} :: $1" 
}

error() {
    echo -e "${RED}[✗]${NC} :: $1" 
}

section() {
    echo -e "${CYAN}[ $1 ]${NC}" 
}

info() { 
    echo -e "${BLUE}[i]${NC} :: $1" 
}

warning() {
    echo -e "${YELLOW}[!]${NC} :: $1" 
}

# Cloning dotfiles to root
cloneDotfiles() {
    section "Cloning dotfiles to /root"

    mkdir -p /root/tools

    cd /root/tools

    # Clone dotfiles directly to root
    git clone https://github.com/Yoswell/dotfiles.git
}

# Setting up BIN and ZSH for root
setupBinAndZsh() {
    section "Setting up BIN and ZSH for root"

    cd /root/tools/dotfiles

    # ZSH and BIN of root user
    cp -rf zshrc /root/.zshrc
    cp -rf bin /root/ && chmod +x /root/bin/*
}

# Setting up root themes
setupRootThemes() {
    section "Setting up root themes"
    
    cd /root/

    # Create necessary directories
    mkdir -p .themes
    mkdir -p .config/micro/colorschemes
    mkdir -p .config/kitty
    mkdir -p .config/xfce4/xfconf/xfce-perchannel-xml
    mkdir -p .config/gtk-3.0
    
    cd /root/tools/dotfiles/config
    
    # Extract themes from themes directory
    tar -xf themes/mantinight.tar -C /root/.themes/
    tar -xf themes/darksun.tar -C /root/.themes/
    
    # Copy schemes from schemes directory
    cp -f schemes/micro_theme.micro /root/.config/micro/colorschemes/
    cp -f schemes/kitty.conf /root/.config/kitty/
    cp -f schemes/tmux.conf /root/.tmux.conf

    # Copy rofi theme system wide
    cp -f schemes/rofi_theme.rasi /usr/share/rofi/themes/
    
    # Update XFCE configs
    cd /root/tools/dotfiles
    cp -f xfce/xfce4-keyboard-shortcuts.xml /root/.config/xfce4/xfconf/xfce-perchannel-xml/
    cp -f xfce/xfce4-power-manager.xml /root/.config/xfce4/xfconf/xfce-perchannel-xml/
    cp -f xfce/xfce4Settings.xml /root/.config/xfce4/xfconf/xfce-perchannel-xml/
}

main() {
    if [ "$EUID" -ne 0 ]; then
        warning "This script must be run as root"
        error "Please run: sudo $0"
        exit 1
    fi
    
    section "Starting Complete Setup for ROOT"
    info "This script will install EVERYTHING for root without asking"
    warning "Press Enter to continue or Ctrl+C to cancel..."
    read -r
    
    # Installation sequence for root
    cloneDotfiles
    setupBinAndZsh
    setupRootThemes
    
    # Completion message
    success "All root configurations applied"
    info "Run: source /root/.zshrc"
}

# Execute main function
main "$@"