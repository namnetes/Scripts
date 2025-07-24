#!/usr/bin/env bash
################################################################################
# remove_snap_firefox.sh
#
# Description :
# Supprime Firefox installé via Snap et installe la version DEB depuis Mozilla :
# - Désactive et supprime le snap Firefox
# - Nettoie le montage systemd associé
# - Ajoute et vérifie le dépôt APT Mozilla
# - Installe Firefox et le pack de langue française
#
# Auteur : Magali & Copilot 🦊
#
# Usage :
# À sourcer dans un script principal ou exécuter avec sudo.
################################################################################

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && {
  echo "Ce script doit être sourcé ou exécuté avec sudo." >&2
  return 1 2>/dev/null || exit 1
}

remove_snap_firefox() {
  log_info "[SUPPRESSION] Désactivation et suppression de Firefox Snap."

  # 1. Désactiver et supprimer le Snap Firefox
  snap disable firefox 2>/dev/null || log_info "  [INFO] Snap Firefox déjà désactivé."
  systemctl stop var-snap-firefox-common-host\\x2dhunspell.mount 2>/dev/null
  systemctl disable var-snap-firefox-common-host\\x2dhunspell.mount 2>/dev/null
  snap remove --purge firefox || {
    log_error "Impossible de supprimer le Snap Firefox."
    return 1
  }
  log_info "  [OK] Firefox Snap supprimé avec succès."

  # 6. Vérification
  command -v firefox &>/dev/null && {
    log_error "Snap Firefox toujours installé."
  } || {
    log_info "[SUCCÈS] Snap Firefox supprimé avec succès."
    return 1
  }
}
