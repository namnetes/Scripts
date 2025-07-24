#!/usr/bin/env bash
################################################################################
# install_restricted_packages.sh
#
# Description :
# Ce module installe les paquets 'ubuntu-restricted-addons' et
# 'ubuntu-restricted-extras'. Il gère spécifiquement l'acceptation
# automatique de la licence EULA pour 'ttf-mscorefonts-installer',
# nécessaire pour une installation non-interactive.
#
# Auteur : Votre Nom/Organisation
#
# Usage :
# Ce script doit être sourcé depuis un script principal.
################################################################################

# -----------------------------------------------------------------------------
# Vérification : ce module doit être sourcé, pas exécuté directement
# -----------------------------------------------------------------------------
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && {
  echo "Ce script doit être sourcé, pas exécuté directement." >&2
  return 1 2>/dev/null || exit 1
}

################################################################################
# install_restricted_packages : Installe les paquets restreints Ubuntu
################################################################################
install_restricted_packages() {
  log_info "[INSTALLATION] Initialisation des paquets restreints Ubuntu."

  # 1. Pré-configuration de debconf pour l'EULA ttf-mscorefonts-installer
  # Cette étape est cruciale pour l'installation non-interactive.
  log_info "  [ACTION] Pré-configuration de debconf pour accepter l'EULA."
  echo "ttf-mscorefonts-installer ttf-mscorefonts-installer/accepted-mscorefonts-eula select true" | \
    debconf-set-selections

  if [ $? -ne 0 ]; then
    log_error "Échec de la pré-configuration de debconf."
    return 1
  fi
  log_info "  [STATUT] Pré-configuration debconf terminée."

  # 2. Mise à jour des listes de paquets
  log_info "  [ACTION] Mise à jour des listes de paquets APT..."
  if ! apt update -y >/dev/null 2>&1; then
    log_error "Échec de la mise à jour des listes de paquets."
    return 1
  fi
  log_info "  [STATUT] Listes de paquets APT à jour."

  # 3. Installation des paquets 'ubuntu-restricted-addons' et '-extras'
  log_info "  [ACTION] Installation des paquets 'ubuntu-restricted-addons' et '-extras'."
  local packages="ubuntu-restricted-addons ubuntu-restricted-extras"
  if ! apt install -y ${packages} >/dev/null 2>&1; then
    log_error "Échec de l'installation des paquets restreints."
    return 1
  fi

  # 4. Vérification finale (simplifiée car 'apt install' est fiable)
  # On peut vérifier la présence de quelques paquets clés si nécessaire,
  # mais 'apt install' est généralement suffisant pour la validation.
  log_info "[SUCCÈS] Paquets restreints Ubuntu installés avec succès."
  return 0
}
