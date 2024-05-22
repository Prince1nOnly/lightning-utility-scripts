#!/bin/bash

# Define persistent storage directory
PERSISTENT_LINUXBREW_DIR="/teamspace/studios/this_studio/.packages/linuxbrew/"

# Ensure persistent storage directory exists (with optional verbose output)
mkdir -pv "$PERSISTENT_LINUXBREW_DIR"

# If /home/linuxbrew/ doesn't exist or isn't a symlink, set it up
if [ ! -L "/home/linuxbrew/" ]; then
  # If /home/linuxbrew/ exists and is a directory, move its contents
  if [ -d "/home/linuxbrew/" ]; then
    # Check if move was successful (assuming enough privileges without sudo)
    sudo mv /home/linuxbrew/ "$PERSISTENT_LINUXBREW_DIR" && echo "Contents of /home/linuxbrew/ moved successfully" || echo "Failed to move contents of /home/linuxbrew/"
  fi
  # Create the symbolic link
  ln -s "$PERSISTENT_LINUXBREW_DIR" /home/linuxbrew/ || echo "Failed to create symbolic link /home/linuxbrew/"
fi
