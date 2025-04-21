#!/bin/bash

###########################################################################
# Check if the user is root
###########################################################################
check_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "You must be a root user to execute this script." >&2
    exit 1
  fi
}

###########################################################################
# Neovim installation
###########################################################################
install_neovim() {
  # Variables
  NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
  NVIM_TAR="nvim-linux-x86_64.tar.gz"
  NVIM_DIR="nvim-linux-x86_64"
  INSTALL_DIR="/usr/local/nvim"

  # Téléchargement de Neovim
  echo "Téléchargement de Neovim..."
  curl -L -o "$NVIM_TAR" "$NVIM_URL" || { echo "Échec du téléchargement de Neovim"; exit 1; }

  # Extraction de l'archive
  echo "Extraction de l'archive Neovim..."
  tar -xzf "$NVIM_TAR" || { echo "Échec de l'extraction de Neovim"; exit 1; }

  # Suppression de l'ancien répertoire et création du nouveau répertoire
  echo "Installation de Neovim..."
  sudo rm -rf "$INSTALL_DIR"
  sudo mkdir -p "$INSTALL_DIR"

  # Déplacement des fichiers extraits
  sudo mv ./"$NVIM_DIR"/* "$INSTALL_DIR/" || { echo "Échec du déplacement des fichiers Neovim"; exit 1; }

  # Nettoyage des fichiers temporaires
  rm -rf "$NVIM_TAR" "$NVIM_DIR"
}

###########################################################################
# Lazyvim installation
###########################################################################
install_lazyvim() {
  echo "Installation de LazyVim..."

  # Sauvegarde de l'ancienne configuration
  mv ~/.config/nvim{,.bak}
  mv ~/.local/share/nvim{,.bak}
  mv ~/.local/state/nvim{,.bak}
  mv ~/.cache/nvim{,.bak}

  # Clonage du dépôt LazyVim
  git clone https://github.com/LazyVim/starter ~/.config/nvim || { echo "Échec du clonage du dépôt LazyVim"; exit 1; }

  # Suppression du répertoire .git
  rm -rf ~/.config/nvim/.git

  echo "Installation terminée. Exécutez :LazyHealth dans Neovim pour vérifier l'installation."
}

###########################################################################
# main
###########################################################################
# to enable debug mode : set -x
set +x 

# Exit immediately if a command exits with a non-zero status
set -e

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
AUTHORIZED_CALLER="run_install_lazyvim.sh"
if [[ $CALLER_SCRIPT != $AUTHORIZED_CALLER ]]; then
  echo "This script should only be called from $AUTHORIZED_CALLER"
  exit 1
fi

# Installations...
check_root
install_neovim

# "Call the function with the regular user"
sudo -u $(logname) bash -c "$(declare -f install_lazyvim); install_lazyvim"

