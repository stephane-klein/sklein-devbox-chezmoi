---
name: sklein-markdown
description: "Préférences Markdown de Stéphane Klein. Conventions de formatage pour les listes, les tableaux, la structure et la mise en forme."
---

# sklein-markdown

Conventions de formatage Markdown pour toute rédaction.

## Général

- Utiliser `-` pour les listes à puces (pas `*`).
- Utiliser `**gras**` pour l'emphase (pas `__gras__` ni `*italique*` pour l'emphase principale).

## Listes

### Espacement des listes

**Format préféré** : une ligne vide sépare le paragraphe introductif de la liste, mais pas de ligne vide au sein de la liste.

```markdown
Paragraphe:

- item 1
- item 2
  - item 2.1
  - item 2.2
- item 3
```

**Format à éviter** : pas de ligne vide entre le paragraphe et la liste, ni de ligne vide au milieu de la liste.

```markdown
Paragraphe:
- item 1
- item 2
  - item 2.1
  - item 2.2

- item 3
```

### Listes imbriquées

- Utiliser 2 espaces pour l'indentation des sous-listes.
- Ne pas insérer de ligne vide entre un item parent et ses enfants.

## Tableaux

- Utiliser des tableaux Markdown avec les colonnes alignées via les deux-points `:`.
- Aligner à gauche `:---`, centrer `:---:`, aligner à droite `---:`.

Exemple :

```markdown
| Colonne 1 | Colonne 2 | Colonne 3 |
|:----------|:---------:|----------:|
| Gauche    | Centré    | Droite    |
```

## Scope

Ces conventions s'appliquent à tout Markdown, sauf si le projet concerné définit déjà ses propres conventions de formatage.
