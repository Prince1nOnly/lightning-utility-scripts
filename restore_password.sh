#!/bin/bash

# Restore the password file from the persistent storage
if [ -f /teamspace/studios/this_studio/shadow ]; then
  sudo cp /teamspace/studios/this_studio/.config/user_creds/shadow /etc/shadow
fi
