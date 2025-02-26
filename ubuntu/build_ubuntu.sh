#!/bin/bash

#==============================================================================
# Script Name    : build_ubuntu.sh
# Description    : This script includes everything necessary after a fresh
#                  Ubuntu installation.
#
# Author         : Alan MARCHAND
# Compatibility  : Bash Only
#==============================================================================

# Exit immediately if a command exits with a non-zero status
set -e

# Check if the user is root
check_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "You must be a root user to execute this script." >&2
    exit 1
  fi
}

# Update the system packages
update_system() {
  echo "Updating the system..."
  apt update
  apt dist-upgrade -y
}

# Remove unnecessary packages
cleanup_packages() {
  echo "Removing unnecessary packages..."
  apt -y remove --purge screen || true
  apt -y autoremove --purge || true
}

# Install necessary packages
install_packages() {
  echo "Installing necessary packages..."
  local packages=(
    apt-transport-https
    cifs-utils
    colordiff
    curl
    dbus-x11
    dos2unix
    elfutils
    exuberant-ctags
    gawk
    gdb
    git
    gnome-shell-extensions
    graphviz
    htop
    imagemagick
    indent
    jq
    libpam0g
    lsb-release
    man
    nautilus-admin
    nautilus-image-converter
    nautilus-share
    nautilus-wipe
    ncat
    nmap
    pdfgrep
    plocate
    samba
    software-properties-common
    sqlite3
    sqlite3-doc
    sharutils
    stow
    strace
    sudo
    tree
    wget
    xclip
  )
  apt install -y "${packages[@]}"
}

# Install Python 3
install_python() {
  echo "Installing Python 3..."
  apt install -y python3
  sudo -u $(logname) bash -c "curl -LsSf https://astral.sh/uv/install.sh | sh"
}

# Install GNOME utilities
install_gnome_tools() {
    echo "Installing GNOME tools..."
    apt install -y \
      dconf-editor \
      gnome-tweaks \
      gnome-shell-extension-manager
}

# Install VLC and multimedia codecs
install_vlc() {
    echo "Installing VLC and codecs..."
    apt install -y \
      ubuntu-restricted-addons \
      ubuntu-restricted-extras \
      vlc
}

# Install Starship cross-shell prompt
install_starship() {
    echo "Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh
}

# Install Firacode font
install_firacode() {
  sudo -u $(logname) bash -c "
    git clone --depth 1 https://github.com/ryanoasis/nerd-fonts.git
    cd nerd-fonts/ >/dev/null 2>&1
    ./install.sh FiraCode >/dev/null 2>&1
    fc-cache -fv >/dev/null 2>&1
    cd ..
    rm -rf nerd-fonts
  "
}

# install Github CLI
install_githubCLI() {
  mkdir -p /etc/apt/keyrings

  wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null

  chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/\
githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
| sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    
  apt update
  apt install gh -y
}

# Install Virtualization stack
install_virtualization() {
  read -p "Do you want to install Virtualization stack ? (y/n) " answer
  if [[ "$answer" =~ ^[yY]$ ]]; then
    echo "Installing Virtualization stack..."
    apt install -y \
      bridge-utils \
      libvirt-clients \
      libvirt-clients-qemu \
      libvirt-daemon \
      libvirt-daemon-driver-lxc \
      libvirt-daemon-driver-vbox \
      qemu-system-x86 \
      virt-manager
  fi
}

# Install X11 Forwarding dependencies
install_x11_dependencies() {
  read -p "Do you want to install X11 Forwarding dependencies? (y/n) " answer
  if [[ "$answer" =~ ^[yY]$ ]]; then
    echo "Installing X11 dependencies..."
    apt install -y \
      dbus-x11 \
      x11-apps \
      xvfb \
      xdm \
      xfonts-base \
      xfonts-100dpi \
      sxiv \
      twm \
      xterm
  fi
}

# Install and start SSH server
install_ssh_server() {
  read -p "Do you want to install the SSH server? (y/n) " answer
  if [[ "$answer" =~ ^[yY]$ ]]; then
    readonly PKG=openssh-server
    if dpkg --get-selections | grep -q "^$PKG[[:space:]]*install$" >/dev/null; then
      echo "OpenSSH server is already installed."
    else
      echo "Installing OpenSSH server..."
      apt install -y "$PKG"
    fi
  fi
}

# Update locate database
update_locate_db() {
  echo "Updating the locate database..."
  updatedb
}

# Clean up temporary files and caches
cleanup() {
  echo "Cleaning up temporary files and caches..."
  apt -y autoremove --purge || true
  apt -y clean autoclean || true
  rm -rf /tmp/*
}

# Check if the script is running on WSL
check_wsl() {
  if uname -a | grep -q "microsoft" && uname -a | grep -q "WSL"; then
    echo "Microsoft WSL2 system detected."
    echo "End of installation process."
    exit
  fi
}

# Execute functions
check_root
update_system
cleanup_packages
install_packages
install_python
install_gnome_tools
install_vlc
install_starship
install_firacode
install_githubCLI
install_virtualization
install_x11_dependencies
install_ssh_server
update_locate_db
cleanup
check_wsl

