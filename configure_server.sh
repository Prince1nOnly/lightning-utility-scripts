#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variable to hold the "yes to all" flag
YES_TO_ALL=false

# Function to check the status of the last command and exit if it failed
check_status() {
  if [ $? -ne 0 ]; then
    echo -e "\n${RED}[$(date)] $1 failed.${NC}" >> script.log
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
    echo -e "\n${YELLOW}Backup directory does not exist. Creating...${NC}"
    mkdir -p "$BACKUP_DIR"
    check_status "Creating backup directory"
  fi

  # Backup the password
  echo -e "\n${GREEN}Backing up password to storage...${NC}"
  if [ -f ./save_password.sh ]; then
    source ./save_password.sh
    check_status "Password backup"
    echo -e "${GREEN}Password successfully backed up.${NC}"
  else
    echo -e "${RED}save_password.sh script not found.${NC}"
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
      *) echo -e "${YELLOW}Invalid response. Please enter 'yes[Y/y]' or 'no[N/n]'.${NC}" ;;
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
      echo -e "${RED}Invalid option: -$OPTARG${NC}" 1>&2
      exit 1
      ;;
  esac
done

# Make all scripts in the current directory executable
echo -e "\n${GREEN}Setting executable permissions for all scripts in the current directory...${NC}"
chmod +x ./*.sh
check_status "Setting executable permissions"

# Display the task description to the user
echo -e "\n${GREEN}This script will configure your Ubuntu Docker instance by performing the following tasks:${NC}"
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
  read -p "${YELLOW}Press Enter to start the configuration process...${NC}"
fi

# Change user password
echo -e "\n${GREEN}Changing user password...${NC}"
echo "$(whoami):welcome" | sudo chpasswd
check_status "Password change"
echo -e "${GREEN}Password changed successfully. New password is 'welcome'.${NC}"

# Backup password
backup_password

# Update package repositories and packages
echo -e "\n${GREEN}Updating package repositories and packages...${NC}"
sudo apt update && sudo apt full-upgrade -y
check_status "Package update"
echo -e "${GREEN}Package repositories and packages updated successfully.${NC}"

# Prompt for and install Linuxbrew
if get_yes_no_response "${YELLOW}Do you want to install Linuxbrew?${NC}"; then
  echo "Installing Linuxbrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  check_status "Linuxbrew installation"
  echo -e "${GREEN}Linuxbrew installed successfully.${NC}"
  ##########################################
else
  echo -e "${YELLOW}Skipping Linuxbrew installation.${NC}"
fi

# Prompt for a release upgrade
if get_yes_no_response "${YELLOW}Do you want to upgrade to the latest Ubuntu LTS release?${NC}"; then
  echo -e "\n${GREEN}Checking and installing required dependencies for release upgrade...${NC}"
  sudo apt install -y update-manager-core
  check_status "Dependency installation for release upgrade"
  echo -e "${GREEN}Starting release upgrade...${NC}"
  sudo do-release-upgrade -f DistUpgradeViewNonInteractive
  check_status "Release upgrade"
  echo -e "${GREEN}Release upgrade completed successfully.${NC}"
else
  echo -e "${YELLOW}Skipping Ubuntu release upgrade.${NC}"
fi

# Append sourcing of "implement.sh" to .profile
if ! grep -q "source ~/lightning-utility-scripts/implement.sh" ~/.profile; then
  echo -e "\n${GREEN}Appending command to source 'implement.sh' to .profile...${NC}"
  echo "source ~/lightning-utility-scripts/implement.sh" >> ~/.profile
fi

# Automatically configure Linuxbrew in the profile if installed
if [ -d "/home/linuxbrew/.linuxbrew" ]; then
  if ! grep -q 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' ~/.profile; then
    echo -e "\n${GREEN}Configuring Linuxbrew in the profile...${NC}"
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.profile
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    check_status "Linuxbrew configuration in profile"
  fi
fi

# Append sourcing of .profile to .zshrc
if ! grep -q "source ~/.profile" ~/.zshrc; then
  echo -e "\n${GREEN}Appending command to source .profile to .zshrc...${NC}"
  echo "source ~/.profile" >> ~/.zshrc
fi

# Install essential packages
echo -e "\n${GREEN}Installing essential packages...${NC}"
sudo apt update && sudo apt full-upgrade -y
sudo apt install -y build-essential make apt-transport-https ca-certificates curl gnupg-agent software-properties-common net-tools iputils-ping git zip nano lsof iptables jq nodejs npm
check_status "Essential package installation"
echo -e "${GREEN}Essential packages installed successfully.${NC}"

# Switch to zsh if not already in zsh and source .zshrc
if [ "$SHELL" != "/bin/zsh" ]; then
  echo -e "\n${GREEN}Switching to zsh and sourcing .zshrc...${NC}"
  zsh -c "source ~/.zshrc"
  check_status "Switching to zsh and sourcing .zshrc"
else
  echo -e "\n${GREEN}Sourcing .zshrc to apply changes...${NC}"
  source ~/.zshrc
  check_status "Sourcing .zshrc"
fi

echo -e "\n${GREEN}Server configuration completed successfully.${NC}"
