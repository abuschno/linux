#!/bin/bash

# Check if the script is run as root or with sudo privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "Re-running the script with sudo..."
    exec sudo bash "$0" "$@"
    exit 1
fi

# Get the original user who ran the script using sudo
ORIGINAL_USER="${SUDO_USER:-$USER}"
USER_HOME=$(eval echo ~$ORIGINAL_USER)

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if Curl is installed
if ! command_exists curl; then
    echo "Curl is not installed. Installing Curl..."
    apt update && apt install -y curl
else
    echo "curl is already installed."
fi

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

# Change the default shell to zsh for the original user
echo "Setting zsh as the default shell for $ORIGINAL_USER..."
chsh -s "$(which zsh)" "$ORIGINAL_USER"

# Install Oh My Zsh
if [ ! -d "$USER_HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sudo -u "$ORIGINAL_USER" sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh is already installed."
fi

# Install Powerlevel10k theme
if [ ! -d "$USER_HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
    echo "Installing Powerlevel10k..."
    sudo -u "$ORIGINAL_USER" git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$USER_HOME/.oh-my-zsh/custom/themes/powerlevel10k"
else
    echo "Powerlevel10k is already installed."
fi

# Set Powerlevel10k as the theme in .zshrc
echo "Setting Powerlevel10k as the theme in .zshrc..."
sudo -u "$ORIGINAL_USER" sed -i 's/^ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$USER_HOME/.zshrc"

# Install zsh-autosuggestions plugin
if [ ! -d "$USER_HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    echo "Installing zsh-autosuggestions..."
    sudo -u "$ORIGINAL_USER" git clone https://github.com/zsh-users/zsh-autosuggestions "$USER_HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
else
    echo "zsh-autosuggestions is already installed."
fi

# Add zsh-autosuggestions to plugins in .zshrc if not already present
if ! grep -q "zsh-autosuggestions" "$USER_HOME/.zshrc"; then
    echo "Adding zsh-autosuggestions to plugins in .zshrc..."
    sudo -u "$ORIGINAL_USER" sed -i 's/plugins=(/&zsh-autosuggestions /' "$USER_HOME/.zshrc"
fi

# Download the Powerlevel10k configuration file (.p10k.zsh) from the given GitHub URL
echo "Downloading Powerlevel10k configuration..."
sudo -u "$ORIGINAL_USER" wget -O "$USER_HOME/.p10k.zsh" https://raw.githubusercontent.com/abuschno/linux/master/.p10k.zsh

# Download the zshrc configuration
echo "Downloading zshrc configuration..."
sudo -u "$ORIGINAL_USER" wget -O "$USER_HOME/.zshrc" https://raw.githubusercontent.com/abuschno/linux/master/zshrc

# Ensure the .p10k.zsh is sourced in .zshrc
if ! grep -q "source ~/.p10k.zsh" "$USER_HOME/.zshrc"; then
    echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' | sudo -u "$ORIGINAL_USER" tee -a "$USER_HOME/.zshrc"
fi

# Reload Zsh to apply the changes for the original user
echo "Reloading zsh..."
sudo -u "$ORIGINAL_USER" zsh

