#!/bin/bash

# Path to the persistent storage shadow file
PERSISTENT_SHADOW_FILE="/teamspace/studios/this_studio/.config/user_creds/shadow"
# Path to the system shadow file
SYSTEM_SHADOW_FILE="/etc/shadow"

# Restore the password file from the persistent storage if it exists
if [ -f "$PERSISTENT_SHADOW_FILE" ]; then
  echo "Restoring password file from persistent storage..."
  sudo cp "$PERSISTENT_SHADOW_FILE" "$SYSTEM_SHADOW_FILE"
  if [ $? -eq 0 ]; then
    echo "Password file restored successfully."
  else
    echo "Failed to restore password file. Please check permissions and try again."
  fi
else
  echo "Persistent shadow file not found. Skipping restoration."
fi
