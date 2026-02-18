# Configuration de l'IA Cursor comme Voie Preponderante

> **Prerequis** : Installer le CLI Cursor et configurer la cle API en suivant
> le guide [INSTALLATION-CURSOR-CLI.md](INSTALLATION-CURSOR-CLI.md).

---

## Les 3 Options d'Integration

### Option 1 : CLI Cursor avec Generation Directe (Recommandee)

Les scripts utilisent le CLI Cursor (`cursor-agent`) pour generer directement
les documents QA, sans intervention manuelle. C'est la voie preponderante.

```bash
./scripts/process-from-api.sh SPEX-3143
# Les 3 documents sont generes automatiquement avec Cursor IA
```

### Option 2 : Mode Prompt avec Fallback Automatique

Si le CLI n'est pas disponible, les scripts preparent des prompts optimises
pour un traitement manuel (copier-coller dans l'interface Cursor).
Aucune configuration necessaire -- le fallback est automatique.

### Option 3 : Mode Mixte (CLI + Fallback)

Les scripts tentent d'abord le CLI, puis basculent vers le mode prompt.
C'est le comportement par defaut : degradation gracieuse.

---

## Flux de Generation

```
process-from-api.sh / process-xml-file.sh
    |
    v
generate_document_directly()   <-- voie preponderante
    |
    +-- CLI disponible ? --> cursor-agent -p --force --> Document genere
    |
    +-- CLI absent ?     --> Prompt affiche (fallback)
    |
    +-- Echec CLI ?      --> generate-from-context.sh (fallback Bash)
    |
    +-- Echec total ?    --> Placeholder template
```

## Modifications Apportees aux Scripts

### `scripts/lib/cursor-ai-utils.sh`

- `generate_with_cursor_agent()` : detecte `cursor-agent` ou `cursor`,
  utilise le CLI en mode non-interactif, et bascule vers le mode prompt
  si le CLI est absent.
- `generate_document_directly()` : fonction principale pour la generation
  directe, prepare le contexte et appelle `generate_with_cursor_agent()`.

### `scripts/process-from-api.sh` et `scripts/process-xml-file.sh`

Chargent `cursor-ai-utils.sh` et utilisent `generate_document_directly()`
comme voie principale. Si Cursor IA echoue, bascule vers
`generate-from-context.sh`, puis vers des templates placeholder.

---

## Voir aussi

- [INSTALLATION-CURSOR-CLI.md](INSTALLATION-CURSOR-CLI.md) -- Installation du CLI et configuration de la cle API
- [../GUIDE-CURSOR-IA.md](../GUIDE-CURSOR-IA.md) -- Guide d'utilisation de Cursor IA pour la generation QA
