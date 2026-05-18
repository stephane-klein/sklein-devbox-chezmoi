---
name: sklein-create-node-project
description: Créer un nouveau projet Node.js basé sur les préférences de Stéphane Klein.
---

# sklein-create-node-project

Créer un nouveau projet Node.js basé sur les préférences de Stéphane Klein.

## Déclencheur

Ce skill est activé lorsque l'utilisateur demande de créer un projet Node.js, par exemple :
- "crée un projet node"
- "initie un projet JS"
- "crée un projet nodejs"

## Collecte des informations

Si l'utilisateur n'a pas fourni de `PROJECT_SHORT_DESCRIPTION`, l'agent doit lui demander brièvement avant de procéder :

> *« Quel est le but de ce projet ? (1–2 phrases) »*

Si l'utilisateur refuse de donner une description, l'agent peut utiliser une chaîne vide et continuer la génération.

### Question sur Jujutsu

L'agent doit demander à l'utilisateur (use question tool) :

> *« Utiliserez-vous Jujutsu (jj) pour ce projet ? (Oui/Non) »*

- Si **Oui** : `USE_JUJUTSU = true`
- Si **Non** : `USE_JUJUTSU = false`

Cette information sera transmise au template `AGENTS.md`.

### Amélioration de la description

Si l'utilisateur a fourni une `PROJECT_SHORT_DESCRIPTION`, l'agent évalue si elle est suffisante et optimale en termes de :
- Clarté
- Concision
- Orthographe et grammaire

Si la description semble insuffisante ou non optimale, l'agent la reformule directement en anglais (une seule version).

Cette version reformulée est utilisée directement dans les templates, sans validation utilisateur.

## Paramètres

- **`PROJECT_NAME`** (requis) : nom du projet. Peut contenir des tirets, pas d'espaces.
- **`PROJECT_SHORT_DESCRIPTION`** : courte explication du projet et de son but (1–2 phrases).
- **`TARGET_DIR`** (optionnel) : chemin absolu ou relatif du répertoire cible. Par défaut : le dossier courant.

## Valeurs fixes

- **`AUTHOR_NAME`** = `Stéphane Klein`

## Récupération automatique des versions

Avant toute génération, l'agent doit récupérer dynamiquement :

1. **Dernière version LTS de Node.js** via `https://nodejs.org/dist/index.json` :
   - Filtrer les entrées où `lts` n'est pas `false`.
   - Trier par `date` décroissante et prendre la dernière version (ex: `22.14.0`).
   - Ne garder que le numéro de version, sans le préfixe `v`.

2. **Dernière version de pnpm** via `curl -s https://registry.npmjs.org/pnpm/latest | jq -r '.version'` :
   - Exemple de résultat : `10.8.0`

Si l'une de ces deux requêtes échoue ou retourne une donnée inutilisable, l'agent **doit échouer proprement** et informer l'utilisateur que la création du projet est impossible sans les versions à jour.

## Vérification des conflits

Avant d'écrire quoi que ce soit, l'agent doit vérifier si les fichiers cibles existent déjà dans `TARGET_DIR` :

- `.mise.toml`
- `.gitignore`
- `AGENTS.md`
- `README.md`
- `package.json`

Si un ou plusieurs de ces fichiers existent déjà, l'agent doit **prévenir l'utilisateur**, lister les fichiers concernés, et **demander une confirmation explicite** avant d'écraser. Sans confirmation, l'opération s'arrête.

## Génération des fichiers

Une fois les versions récupérées et les conflits résolus (ou confirmés par l'utilisateur), l'agent doit :

1. **Lire les templates** situés dans le répertoire `template/` à côté de ce `SKILL.md` :
   - `template/.mise.toml`
   - `template/.gitignore`
   - `template/AGENTS.md`
   - `template/README.md`
   - `template/package.json`

2. **Substituer les placeholders** dans le contenu de chaque template :

| Placeholder | Valeur |
|---|---|---|
| `{{PROJECT_NAME}}` | `PROJECT_NAME` |
| `{{PROJECT_SHORT_DESCRIPTION}}` | `PROJECT_SHORT_DESCRIPTION` (peut être vide) |
| `{{AUTHOR_NAME}}` | `Stéphane Klein` |
| `{{LAST_NODE_LTS_VERSION}}` | Version Node.js LTS récupérée |
| `{{LAST_PNPM_VERSION}}` | Version pnpm récupérée |
| `{{USE_JUJUTSU}}` | `true` si Jujutsu sera utilisé, sinon `false` |

1. **Écrire les fichiers** dans le répertoire cible `TARGET_DIR` :

| Fichier cible | Template source |
|---|---|
| `.mise.toml` | `template/.mise.toml` |
| `.gitignore` | `template/.gitignore` |
| `AGENTS.md` | `template/AGENTS.md` |
| `README.md` | `template/README.md` |
| `package.json` | `template/package.json` |

**Important** : le fichier `AGENTS.md` contient le `PROJECT_SHORT_DESCRIPTION` en plus des instructions de langue.

**L'agent ne doit PAS exécuter `pnpm install` ni aucune autre commande d'installation.**

## Arrêt strict après initialisation

**Ce skill a un périmètre strict : initialiser le projet et rien d'autre.**

Une fois les fichiers créés et la confirmation envoyée, l'agent **doit s'arrêter**. Il ne doit en aucun cas :

- Commencer à coder de la logique métier, des composants, ou du code source quelconque
- Exécuter des commandes (`pnpm install`, `pnpm dev`, `pnpm build`, `pnpm test`, `git init`, etc.)
- Créer des fichiers supplémentaires au-delà des 5 templates
- Continuer le développement du projet de quelque manière que ce soit

L'initialisation est **terminée** quand les fichiers sont écrits. L'utilisateur décidera lui-même de la suite.

## Confirmation finale

Après avoir écrit les fichiers, l'agent confirme le succès à l'utilisateur en listant les fichiers créés et le répertoire cible, **puis s'arrête**.
