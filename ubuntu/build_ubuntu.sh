
#!/usr/bin/bash

#==============================================================================
# Script Name    : build_ubuntu.sh
# Description    : This script includes everything necessary after a fresh
#                  Ubuntu installation.
#
# Author         : Alan MARCHAND
# Compatibility  : Bash Only
#==============================================================================

# to enable debug mode : set -x
set +x

# Exit immediately if a command exits with a non-zero status
#set -e

# Check if the script is executed directly or called from another script
if [[ $SHLVL -eq 1 ]]; then
  echo "This script should not be run directly from the command line."
  exit 1
fi

# Get the name of the calling script
CALLER_PPID=$(ps -o args= $PPID)
CALLER_SCRIPT=$(echo $CALLER_PPID | awk '{print $2}' | awk -F '/' '{print $NF}')
echo "Caller script is : $CALLER_SCRIPT"

# Check if the calling script is authorized
AUTHORIZED_CALLER="run_build_ubuntu.sh"
if [[ $CALLER_SCRIPT != $AUTHORIZED_CALLER ]]; then
  echo "This script should only be called from $AUTHORIZED_CALLER"
  exit 1
fi

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
  apt-get update
  apt-get dist-upgrade -y
}

# update snap
update_snap() {
  echo "Updating snap..."
  pkill firefox
  snap refresh
  snap install yazi --classic
  snap install kolourpaint onlyoffice-desktopeditors
}

# Remove unnecessary packages
cleanup_packages() {
  echo "Removing unnecessary packages..."
  apt-get -y remove --purge screen || true
  apt-get -y autoremove --purge || true
}

# Function to add PPA repositories from a predefined list
add_ppas() {
  echo "Checking and adding PPA repositories..."

  apt-get install -y software-properties-common

  local ppas=(
    "ppa:ansible/ansible"
    # Ajoute ici d'autres PPA sans modifier la logique de la fonction
  )

  for ppa in "${ppas[@]}"; do
    # Vérifier si le PPA est déjà ajouté
    if grep -q "^deb .*${ppa}" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
      echo "✅ PPA déjà présent : $ppa"
    else
      echo "➕ Ajout du PPA : $ppa"
      sudo add-apt-repository --yes --update "$ppa"
    fi
  done

  # Mise à jour après ajout des nouveaux PPA
  apt-get update
}

# Install necessary packages
install_packages() {
  echo "Installing necessary base packages..."
  local packages=(
    apt-transport-https
    ansible
    bat
    build-essential
    cifs-utils
    colordiff
    curl
    dbus-x11
    dos2unix
    elfutils
    ecryptfs-utils
    exuberant-ctags
    fd-find
    gawk
    gdb
    git
    gnome-calendar
    gnome-contacts
    gnome-shell-extensions
    gnome-user-share
    graphviz
    btop++
    imagemagick
    indent
    jq
    kitty
    libpam0g
    lsb-release
    man
    meld
    nautilus-admin
    nautilus-image-converter
    nautilus-share
    nautilus-wipe
    ncat
    nmap
    pdfgrep
    plocate
    poppler-utils
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
    zoxide
  )
  apt-get install -y "${packages[@]}"
}

# Install Python 3
install_python() {
  echo "Installing Python 3..."
  apt-get install -y python3

  echo "Installing uv packager..."
  sudo -u $(logname) bash -c "curl -LsSf https://astral.sh/uv/install.sh | sh"

  PYTHON3_PATH=$(which python3)
  PYTHON3_DIR=$(echo $PYTHON3_PATH | sed 's/[0-9]*$//')
  PYTHON3_VERSION=$($PYTHON3_PATH --version | cut -d ' ' -f2 | sed 's/\.[0-9]*$//')
  update-alternatives --install $PYTHON3_DIR python ${PYTHON3_DIR}${PYTHON3_VERSION} 1
  update-alternatives --list python
}

# Install GNOME utilities
install_gnome_tools() {
  echo "Installing GNOME tools..."
  apt-get install -y \
    dconf-editor \
    gnome-tweaks \
    gnome-shell-extension-manager
}

# Install VLC and multimedia codecs
install_vlc() {
  echo "Installing VLC and codecs..."
  apt-get install -y \
    ubuntu-restricted-addons \
    ubuntu-restricted-extras \
    vlc
}

# Install Starship cross-shell prompt
install_starship() {
  echo "Installing Starship..."
  curl -sS https://starship.rs/install.sh | sh -s -- --yes
}


