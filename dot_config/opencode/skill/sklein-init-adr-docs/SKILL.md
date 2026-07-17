---
name: sklein-init-adr-docs
description: Initialize ADR/agents/docs infrastructure in a project
---

# sklein-init-adr-docs

Initialise l'infrastructure de documentation ADR + agents + skills locaux
dans un projet.

## Prérequis

- Le projet a un fichier `AGENTS.md` à la racine

## Actions

### 1. Créer `docs/decisions/README.md`

Copier depuis `templates/decisions-readme.md`.

### 2. Créer `docs/agents/README.md`

Copier depuis `templates/agents-readme.md`.

### 3. Ajouter la section dans AGENTS.md

Si la section `## Supplementary Documentation` n'existe pas déjà, l'ajouter
avant `## Documentation Maintenance`. Sinon, juste vérifier que les liens
vers `docs/agents/` et `docs/decisions/` sont présents.

```markdown
## Supplementary Documentation

- [`docs/agents/`](docs/agents/) — operational snapshots of subsystems (loaded on demand by the agent)
- [`docs/decisions/`](docs/decisions/) — architecture decision records
- `.opencode/skills/new-decision/` — skill for creating new decision records
```

### 4. Créer `.opencode/skills/new-decision/SKILL.md`

Copier depuis `templates/local-new-decision-skill.md`.

## Fichiers créés / modifiés

| Fichier | Action |
|---|---|
| `docs/decisions/README.md` | Créé |
| `docs/agents/README.md` | Créé |
| `AGENTS.md` | Modifié (section Supplementary Documentation ajoutée) |
| `.opencode/skills/new-decision/SKILL.md` | Créé |
