# Source the linuxbrew setup script
if [ -f /teamspace/studios/this_studio/setup_linuxbrew.sh ]; then
    source /teamspace/studios/this_studio/lightning-utility-scripts/setup_linuxbrew.sh
fi

# Ensure password
# Restore password state on shell startup
if [ -f /teamspace/studios/this_studio/lightning-utility-scripts/restore_password.sh ]; then
  /teamspace/studios/this_studio/lightning-utility-scripts/restore_password.sh
fi

# Function to handle shell exit
function on_exit {
  # Call the script to save password
  if [ -f /teamspace/studios/this_studio/lightning-utility-scripts/save_password.sh ]; then
    /teamspace/studios/this_studio/lightning-utility-scripts/save_password.sh
  fi

  # Call the script to move Jupyter kernels to the target directory
  if [ -f /teamspace/studios/this_studio/lightning-utility-scripts/move_kernels.sh ]; then
    /teamspace/studios/this_studio/lightning-utility-scripts/move_kernels.sh
  fi
}

# Trap EXIT signal to call the on_exit function
trap on_exit EXIT
