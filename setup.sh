#!/bin/bash

# Check if the script is run as root or with sudo privileges
if [ "$EUID" -ne 0 ]; then
    echo "This script needs to be run as root or with sudo privileges."
    echo "Re-running the script with sudo..."
    exec sudo bash "$0" "$@"
    exit
fi

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if Git is installed
if ! command_exists git; then
    echo "Git is not installed. Installing Git..."
    apt update && apt install -y git
else
    echo "Git is already installed."
fi

# Install Zsh if not installed
if ! command_exists zsh; then
    echo "Installing zsh..."
    apt update && apt install -y zsh
else
    echo "Zsh is already installed."
fi

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "Oh My Zsh is already installed."
fi

# Install Powerlevel10k theme
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    echo "Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
else
    echo "Powerlevel10k is already installed."
fi

# Set Powerlevel10k as the theme in .zshrc
echo "Setting Powerlevel10k as the theme in .zshrc..."
sed -i 's/^ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

# Install zsh-autosuggestions plugin
if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    echo "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
else
    echo "zsh-autosuggestions is already installed."
fi

# Add zsh-autosuggestions to plugins in .zshrc if not already present
if ! grep -q "zsh-autosuggestions" ~/.zshrc; then
    echo "Adding zsh-autosuggestions to plugins in .zshrc..."
    sed -i 's/plugins=(/&zsh-autosuggestions /' ~/.zshrc
fi

# Download the Powerlevel10k configuration file (.p10k.zsh) from the given GitHub URL
echo "Downloading Powerlevel10k configuration..."
wget -O ~/.p10k.zsh https://raw.githubusercontent.com/abuschno/linux/master/.p10k.zsh

# Ensure the .p10k.zsh is sourced in .zshrc
if ! grep -q "source ~/.p10k.zsh" ~/.zshrc; then
    echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> ~/.zshrc
fi

# Reload Zsh to apply the changes
echo "Reloading zsh..."
exec zsh
