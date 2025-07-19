#!/usr/bin/env bash
################################################################################
# check_caller_script.sh
#
# Description :
# Ce module vérifie que le script courant a été appelé depuis un fichier autorisé,
# en analysant le parent du processus (`PPID`). Il bloque l'exécution si
# l’appelant n’est pas celui attendu.
#
# Auteur : Magali + Copilot
#
# Usage :
# Ce script doit être sourcé par un script secondaire.
# À inclure via : source check_caller_script.sh
################################################################################

# -----------------------------------------------------------------------------
# Fonction : check_caller_script
# -----------------------------------------------------------------------------
check_caller_script() {
  local expected_caller="run_build.sh"
  local caller_cmdline
  local caller_script

  # Récupération de la ligne de commande du processus parent
  caller_cmdline=$(ps -o args= -p "${PPID}" | tr -d '\n')

  # Extraction du nom de fichier (dernier élément du chemin)
  caller_script=$(basename "${caller_cmdline}")

  log_debug "Script appelant détecté : ${caller_script}"
  log_debug "Script autorisé attendu : ${expected_caller}"

  # Vérification
  if [[ "${caller_script}" != "${expected_caller}" ]]; then
    log_error "Ce module ne doit être lancé que depuis ${expected_caller}."
    log_error "Appel détecté depuis : ${caller_script}"
    return 1
  fi

  log_info "Appelant vérifié : ${caller_script} est autorisé."
  return 0
}
