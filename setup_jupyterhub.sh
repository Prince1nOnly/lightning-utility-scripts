#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting JupyterHub setup...${NC}"

# Update conda and add channels
echo -e "${YELLOW}Updating conda and configuring channels...${NC}"
conda config --add channels conda-forge
conda config --add channels jetbrains
conda config --add channels r
conda update --all -y

# Install conda packages
echo -e "${YELLOW}Installing conda packages...${NC}"
conda install -y r-base kotlin-jupyter-kernel r-essentials xeus-sql xeus-cling octave_kernel bash_kernel deno jupyterhub ipykernel ipywidgets ipympl voila nbdime python-lsp-server jedi-language-server jupyterlab-git jupyter-resource-usage

# Fix Kotlin kernel specification location
echo -e "${YELLOW}Fixing Kotlin kernel specification location...${NC}"
python -m kotlin_kernel fix-kernelspec-location

# Install Bash kernel
echo -e "${YELLOW}Installing Bash kernel...${NC}"
python -m bash_kernel.install

# Install Deno kernel
echo -e "${YELLOW}Installing Deno kernel...${NC}"
deno jupyter --install

# Install OpenJDK, Kotlin, and jbang
echo -e "${YELLOW}Installing OpenJDK, Kotlin, and jbang using Homebrew...${NC}"
brew install openjdk kotlin jbang

# Install Jupyter Java kernel using jbang
echo -e "${YELLOW}Installing Jupyter Java kernel using jbang...${NC}"
jbang install-kernel@jupyter-java

# Install Octave
echo -e "${YELLOW}Installing Octave...${NC}"
sudo apt-get update && sudo apt-get install -y octave

# Install IJavascript and set up the kernel
echo -e "${YELLOW}Installing IJavascript and setting up the kernel...${NC}"
npm install -g ijavascript && ijsinstall

# Install C kernel
echo -e "${YELLOW}Installing C kernel...${NC}"
pip install jupyter-c-kernel && sudo $(which install_c_kernel)

# Install Rust and evcxr Jupyter kernel
echo -e "${YELLOW}Installing Rust and evcxr Jupyter kernel...${NC}"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"
cargo install evcxr_jupyter && evcxr_jupyter --install

# Install PowerShell and PowerShell kernel
echo -e "${YELLOW}Installing PowerShell and PowerShell kernel...${NC}"
./powershell.sh
pip install powershell_kernel && python -m powershell_kernel.install

echo -e "${GREEN}JupyterHub setup is complete.${NC}"
