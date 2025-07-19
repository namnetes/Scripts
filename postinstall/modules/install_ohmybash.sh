#!/usr/bin/env bash
################################################################################
# install_oh_my_bash.sh
#
# Description :
# Ce module installe Oh My Bash pour l’utilisateur original (sudo).
# - Vérifie le répertoire personnel via getent
# - Vérifie la présence de l’installation précédente
# - Télécharge et exécute le script officiel d’installation en tant qu’utilisateur original
# - Valide la présence de ~/.oh-my-bash et de la configuration dans .bashrc
#
# Oh My Bash est installé uniquement dans l’espace utilisateur ayant initié
# le script avec sudo (via $SUDO_USER). Le module est idempotent.
#
# Auteur : Magali + Copilot
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
# install_oh_my_bash : Installe Oh My Bash pour l’utilisateur sudo original
################################################################################
install_oh_my_bash() {
  log_info "[INSTALLATION] Initialisation de Oh My Bash."

  local original_user="${SUDO_USER}"
  local original_user_home
  original_user_home=$(getent passwd "${original_user}" | cut -d: -f6)

  if [ -z "${original_user_home}" ]; then
    log_error "Impossible de déterminer le répertoire personnel de ${original_user}."
    return 1
  fi

  local ohmb_dir="${original_user_home}/.oh-my-bash"
  local bashrc_path="${original_user_home}/.bashrc"

  # 1. Vérification idempotente
  if [ -d "${ohmb_dir}" ]; then
    if [ -f "${bashrc_path}" ] && sudo -u "${original_user}" grep -q 'plugins=(ohmybash)' "${bashrc_path}"; then
      log_info "  [STATUT] Oh My Bash est déjà installé et configuré pour ${original_user}."
      return 0
    else
      log_warning "  [WARNING] Oh My Bash est présent mais la configuration semble incomplète dans .bashrc."
      log_warning "  [CONSEIL] Vérifiez ou restaurez la configuration manuellement si nécessaire."
      return 0
    fi
  fi

  # 2. Installation via script officiel
  log_info "  [ACTION] Oh My Bash non détecté. Téléchargement et installation..."
  if ! sudo -u "${original_user}" HOME="${original_user_home}" bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"; then
    log_error "L’installation d’Oh My Bash a échoué pour ${original_user}."
    return 1
  fi

  # 3. Vérification post-installation
  if [ -d "${ohmb_dir}" ] && [ -f "${bashrc_path}" ] && sudo -u "${original_user}" grep -q 'plugins=(ohmybash)' "${bashrc_path}"; then
    log_info "[SUCCÈS] Oh My Bash installé et configuré pour ${original_user}."
    log_info "[NOTE] Pensez à sourcer ~/.bashrc ou redémarrer le terminal."
  else
    log_error "Oh My Bash semble mal installé ou absent dans .bashrc."
    return 1
  fi
}
