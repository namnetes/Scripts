#!/usr/bin/env bash
################################################################################
# install_firefox.sh
#
# Description :
# Installe Firefox via le dépôt APT officiel de Mozilla :
# - Vérifie si Firefox est déjà installé via le dépôt Mozilla
# - Configure le dépôt et la priorité APT
# - Vérifie la signature du dépôt (fingerprint)
# - Installe Firefox et le pack de langue souhaité
#
# Auteur : Magali & Copilot ✨
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
# install_firefox : Installe Firefox depuis le dépôt Mozilla
################################################################################
install_firefox() {
  log_info "[INSTALLATION] Initialisation de Firefox."

  local firefox_bin
  firefox_bin=$(command -v firefox 2>/dev/null)

  # 1. Vérification de présence
  if [[ -n "${firefox_bin}" ]] && grep -q "packages.mozilla.org" /etc/apt/sources.list.d/mozilla.list 2>/dev/null; then
    local version
    version=$("${firefox_bin}" --version | awk '{print $NF}')
    log_info "  [STATUT] Firefox déjà installé (version : ${version})."
    return 0
  fi

  # 2. Préparation du répertoire de clés
  install -d -m 0755 /etc/apt/keyrings

  # 3. Téléchargement et installation de la clé
  local key_path="/etc/apt/keyrings/packages.mozilla.org.asc"
  wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee "${key_path}" > /dev/null

  # 4. Vérification de l'empreinte
  local expected_fp="35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3"
  local actual_fp
  actual_fp=$(gpg -n -q --import --import-options import-show "${key_path}" | awk '/pub/{getline; gsub(/^ +| +$/,""); print $0}')

  if [[ "${actual_fp}" != "${expected_fp}" ]]; then
    log_error "Empreinte incorrecte : ${actual_fp} (attendu : ${expected_fp})"
    return 1
  fi
  log_info "  [SECURITÉ] Empreinte de clé vérifiée : ${actual_fp}"

  # 5. Ajout du dépôt Mozilla
  echo "deb [signed-by=${key_path}] https://packages.mozilla.org/apt mozilla main" \
    | tee /etc/apt/sources.list.d/mozilla.list > /dev/null

  # 6. Priorisation du dépôt
  echo 'Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000' | tee /etc/apt/preferences.d/mozilla > /dev/null

  # 7. Mise à jour et installation
  apt-get update
  apt-get install -y firefox

  # 8. Pack de langue (français par défaut)
  apt-get install -y firefox-l10n-fr

  # 9. Vérification finale
  if command -v firefox &>/dev/null; then
    local final_version
    final_version=$(firefox --version | awk '{print $NF}')
    log_info "[SUCCÈS] Firefox installé avec succès (version : ${final_version})."
  else
    log_error "Firefox semble mal installé ou introuvable dans le PATH."
    return 1
  fi
}

