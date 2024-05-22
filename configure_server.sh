#!/bin/bash

# Function to check the status of the last command and exit if it failed
check_status() {
  if [ $? -ne 0 ]; then
    echo "$1 failed."
    exit 1
  fi
}

# Function to backup password
backup_password() {
  # Define the backup directory and file path
  BACKUP_DIR="/teamspace/studios/this_studio/.config/user_creds"
  BACKUP_FILE="$BACKUP_DIR/shadow"

  # Check if the backup directory exists, if not, create it
  if [ ! -d "$BACKUP_DIR" ]; then
    echo "Backup directory does not exist. Creating..."
    mkdir -p "$BACKUP_DIR"
    check_status "Creating backup directory"
  fi

  # Backup the password
  echo "Backing up password to storage..."
  source ./save_password.sh
  check_status "Password backup"
  echo "Password successfully backed up."
}

# Make all scripts in the current directory executable
echo "Setting executable permissions for all scripts in the current directory..."
chmod +x ./*.sh
check_status "Setting executable permissions"

# Display the task description to the user
echo "This script will configure your Ubuntu Docker instance by performing the following tasks:"
echo "1. Change the user password."
echo "2. Update package repositories and packages."
echo "3. Prompt for a release upgrade of the current Ubuntu version."
echo "4. Prompt for and install Linuxbrew if desired."
echo "5. Append sourcing of 'implement.sh' to .profile."
echo "6. Append sourcing of .profile to .zshrc."
echo "7. Configure Linuxbrew in the profile."
echo "8. Install essential packages."

# Wait for the user to be ready
read -p "Press Enter to start the configuration process..."

# Change user password
echo "Changing user password..."
echo "$(whoami):welcome" | sudo chpasswd
check_status "Password change"
echo "Password changed successfully. New password is 'welcome'."

# Backup password
backup_password

# Update package repositories and packages
echo "Updating package repositories and packages..."
sudo apt update && sudo apt upgrade -y
check_status "Package update"
echo "Package repositories and packages updated successfully."

# Prompt for a release upgrade
read -p "Do you want to upgrade to the latest Ubuntu LTS release? (yes/no): " upgrade_ubuntu
if [[ $upgrade_ubuntu == "yes" ]]; then
  echo "Checking and installing required dependencies for release upgrade..."
  sudo apt install -y update-manager-core
  check_status "Dependency installation for release upgrade"
  echo "Starting release upgrade..."
  sudo do-release-upgrade
  check_status "Release upgrade"
  echo "Release upgrade completed successfully."
else
  echo "Skipping Ubuntu release upgrade."
fi

# Prompt for and install Linuxbrew
read -p "Do you want to install Linuxbrew? (yes/no): " install_brew
if [[ $install_brew == "yes" ]]; then
  echo "Installing Linuxbrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  check_status "Linuxbrew installation"
  echo "Linuxbrew installed successfully."
  echo "Persisting Linuxbrew to storage..."
  source ./setup_linuxbrew.sh
  check_status "Linuxbrew setup"
else
  echo "Skipping Linuxbrew installation."
fi

# Append sourcing of "implement.sh" to .profile
echo "Appending command to source 'implement.sh' to .profile..."
echo "source ~/lightning-utility-scripts/implement.sh" >> ~/.profile

# Append sourcing of .profile to .zshrc
echo "Appending command to source .profile to .zshrc..."
echo "source ~/.profile" >> ~/.zshrc

# Configure Linuxbrew in the profile
if [[ $install_brew == "yes" ]]; then
  echo "Configuring Linuxbrew in the profile..."
  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.profile
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  check_status "Linuxbrew configuration in profile"
fi

# Install essential packages
echo "Installing essential packages..."
sudo apt install -y build-essential make apt-transport-https ca-certificates curl gnupg-agent software-properties-common net-tools iputils-ping git zip nano lsof iptables jq
check_status "Essential package installation"
echo "Essential packages installed successfully."

# Affect changes to shell
echo "Sourcing .zshrc to apply changes..."
source ~/.zshrc
check_status "Sourcing .zshrc"

echo "Server configuration completed successfully."
