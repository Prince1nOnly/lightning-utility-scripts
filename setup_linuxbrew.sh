#!/bin/bash

# Define persistent storage directory
PERSISTENT_LINUXBREW_DIR="/teamspace/studios/this_studio/.packages/linuxbrew"

# Ensure persistent storage directory exists
mkdir -p "$PERSISTENT_LINUXBREW_DIR"

# If /home/linuxbrew doesn't exist or isn't a symlink, set it up
if [ ! -L "/home/linuxbrew" ]; then
    # If /home/linuxbrew exists and is a directory, move its contents
    if [ -d "/home/linuxbrew" ]; then
        # Loop through files in /home/linuxbrew and move them individually
        for file in /home/linuxbrew/*; do
            sudo mv "$file" "$PERSISTENT_LINUXBREW_DIR"
        done
    fi
    # Create the symbolic link
    sudo ln -s "$PERSISTENT_LINUXBREW_DIR" /home/linuxbrew
fi
