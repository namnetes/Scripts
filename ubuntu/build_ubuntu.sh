#!/bin/bash
#Alan
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

# update snap
update_snap() {
  echo "Updating snap..."
  snap refresh
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
    fd-find
    fzf
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
    ripgrep
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
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
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
  echo "Installing GitHub CLI..."

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

# install Lazygit
install_lazygit() {
  echo "Installing lazygit..."

  # extract lazygit version
  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/\
lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')

  # donwload lazigit in the file named lazygit.tar.gz
  curl -Lo lazygit.tar.gz \
"https://github.com/jesseduffield/lazygit/releases/download/\
v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"

  # extract lazygit.tar.gz in lazygit folder
  tar xf lazygit.tar.gz lazygit

  # install lazygit in /usr/local/bin/ folder
  install lazygit -D -t /usr/local/bin/

  # clear unecessary files and folders
  rm -rf lazygit lazygit.tar.gz
}

install_neovim() {
  if [ ! -d "/usr/local/nvim" ]; then
    echo "Installing neovim..."
    rm -rf /usr/local
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
    tar -xzf nvim-linux-x86_64.tar.gz
    mv nvim-linux-x86_64 /usr/local
    echo "Neovim has been installed in the /usr/local directory"
  fi
}

# install_lazyvim
install_lazyvim() {
  echo "Installing lazyvim..."

  # Install neovim if not yet done
  if [ ! -d "/usr/local/nvim" ]; then
    echo "Neovim is required and must therefore be installed."
    exit 1
  fi

  NVIM_VERSION=$(/usr/local/nvim/bin/nvim --version | head -n 1 | awk '{print $2}' | cut -c 2-)
  echo "The $NVIM_VERSION is installed"

  IFS='.' read -r MAJOR MINOR PATCH <<< "$NVIM_VERSION"
  if [ "$MAJOR" -lt 0 ] || ([ "$MAJOR" -eq 0 ] && [ "$MINOR" -lt 10 ]) || ([ "$MAJOR" -eq 0 ] && [ "$MINOR" -eq 10 ] && [ "$PATCH" -lt 0 ]); then
    echo 'Lazyvim requires at least version 0.10.0 or higher.'
    exit 1
  fi

  rm -rf ~/.config/nvim
  rm -rf ~/.local/share/nvim
  rm -rf ~/.local/state/nvim
  rm -rf ~/.cache/nvim

  # Install lazyvim
  git clone https://github.com/LazyVim/starter ~/.config/nvim
  rm -rf ~/.config/nvim/.git
  echo "On the next startup of lzayvim/nvim the installation will be completed.\n" \
  "It is recommended to run :LazyHealth after installation."
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
update_snap
cleanup_packages
install_packages
install_python
install_gnome_tools
install_vlc
install_starship
install_firacode
install_githubCLI
install_lazygit
install_neovim

# "Call the function with the regular user"
sudo -u $(logname) bash -c "$(declare -f install_lazyvim); install_lazyvim"

install_virtualization
install_x11_dependencies
install_ssh_server
update_locate_db
cleanup
check_wsl

