#!/usr/bin/env bash
################################################################################
# install_ubuntu-restricted-addons.sh
#
# Description :
# Ce module installe ubuntu-restricted-addons sur un système Ubuntu :
# - Pré-accepte la licence des polices Microsoft via debconf
# - Met à jour l’index des paquets
# - Installe le métapaquet de manière non-interactive
#
# Auteur : Magali (adapté avec l’aide de Copilot ✨)
#
# Usage :
# Ce module est conçu pour être sourcé depuis un script principal.
################################################################################

# -----------------------------------------------------------------------------
# Vérification : ce module doit être sourcé, pas exécuté directement
# -----------------------------------------------------------------------------
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && {
  echo "Ce module doit être sourcé depuis un script principal." >&2
  return 1 2>/dev/null || exit 1
}

################################################################################
# install_restricted_addons : Installe ubuntu-restricted-extras
################################################################################
install_restricted_addons() {
  log_info "[INSTALLATION] Initialisation de ubuntu-restricted-extras."

  local pkg="ubuntu-restricted-addons"
  local font_pkg="ttf-mscorefonts-installer"
  local accepted="msttcorefonts/accepted-mscorefonts-eula"

  # 1. Pré-acceptation de la licence des polices Microsoft
  log_info "  [CONFIG] Pré-acception de la licence du paquet ${font_pkg}."
  echo "${font_pkg} ${accepted} select true" | sudo debconf-set-selections

  # 2. Mise à jour de l’index des paquets
  log_info "  [ACTION] Mise à jour de l’index APT..."
  sudo apt-get update

  # 3. Installation du paquet
  log_info "  [ACTION] Installation de ${pkg}..."
  if ! sudo apt-get install -y "${pkg}"; then
    log_error "  [ÉCHEC] Installation de ${pkg} échouée."
    return 1
  fi

  # 4. Vérification finale
  if dpkg -s "${pkg}" &>/dev/null; then
    log_info "[SUCCÈS] ${pkg} installé avec succès."
  else
    log_error "[ERREUR] ${pkg} semble ne pas avoir été correctement installé."
    return 1
  fi
}
