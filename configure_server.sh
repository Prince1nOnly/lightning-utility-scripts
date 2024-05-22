#!/bin/bash

# Variable to hold the "yes to all" flag
YES_TO_ALL=false

# Function to check the status of the last command and exit if it failed
check_status() {
  if [ $? -ne 0 ]; then
    echo "[$(date)] $1 failed." >> script.log
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
  if [ -f ./save_password.sh ]; then
    source ./save_password.sh
    check_status "Password backup"
    echo "Password successfully backed up."
  else
    echo "save_password.sh script not found."
    exit 1
  fi
}

# Function to get normalized yes/no response from the user
get_yes_no_response() {
  if $YES_TO_ALL; then
    return 0
  fi
  while true; do
    read -p "$1 (yes/no): " response
    case "$response" in
      [yY][eE][sS]|[yY]) return 0 ;;
      [nN][oO]|[nN]) return 1 ;;
      *) echo "Invalid response. Please enter 'yes[Y/y]' or 'no[N/n]'." ;;
    esac
  done
}

# Parse arguments
while getopts ":y" opt; do
  case ${opt} in
    y )
      YES_TO_ALL=true
      ;;
    \? )
      echo "Invalid option: -$OPTARG" 1>&2
      exit 1
      ;;
  esac
done

# Make all scripts in the current directory executable
echo "Setting executable permissions for all scripts in the current directory..."
chmod +x ./*.sh
check_status "Setting executable permissions"

# Display the task description to the user
echo "This script will configure your Ubuntu Docker instance by performing the following tasks:"
echo "1. Change the user password."
echo "2. Update package repositories and packages."
echo "3. Prompt for and install Linuxbrew if desired."
echo "4. Prompt for a release upgrade of the current Ubuntu version."
echo "5. Append sourcing of 'implement.sh' to .profile."
echo "6. Append sourcing of .profile to .zshrc."
echo "7. Automatically configure Linuxbrew in the profile if installed."
echo "8. Install essential packages."

# Wait for the user to be ready if not using -y
if ! $YES_TO_ALL; then
  read -p "Press Enter to start the configuration process..."
fi

# Change user password
echo "Changing user password..."
echo "$(whoami):welcome" | sudo chpasswd
check_status "Password change"
echo "Password changed successfully. New password is 'welcome'."

# Backup password
backup_password

# Update package repositories and packages
echo "Updating package repositories and packages..."
sudo apt update && sudo apt full-upgrade -y
check_status "Package update"
echo "Package repositories and packages updated successfully."

# Prompt for and install Linuxbrew
if get_yes_no_response "Do you want to install Linuxbrew?"; then
  echo "Installing Linuxbrew..."
  sudo apt-get install -y expect
  expect -c "
  set timeout -1
  spawn /bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"
  expect \"Password:\"
  send \"welcome\r\"
  expect eof
  "
  check_status "Linuxbrew installation"
  echo "Linuxbrew installed successfully."
  if [ -f ./setup_linuxbrew.sh ]; then
    echo "Persisting Linuxbrew to storage..."
    source ./setup_linuxbrew.sh
    check_status "Linuxbrew setup"
  else
    echo "setup_linuxbrew.sh script not found."
    exit 1
  fi
else
  echo "Skipping Linuxbrew installation."
fi

# Prompt for a release upgrade
if get_yes_no_response "Do you want to upgrade to the latest Ubuntu LTS release?"; then
  echo "Checking and installing required dependencies for release upgrade..."
  sudo apt install -y update-manager-core
  check_status "Dependency installation for release upgrade"
  echo "Starting release upgrade..."
  sudo do-release-upgrade -f DistUpgradeViewNonInteractive
  check_status "Release upgrade"
  echo "Release upgrade completed successfully."
else
  echo "Skipping Ubuntu release upgrade."
fi

# Append sourcing of "implement.sh" to .profile
if ! grep -q "source ~/lightning-utility-scripts/implement.sh" ~/.profile; then
  echo "Appending command to source 'implement.sh' to .profile..."
  echo "source ~/lightning-utility-scripts/implement.sh" >> ~/.profile
fi

# Automatically configure Linuxbrew in the profile if installed
if [ -d "/home/linuxbrew/.linuxbrew" ]; then
  if ! grep -q 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' ~/.profile; then
    echo "Configuring Linuxbrew in the profile..."
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.profile
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    check_status "Linuxbrew configuration in profile"
  fi
fi

# Append sourcing of .profile to .zshrc
if ! grep -q "source ~/.profile" ~/.zshrc; then
  echo "Appending command to source .profile to .zshrc..."
  echo "source ~/.profile" >> ~/.zshrc
fi

# Install essential packages
echo "Installing essential packages..."
sudo apt update && sudo apt full-upgrade -y
sudo apt install -y build-essential make apt-transport-https ca-certificates curl gnupg-agent software-properties-common net-tools iputils-ping git zip nano lsof iptables jq nodejs npm
check_status "Essential package installation"
echo "Essential packages installed successfully."

# Switch to zsh if not already in zsh and source .zshrc
if [ "$SHELL" != "/bin/zsh" ]; then
  echo "Switching to zsh and sourcing .zshrc..."
  zsh -c "source ~/.zshrc"
  check_status "Switching to zsh and sourcing .zshrc"
else
  echo "Sourcing .zshrc to apply changes..."
  source ~/.zshrc
  check_status "Sourcing .zshrc"
fi

echo "Server configuration completed successfully."
