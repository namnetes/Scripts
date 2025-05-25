#!/usr/bin/bash

# Check if the user is root
check_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "You must be a root user to execute this script." >&2
    exit 1
  fi
}

# Call the function to check if the user is root
check_root

# Execute the build_ubuntu.sh script and redirect output to log file
./build_ubuntu.sh |& tee "/var/log/$(date +%Y-%m-%d_%H-%M-%S)_build_unbuntu.log"
