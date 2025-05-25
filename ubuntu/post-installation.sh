#!/bin/bash

# Désactiver l'option d'extension verticale de Dash to Dock
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false

# Positionner le dock en bas de l'écran
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'

# Fixer la transparence du dock en mode "FIXED"
gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'FIXED'

# Rendre le fond du dock totalement transparent
gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0

# Activer la minimisation par clic sur une application dans le dock
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'

# Masquer l'icône du dossier personnel sur le bureau
gsettings set org.gnome.shell.extensions.ding show-home false

# center les nouvelles fenêtres
gsettings set org.gnome.mutter center-new-windows true

#######################################################################################
# Économies d'énergie
#######################################################################################

# Activer le profil d'énergie "Performance"
powerprofilesctl set performance

# Afficher le pourcentage de batterie dans la barre système
gsettings set org.gnome.desktop.interface show-battery-percentage true

# Éteindre l'écran après 10 minutes d'inactivité
gsettings set org.gnome.desktop.session idle-delay 600

#######################################################################################
# Lumière nocturne et température des couleurs
#######################################################################################

# Désactiver la lumière nocturne
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled false

# Définir la température de couleur à 4000K (si activé)
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4000

#######################################################################################
# Espaces de travail fixes
#######################################################################################

# Désactiver les espaces de travail dynamiques
gsettings set org.gnome.mutter dynamic-workspaces false

# Fixer le nombre d'espaces de travail à 4
gsettings set org.gnome.desktop.wm.preferences num-workspaces 4

#######################################################################################
# Raccourcis clavier
#######################################################################################

# Aller à un espace de travail spécifique (Super + chiffre)
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<Shift><Super>KP_End']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<Shift><Super>KP_Down']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<Shift><Super>KP_Next']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-4 "['<Shift><Super>KP_Left']"

# Déplacer une fenêtre vers un espace de travail spécifique (Alt + chiffre)
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-1 "['<Alt>KP_End']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-2 "['<Alt>KP_Down']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-3 "['<Alt>KP_Next']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-4 "['<Alt>KP_Left']"

#######################################################################################
# Masquage automatique du dock
#######################################################################################

# Désactiver le mode "dock toujours visible"
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false

# Désactiver le masquage intelligent du dock
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide false

# Désactiver le masquage auto en plein écran
gsettings set org.gnome.shell.extensions.dash-to-dock autohide-in-fullscreen false

# Activer le masquage automatique
gsettings set org.gnome.shell.extensions.dash-to-dock autohide true

#######################################################################################
# Exclure les volumes non montés du dock
#######################################################################################

gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false

#######################################################################################
# Configuration de Gnome Text Editor
#######################################################################################

# Police personnalisée : FiraCode Retina
gsettings set org.gnome.TextEditor custom-font "FiraCode Nerd Font Retina 12"

# Surligner la ligne actuelle
gsettings set org.gnome.TextEditor highlight-current-line true

# Activer la numérotation des lignes
gsettings set org.gnome.TextEditor show-line-numbers true

# Activer la vue d'ensemble (map)
gsettings set org.gnome.TextEditor show-map true

# Définir une marge à 80 caractères
gsettings set org.gnome.TextEditor right-margin-position 80

# Désactiver la correction orthographique
gsettings set org.gnome.TextEditor spellcheck false

# Activer l'indentation automatique
gsettings set org.gnome.TextEditor auto-indent true

# Utiliser des espaces pour l'indentation avec une largeur de 2
gsettings set org.gnome.TextEditor indent-style 'space'
gsettings set org.gnome.TextEditor indent-width 2

