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

  # 2. Préparer les clés APT
  install -d -m 0755 /etc/apt/keyrings
  local key_path="/etc/apt/keyrings/packages.mozilla.org.asc"
  wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee "${key_path}" > /dev/null

  # 3. Vérifier l’empreinte
  local expected_fp="35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3"
  local actual_fp
  actual_fp=$(gpg -n -q --import --import-options import-show "${key_path}" | awk '/pub/{getline; gsub(/^ +| +$/,""); print $0}')

  if [[ "${actual_fp}" != "${expected_fp}" ]]; then
    log_error "Empreinte de clé incorrecte : ${actual_fp}"
    return 1
  fi
  log_info "  [SECURITÉ] Empreinte de clé validée."

  # 4. Ajouter le dépôt Mozilla
  echo "deb [signed-by=${key_path}] https://packages.mozilla.org/apt mozilla main" \
    | tee /etc/apt/sources.list.d/mozilla.list > /dev/null

  echo 'Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000' | tee /etc/apt/preferences.d/mozilla > /dev/null

  # 5. Installer Firefox version DEB
  apt-get update && apt-get install -y firefox firefox-l10n-fr

  # 6. Vérification
  command -v firefox &>/dev/null && {
    log_info "[SUCCÈS] Firefox DEB installé avec succès."
  } || {
    log_error "Firefox DEB semble mal installé."
    return 1
  }
}

