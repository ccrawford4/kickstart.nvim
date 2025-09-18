#!/bin/bash

# Portable Neovim Configuration Installer
# This script installs/updates your portable Neovim config by symlinking to the standard config location

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SOURCE="$SCRIPT_DIR"

# Determine Neovim config directory based on OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    NVIM_CONFIG_DIR="$HOME/.config/nvim"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    NVIM_CONFIG_DIR="$HOME/.config/nvim"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    # Windows (Git Bash/Cygwin)
    NVIM_CONFIG_DIR="$HOME/AppData/Local/nvim"
else
    # Default to XDG config
    NVIM_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
fi

echo -e "${GREEN}Portable Neovim Config Installer${NC}"
echo "Source: $CONFIG_SOURCE"
echo "Target: $NVIM_CONFIG_DIR"
echo

# Check if Neovim is installed
if ! command -v nvim &> /dev/null; then
    echo -e "${YELLOW}Warning: Neovim is not installed on this system${NC}"
    echo "Please install Neovim first"
    exit 1
fi

# Create .config directory if it doesn't exist
mkdir -p "$(dirname "$NVIM_CONFIG_DIR")"

# Handle existing config
if [[ -e "$NVIM_CONFIG_DIR" ]]; then
    if [[ -L "$NVIM_CONFIG_DIR" ]]; then
        echo -e "${YELLOW}Existing symlink found, removing...${NC}"
        rm "$NVIM_CONFIG_DIR"
    elif [[ -d "$NVIM_CONFIG_DIR" ]]; then
        BACKUP_DIR="${NVIM_CONFIG_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
        echo -e "${YELLOW}Backing up existing config to: $BACKUP_DIR${NC}"
        mv "$NVIM_CONFIG_DIR" "$BACKUP_DIR"
    else
        echo -e "${YELLOW}Removing existing file: $NVIM_CONFIG_DIR${NC}"
        rm "$NVIM_CONFIG_DIR"
    fi
fi

# Create symlink
echo -e "${GREEN}Creating symlink...${NC}"
ln -s "$CONFIG_SOURCE" "$NVIM_CONFIG_DIR"

# Verify installation
if [[ -L "$NVIM_CONFIG_DIR" && -e "$NVIM_CONFIG_DIR" ]]; then
    echo -e "${GREEN}✓ Installation successful!${NC}"
    echo "Your portable Neovim config is now active"
    echo
    echo "To update your config:"
    echo "1. Make changes in: $CONFIG_SOURCE"
    echo "2. Run this script again (optional, changes are live)"
    echo
    echo "To uninstall:"
    echo "rm '$NVIM_CONFIG_DIR'"
else
    echo -e "${RED}✗ Installation failed${NC}"
    exit 1
fi
