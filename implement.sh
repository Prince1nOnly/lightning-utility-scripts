#!/bin/bash

# Source the linuxbrew setup script if it exists
LINUXBREW_SETUP_SCRIPT="/teamspace/studios/this_studio/lightning-utility-scripts/setup_linuxbrew.sh"
if [ -f "$LINUXBREW_SETUP_SCRIPT" ]; then
    source "$LINUXBREW_SETUP_SCRIPT"
fi

# Restore password state on shell startup if the restore script exists
RESTORE_PASSWORD_SCRIPT="/teamspace/studios/this_studio/lightning-utility-scripts/restore_password.sh"
if [ -f "$RESTORE_PASSWORD_SCRIPT" ]; then
    "$RESTORE_PASSWORD_SCRIPT"
fi

# Function to handle shell exit
on_exit() {
  # Call the script to save password if it exists
  SAVE_PASSWORD_SCRIPT="/teamspace/studios/this_studio/lightning-utility-scripts/save_password.sh"
  if [ -f "$SAVE_PASSWORD_SCRIPT" ]; then
      "$SAVE_PASSWORD_SCRIPT"
  fi

  # Call the script to move Jupyter kernels to the target directory if it exists
  MOVE_KERNELS_SCRIPT="/teamspace/studios/this_studio/lightning-utility-scripts/move_kernels.sh"
  if [ -f "$MOVE_KERNELS_SCRIPT" ]; then
      "$MOVE_KERNELS_SCRIPT"
  fi
}

# Trap EXIT signal to call the on_exit function
trap on_exit EXIT
