#!/bin/bash

# Define the persistent storage directory
PERSISTENT_LINUXBREW_DIR="/teamspace/studios/this_studio/.packages/linuxbrew"

# Ensure the persistent storage directory exists
sudo mkdir -pv "$PERSISTENT_LINUXBREW_DIR"

# Check if /home/linuxbrew exists and is not a symlink
if [ ! -L "/home/linuxbrew" ]; then
  # If /home/linuxbrew exists and is a directory, move its contents
  if [ -d "/home/linuxbrew" ]; then
    echo "Moving /home/linuxbrew to $PERSISTENT_LINUXBREW_DIR..."
    shopt -s dotglob
    sudo mv /home/linuxbrew/* "$PERSISTENT_LINUXBREW_DIR"/
    shopt -u dotglob
    if [ $? -eq 0 ]; then
      echo "/home/linuxbrew moved successfully."
    else
      echo "Failed to move contents of /home/linuxbrew."
      exit 1
    fi
  fi
  
  # Remove the original /home/linuxbrew directory if it's empty
  sudo rmdir /home/linuxbrew 2>/dev/null

  # Create the symbolic link
  echo "Creating symbolic link /home/linuxbrew -> $PERSISTENT_LINUXBREW_DIR..."
  sudo ln -s "$PERSISTENT_LINUXBREW_DIR" /home/linuxbrew
  if [ $? -eq 0 ]; then
    echo "Symbolic link created successfully."
  else
    echo "Failed to create symbolic link /home/linuxbrew."
    exit 1
  fi
else
  echo "/home/linuxbrew is already a symbolic link. No action needed."
fi
