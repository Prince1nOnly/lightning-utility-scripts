#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Starting JupyterHub setup..."

# Add conda channels
echo "Configuring conda channels..."
conda config --add channels conda-forge
conda config --add channels jetbrains
conda config --add channels r

# Update conda packages
echo "Updating all conda packages..."
conda update --all -y

# Install conda packages
echo "Installing conda packages..."
conda install -y r-base kotlin-jupyter-kernel r-essentials xeus-sql xeus-cling xeus-octave bash_kernel deno jupyterhub ipykernel ipywidgets ipympl voila nbdime python-lsp-server jedi-language-server jupyterlab-git jupyter-resource-usage jupyterlab-drawio

# Fix the Kotlin kernel specification location
echo "Fixing Kotlin kernel specification location..."
python -m kotlin_kernel fix-kernelspec-location

# Install Bash kernel
echo "Installing Bash kernel..."
python -m bash_kernel.install

# Install the Deno kernel
echo "Installing Deno kernel..."
deno install --unstable --allow-read --allow-write --allow-net --allow-env --name deno_kernel https://deno.land/x/jupyter/deno_kernel.ts
deno jupyter --install

# Install OpenJDK, Kotlin, and jbang
echo "Installing OpenJDK, Kotlin, and jbang using Homebrew..."
brew install openjdk kotlin jbang

# Install Jupyter Java kernel using jbang
echo "Installing Jupyter Java kernel using jbang..."
jbang install-kernel@jupyter-java

# Install Octave
echo "Updating package lists and installing Octave..."
sudo apt update
sudo apt install -y octave

# Install IJavascript and set up the kernel
echo "Installing IJavascript and setting up the kernel..."
npm install -g ijavascript
ijsinstall

# Install the C kernel
echo "Installing C kernel..."
pip install jupyter-c-kernel
install_c_kernel

# Install Rust and the evcxr Jupyter kernel
echo "Installing Rust and evcxr Jupyter kernel..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env
cargo install evcxr_jupyter
evcxr_jupyter --install

# Install PowerShell and PowerShell kernel
echo "Installing PowerShell..."
./powershell.sh
# sudo ln -s ~/powershell/pwsh /usr/bin/pwsh
echo "Installing PowerShell kernel..."
pip install powershell_kernel
python -m powershell_kernel.install

echo "JupyterHub setup is complete."
