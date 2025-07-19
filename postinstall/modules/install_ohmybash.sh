#!/usr/bin/env bash
################################################################################
# install_oh_my_bash.sh
#
# Description :
# Ce module installe Oh My Bash pour l’utilisateur original (sudo).
# - Vérifie le répertoire personnel via getent
# - Refuse l’installation si Oh My Bash est déjà présent ou trace dans .bashrc
#
# Auteur : Magali + Copilot ✨
#
# Usage :
# Ce script doit être sourcé depuis un script principal.
################################################################################

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && {
  echo "Ce script doit être sourcé depuis un script principal." >&2
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

  # 🔒 Blocage si traces existantes
  if [ -d "${ohmb_dir}" ]; then
    log_error "Installation refusée : répertoire ${ohmb_dir} déjà présent."
    log_error "Veuillez supprimer ce répertoire manuellement si une réinstallation est souhaitée."
    return 1
  fi

  if [ -f "${bashrc_path}" ] && sudo -u "${original_user}" grep -q -i 'oh[-_]my[-_]bash' "${bashrc_path}"; then
    log_error "Installation refusée : fichier .bashrc contient des traces d’Oh My Bash."
    log_error "Corrigez ou purgez .bashrc avant de relancer ce module."
    return 1
  fi

  # 🧰 Téléchargement et installation via script officiel
  log_info "  [ACTION] Téléchargement et installation d'Oh My Bash..."
  if ! sudo -u "${original_user}" HOME="${original_user_home}" bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"; then
    log_error "L’installation d’Oh My Bash a échoué pour ${original_user}."
    return 1
  fi

  # ✅ Vérification post-installation
  if [ -d "${ohmb_dir}" ] && [ -f "${bashrc_path}" ] && \
     sudo -u "${original_user}" grep -q 'oh-my-bash.sh' "${bashrc_path}"; then
    log_info "[SUCCÈS] Oh My Bash installé et configuré pour ${original_user}."
    log_info "[NOTE] Pensez à sourcer ~/.bashrc ou redémarrer le terminal."
  else
    log_error "Oh My Bash semble mal installé ou non configuré correctement."
    return 1
  fi
}
