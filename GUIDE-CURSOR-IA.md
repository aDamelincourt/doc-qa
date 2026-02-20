# Guide d'utilisation de Cursor IA pour la generation de documents QA

## Objectif

Ce guide explique comment l'IA Cursor est integree dans le pipeline QA pour
generer automatiquement les 3 documents de documentation (questions, strategie,
cas de test) a partir des tickets Jira.

---

## Workflow principal (automatique)

### Via le pipeline (recommande)

Le pipeline utilise automatiquement Cursor IA comme voie preponderante.
Il suffit de lancer le traitement d'un ticket :

```bash
# Traiter un ticket via l'API Jira
make process T=SPEX-3143

# Ou directement
./scripts/process-from-api.sh SPEX-3143
```

Le pipeline execute automatiquement la chaine de generation avec 3 niveaux
de fallback :

1. **Cursor IA** (voie preponderante) -- generation directe via `cursor-agent`
2. **Script Bash** (`generate-from-context.sh`) -- generation a partir du contexte extrait
3. **Template placeholder** -- si tout echoue, un template vide est cree

### Via le CLI Jira standalone

```bash
# Extraire le contexte d'un ticket (sortie Markdown)
node dist/cli.js context SPEX-3143 > extraction.md

# Traiter tous les tickets sans doc QA
make process-all
```

---

## Workflow legacy (XML)

Pour les tickets disponibles uniquement en export XML :

```bash
# Traiter un fichier XML
./scripts/process-xml-file.sh "Jira/ACCOUNT/ACCOUNT-2608.xml"
```

Le meme mecanisme de fallback s'applique.

---

## Generation manuelle avec prompts

Si le CLI Cursor n'est pas installe ou que la generation automatique echoue,
les scripts preparent des prompts optimises :

1. Les prompts sont affiches dans la console
2. Copier le prompt dans l'interface Cursor (agent)
3. L'agent genere le document
4. Sauvegarder le resultat dans le fichier cible

### Scripts de generation par type

```bash
# Generer un type de document specifique
./scripts/generate-with-cursor.sh questions projets/ACCOUNT/us-2608
./scripts/generate-with-cursor.sh strategy projets/ACCOUNT/us-2608
./scripts/generate-with-cursor.sh test-cases projets/ACCOUNT/us-2608

# Generer les 3 documents
./scripts/generate-with-cursor.sh all projets/ACCOUNT/us-2608
```

---

## Qualite de generation : Cursor IA vs Bash

| Aspect | Generation Bash | Generation Cursor IA |
|--------|----------------|---------------------|
| Questions | 30-40 | 50-80+ |
| Cas de test | 15-25 scenarios | 30-50+ scenarios |
| Strategie | 8 axes de test | 15+ axes de test |
| Details | Basiques | Contextuels et approfondis |
| Edge cases | Limites | Exhaustifs |

---

## Prerequis

- **CLI Cursor** : Voir [docs/INSTALLATION-CURSOR-CLI.md](docs/INSTALLATION-CURSOR-CLI.md)
  pour l'installation et la configuration de la cle API
- **Configuration avancee** : Voir [docs/CONFIGURATION-CURSOR-IA.md](docs/CONFIGURATION-CURSOR-IA.md)
  pour le detail des 3 options d'integration

---

## Depannage

### La generation automatique ne se lance pas

1. Verifier que le CLI Cursor est installe : `cursor-agent --version`
2. Verifier que `CURSOR_API_KEY` est definie : `echo $CURSOR_API_KEY`
3. Consulter les logs dans `logs/` pour le detail des erreurs

### La generation Bash prend le relais au lieu de Cursor

C'est le comportement attendu si le CLI n'est pas disponible.
Le fallback est transparent -- les documents sont quand meme generes.

### Les documents generes sont trop courts

En mode Bash (fallback), la generation est plus basique.
Installer le CLI Cursor pour obtenir des documents plus complets.

---

## Pipeline complet et sous-agents

Ordre recommande apres generation des documents :

1. **validate** — Valider les documents (automatique apres process)
2. **sync-xray** — Envoyer les cas de test et pas de tests vers Xray (validation lancee avant sync)
3. **sync-notion** — Envoyer 01/02/03 dans Notion (Projet → EPIC → US/Bug)
4. **validator** (sous-agent) — En fin de chaîne : revue qualite, refs Jira, bugs/risques

Les sous-agents Cursor (analyste-req, test-writer, infra-builder, validator) sont decrits dans [.cursor/agents/README.md](.cursor/agents/README.md). Utiliser le sous-agent **validator** en dernier pour verifier la doc et les references Jira.

---

## Voir aussi

- [docs/INSTALLATION-CURSOR-CLI.md](docs/INSTALLATION-CURSOR-CLI.md) -- Installation CLI et cle API
- [docs/CONFIGURATION-CURSOR-IA.md](docs/CONFIGURATION-CURSOR-IA.md) -- Options d'integration
- [scripts/README.md](scripts/README.md) -- Documentation des scripts
- [templates/README.md](templates/README.md) -- Templates de prompts
