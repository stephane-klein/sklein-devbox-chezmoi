#!/bin/bash
# Script pour mettre à jour la completion zsh de Jujutsu (jj)

set -euo pipefail

COMPLETIONS_DIR="${HOME}/.config/zsh/completions"

# Vérifier que jj est disponible
if ! command -v jj &> /dev/null; then
    echo "Erreur: jj n'est pas installé ou n'est pas dans le PATH" >&2
    exit 1
fi

# Créer le répertoire si nécessaire
mkdir -p "$COMPLETIONS_DIR"

# Générer le fichier de completion
jj util completion zsh > "${COMPLETIONS_DIR}/_jj"

echo "✓ Completion Jujutsu mise à jour dans ${COMPLETIONS_DIR}/_jj"
echo "  Redémarrez votre terminal ou exécutez 'exec zsh' pour appliquer les changements"
