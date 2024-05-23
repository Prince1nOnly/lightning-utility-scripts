#!/bin/bash

# Paths for the system shadow file and the persistent storage shadow file
SYSTEM_SHADOW_FILE="/etc/shadow"
PERSISTENT_SHADOW_DIR="/teamspace/studios/this_studio/.config/user_creds"
PERSISTENT_SHADOW_FILE="$PERSISTENT_SHADOW_DIR/shadow"

# Ensure the persistent storage directory exists
if [ ! -d "$PERSISTENT_SHADOW_DIR" ]; then
  echo "Creating persistent storage directory..."
  sudo mkdir -p "$PERSISTENT_SHADOW_DIR"
  if [ $? -ne 0 ]; then
    echo "Failed to create directory $PERSISTENT_SHADOW_DIR. Please check permissions and try again."
    exit 1
  fi
fi

# Save the password file to the persistent storage
echo "Saving the password file to persistent storage..."
sudo cp "$SYSTEM_SHADOW_FILE" "$PERSISTENT_SHADOW_FILE"
if [ $? -eq 0 ]; then
  echo "Password file saved successfully."
else
  echo "Failed to save the password file. Please check permissions and try again."
  exit 1
fi
