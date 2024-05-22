#!/bin/bash

# Description: This script will configure the Ubuntu server by performing the following tasks:
# 1. Change the user password.
# 2. Update package repositories and packages.
# 3. Attempt a release upgrade of the current Ubuntu version.
# 4. Prompt for and install Linuxbrew if the user desires.
# 5. Append sourcing of "implement.sh" to .profile.
# 6. Append sourcing of .profile to .zshrc.
# 7. Configure Linuxbrew in the profile.
# 8. Install essential packages.

# Change user password
echo "Starting password change..."
echo "$(whoami):welcome" | sudo chpasswd
if [ $? -eq 0 ]; then
  echo "Password changed successfully. New password is 'welcome'."
else
  echo "Failed to change password."
  exit 1
fi

# Update package repositories and packages
echo "Updating package repositories and packages..."
sudo apt update && sudo apt upgrade -y
if [ $? -eq 0 ]; then
  echo "Package repositories and packages updated successfully."
else
  echo "Failed to update packages."
  exit 1
fi

# Attempt to do a release upgrade
echo "Checking and installing required dependencies for release upgrade..."
sudo apt install -y update-manager-core
echo "Starting release upgrade..."
sudo do-release-upgrade -d
if [ $? -eq 0 ]; then
  echo "Release upgrade completed successfully."
else
  echo "Release upgrade failed."
  exit 1
fi

# Prompt for and install Linuxbrew
read -p "Do you want to install Linuxbrew? (yes/no): " install_brew
if [[ $install_brew == "yes" ]]; then
  echo "Installing Linuxbrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ $? -eq 0 ]; then
    echo "Linuxbrew installed successfully."
  else
    echo "Failed to install Linuxbrew."
    exit 1
  fi
else
  echo "Skipping Linuxbrew installation."
fi

# Append sourcing of "implement.sh" to .profile
echo "Appending command to execute 'implement.sh' to .profile..."
echo "source ~/lightning-utility-scripts/implement.sh" >> ~/.profile

# Append sourcing of .profile to .zshrc
echo "Appending command to execute .profile to .zshrc..."
echo "source ~/.profile" >> ~/.zshrc

# Configure Linuxbrew in the profile
if [[ $install_brew == "yes" ]]; then
  echo "Configuring Linuxbrew in the profile..."
  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.profile
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Install essential packages
echo "Installing essential packages..."
sudo apt install -y build-essential make apt-transport-https ca-certificates curl gnupg-agent software-properties-common net-tools iputils-ping git zip nano lsof iptables jq
if [ $? -eq 0 ]; then
  echo "Essential packages installed successfully."
else
  echo "Failed to install essential packages."
  exit 1
fi

echo "Server configuration completed."