# Install fzf
install_fzf() {
  echo "Installing fzf..."

  # Récupérer l'utilisateur réel
  USER_HOME=$(eval echo ~$(logname))

  # Définir le chemin d'installation
  INSTALL_DIR="$USER_HOME/.local/bin"

  # S'assurer que le dossier existe
  sudo -u $(logname) mkdir -p "$INSTALL_DIR"

  # Récupérer la dernière version disponible
  FZF_VERSION=$(curl -s "https://api.github.com/repos/junegunn/fzf/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+' )

  # Vérifier si la récupération a réussi
  if [[ -z "$FZF_VERSION" ]]; then
      echo "Error: Unable to retrieve fzf version."
      return 1
  fi

  # Télécharger l'archive
  sudo -u $(logname) wget -qO "$INSTALL_DIR/fzf.tar.gz" "https://github.com/junegunn/fzf/releases/download/v$FZF_VERSION/fzf-$FZF_VERSION-linux_amd64.tar.gz"

  # Extraire l'archive dans le bon dossier
  sudo -u $(logname) tar -xzf "$INSTALL_DIR/fzf.tar.gz" -C "$INSTALL_DIR"

  # Nettoyer les fichiers temporaires
  sudo -u $(logname) rm -rf "$INSTALL_DIR/fzf.tar.gz"

  # Vérifier l'installation
  if sudo -u $(logname) "$INSTALL_DIR/fzf" --version &>/dev/null; then
     echo "✅ fzf version $FZF_VERSION successfully installed in $INSTALL_DIR!"
  else
     echo "❌ Error during fzf installation."
     return 1
  fi
}


# Install kitty
install_kitty() {
  if command -v kitty &>/dev/null; then
    # Sauvegarder le chemin d'installation de kitty
    KITTY_PATH=$(command -v kitty)

    # Vérifier s'il existe une alternative kitty installée
    if ! update-alternatives --query x-terminal-emulator | grep -q 'link currently points to kitty'; then
      # Installer l'alternative kitty
      sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator $KITTY_PATH 50
    fi

    # Définir kitty comme terminal par défaut
    sudo update-alternatives --set x-terminal-emulator $KITTY_PATH
  fi
}

# install Github CLI
install_githubCLI() {
  echo "Installing GitHub CLI..."

  mkdir -p /etc/apt/keyrings

  wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg |
    sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null

  chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/\
githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" |
    sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null

  apt-get update
  apt-get install gh -y
}

# Install Virtualization stack
install_virtualization() {
  echo "Installing Virtualization stack..."
  apt-get install -y \
    bridge-utils \
    libvirt-clients \
    libvirt-clients-qemu \
    libvirt-daemon \
    libvirt-daemon-driver-lxc \
    libvirt-daemon-driver-vbox \
    qemu-system-x86 \
    virt-manager
}

install_xan() {
    echo "Installing Xan, the CSV magician."

    # Retrieve the latest version
    XAN_VERSION=$(curl -s "https://api.github.com/repos/medialab/xan/releases/latest" | grep -Po '"tag_name": "\K[0-9.]+' )

    # Check if retrieval was successful
    if [[ -z "$XAN_VERSION" ]]; then
        echo "Error: Unable to retrieve Xan version."
        return 1
    fi

    # Download the archive
    wget -qO xan.tar.gz "https://github.com/medialab/xan/releases/download/$XAN_VERSION/xan-x86_64-unknown-linux-gnu.tar.gz"

    # Extract and install
    sudo tar -xzf xan.tar.gz -C /usr/local/bin xan

    # Clean up temporary files
    rm -rf xan.tar.gz

    # Verify installation
    if xan --version &>/dev/null; then
        echo "✅ Xan version $XAN_VERSION successfully installed!"
    else
        echo "❌ Error during Xan installation."
        return 1
    fi
}


# Install X11 Forwarding dependencies
install_x11_dependencies() {
  read -p "Do you want to install X11 Forwarding dependencies? (y/n) " answer
  if [[ "$answer" =~ ^[yY]$ ]]; then
    echo "Installing X11 dependencies..."
    apt-get install -y \
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
      apt-get install -y "$PKG"
    fi
  fi
}

# Install Firacode font
install_firacode() {
  echo "Installing FiraCode NERD Fonts..."
  git clone --depth 1 https://github.com/ryanoasis/nerd-fonts.git
  cd nerd-fonts/ >/dev/null 2>&1
  ./install.sh FiraCode >/dev/null 2>&1
  fc-cache -fv >/dev/null 2>&1
  cd ..
  rm -rf nerd-fonts
}

# Install Oh My Bash
install_oh_my_bash() {
  echo "Installing Oh My Bash..."
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
}

# Update locate database
update_locate_db() {
  echo "Updating the locate database..."
  updatedb
}

# Clean up temporary files and caches
cleanup() {
  echo "Cleaning up temporary files and caches..."
  apt-get -y autoremove --purge || true
  apt-get -y clean autoclean || true
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
manage_ppa
install_packages
install_python
install_gnome_tools
install_vlc
install_starship
install_fzf
install_kitty
install_githubCLI
install_virtualization
install_xan
install_x11_dependencies
install_ssh_server

# Unlike other functions executed with root privileges, these two functions must 
# imperatively be executed in the user space.
sudo -u $(logname) bash -c "$(declare -f install_firacode); install_firacode"
sudo -u $(logname) bash -c "$(declare -f install_oh-my-bash); install_oh-my-bash"

update_locate_db
cleanup
check_wsl
