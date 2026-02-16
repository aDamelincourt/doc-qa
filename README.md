# Doc QA - Pipeline de documentation QA automatisé

![CI](https://github.com/<owner>/<repo>/actions/workflows/qa-pipeline.yml/badge.svg)
![Tests](https://img.shields.io/badge/tests-123%20passing-brightgreen)
![Coverage](https://img.shields.io/badge/coverage-87%25-brightgreen)

> Remplacer `<owner>/<repo>` par le chemin réel du dépôt GitHub pour activer les badges CI.

Pipeline complet de génération et de synchronisation de documentation QA,
alimenté par l'API Jira Cloud et intégré à Xray Test Management via un
serveur MCP (Model Context Protocol) pour Cursor AI.

---

## Architecture du projet

```
Doc QA/
├── config/
│   └── project.conf              # Configuration centralisée (URLs, limites, retry, etc.)
├── jira-mcp-server/              # Serveur MCP + CLI TypeScript
│   ├── src/
│   │   ├── server.ts             # Serveur MCP — outils Jira pour Cursor AI
│   │   ├── cli.ts                # CLI standalone (detect, context, label, sync-xray, etc.)
│   │   └── lib/
│   │       ├── adf-converter.ts        # Convertisseur ADF -> Markdown
│   │       ├── xray-markdown-parser.ts # Parseur Markdown -> test steps Xray
│   │       ├── xray-client.ts          # Client REST Xray Cloud
│   │       ├── validators.ts           # Validation centralisée (ticket ID, JQL, chemins)
│   │       ├── mcp-error-handler.ts    # Gestion d'erreurs MCP standardisée
│   │       └── retry.ts               # Utilitaire de retry avec backoff exponentiel
│   ├── eslint.config.cjs         # Configuration ESLint (flat config v9+)
│   ├── jest.config.cjs           # Configuration Jest
│   └── package.json
├── scripts/                      # Pipeline Bash
│   ├── qa-pipeline.sh            # Orchestrateur principal (detect, process-all)
│   ├── process-from-api.sh       # Traitement d'un ticket via API Jira
│   ├── validate-docs.sh          # Validation de la documentation générée
│   ├── metrics.sh                # Dashboard de métriques (text, json, markdown)
│   ├── notify.sh                 # Notifications (console, Slack)
│   ├── sync-xray.sh              # Synchronisation Xray test steps
│   └── lib/                      # Bibliothèques Bash partagées
├── tests/                        # Tests Bash
│   ├── run-all-tests.sh          # Runner central
│   ├── test-helpers.sh           # Framework de test Bash
│   ├── test-validate-docs.sh     # Tests validate-docs.sh
│   ├── test-notify.sh            # Tests notify.sh
│   ├── test-metrics.sh           # Tests metrics.sh
│   └── ...
├── templates/                    # Templates Markdown pour la documentation
├── projets/                      # Documentation générée par projet/US
├── Makefile                      # Raccourcis make (process, detect, validate, etc.)
└── .github/workflows/
    └── qa-pipeline.yml           # CI/CD GitHub Actions
```

---

## Prérequis

- **Node.js** >= 20
- **Bash** >= 4
- Variables d'environnement (ou fichier `jira-mcp-server/.env`) :

| Variable              | Description                                     |
| --------------------- | ----------------------------------------------- |
| `JIRA_HOST`           | URL de l'instance Jira (`https://xxx.atlassian.net`) |
| `JIRA_EMAIL`          | Email du compte Jira                            |
| `JIRA_API_TOKEN`      | Token API Jira (Personal Access Token)          |
| `XRAY_CLIENT_ID`      | Client ID Xray Cloud (optionnel)                |
| `XRAY_CLIENT_SECRET`  | Client Secret Xray Cloud (optionnel)            |

---

## Installation

```bash
# Cloner le projet
git clone <url> && cd "Doc QA"

# Installer les dépendances TypeScript
cd jira-mcp-server && npm ci && npm run build && cd ..

# Créer le fichier .env
cp jira-mcp-server/.env.example jira-mcp-server/.env
# Renseigner les variables dans .env
```

---

## Utilisation

### Pipeline complet (Bash)

```bash
# Détecter les tickets sans documentation QA
make detect

# Traiter un ticket spécifique
make process T=SPEX-3143

# Traiter tous les tickets en parallèle
make process-all

# Valider les documents générés
make validate T=SPEX-3143

# Afficher les métriques
make metrics
```

### CLI standalone

```bash
cd jira-mcp-server

# Détecter les tickets (formats : table, json, keys)
node dist/cli.js detect --projects SPEX,ACCOUNT --format table

# Extraire le contexte complet d'un ticket (Markdown)
node dist/cli.js context SPEX-3143

# Ajouter/retirer un label
node dist/cli.js label add SPEX-3143 qa-documented
node dist/cli.js label remove SPEX-3143 qa-documented

# Synchroniser les cas de test vers Xray
node dist/cli.js sync-xray SPEX-3143

# Lire les test steps Xray existants
node dist/cli.js read-xray-steps SPEX-3143
```

### Serveur MCP (Cursor AI)

Le serveur MCP expose les outils Jira directement dans Cursor AI :

- `get_ticket` : récupérer un ticket Jira
- `create_ticket` : créer un ticket
- `add_comment` / `get_comments` : gérer les commentaires
- `update_status` / `get_transitions` : transitions de workflow
- `get_ticket_context` : contexte complet en Markdown
- `find_tickets_needing_qa_docs` : recherche des tickets sans doc QA
- `add_label` / `remove_label` : gestion des labels

Configuration dans `.cursor/mcp.json` :

```json
{
  "mcpServers": {
    "jira-qa": {
      "command": "node",
      "args": ["<chemin>/jira-mcp-server/dist/server.js"]
    }
  }
}
```

---

## Intégration Xray

Le CLI synchronise les cas de test Markdown vers Xray Cloud :

1. Parse le fichier `03-cas-test.md` (scénarios, étapes, résultats attendus)
2. Compare avec les test steps existants dans Xray
3. Crée / met à jour / supprime les steps pour maintenir la synchronisation

```bash
# Synchroniser un ticket
node dist/cli.js sync-xray SPEX-3143

# Vérifier les steps existants
node dist/cli.js read-xray-steps SPEX-3143
```

---

## Configuration

Toutes les valeurs configurables sont centralisées dans `config/project.conf` :

| Paramètre           | Défaut    | Description                                      |
| -------------------- | --------- | ------------------------------------------------ |
| `DEFAULT_PROJECTS`   | `SPEX,...` | Projets Jira surveillés                           |
| `DEFAULT_MAX_TICKETS`| `50`      | Tickets max par exécution                        |
| `PARALLEL_WORKERS`   | `4`       | Workers de traitement parallèle                  |
| `PROCESS_TIMEOUT`    | `300`     | Timeout par ticket (secondes)                    |
| `API_MAX_RETRIES`    | `3`       | Tentatives en cas d'échec réseau                 |
| `API_RETRY_DELAY`    | `2`       | Délai initial de retry (secondes)                |
| `MIN_FILE_SIZE`      | `200`     | Taille minimale des fichiers générés (octets)    |
| `MIN_SCENARIOS`      | `2`       | Nombre minimum de scénarios dans les cas de test |

Les variables d'environnement ont priorité sur `project.conf`.

---

## Sécurité et validation

- **Validation des entrées** : ticket IDs (`^[A-Z][A-Z0-9_]{0,9}-\d{1,7}$`), clés de projet, JQL
- **Protection contre l'injection JQL** : échappement des caractères spéciaux
- **Protection contre le path traversal** : vérification que les chemins restent dans le répertoire de base
- **Gestion centralisée des erreurs** : réponses MCP standardisées (404, auth, rate limiting, réseau)
- **Retry avec backoff exponentiel** : résilience face aux erreurs réseau et rate limiting

---

## Tests

### Tests TypeScript (Jest)

```bash
cd jira-mcp-server

# Exécuter les tests
npm test

# Avec couverture
npx jest --coverage
```

Modules testés :
- `validators.ts` : validation des entrées (24 tests)
- `adf-converter.ts` : conversion ADF -> Markdown
- `xray-markdown-parser.ts` : parsing Markdown -> test steps
- `xray-client.ts` : client Xray Cloud
- `retry.ts` : logique de retry

### Tests Bash

```bash
# Exécuter tous les tests Bash
./tests/run-all-tests.sh

# Mode verbose
VERBOSE=1 ./tests/run-all-tests.sh

# Test spécifique
./tests/test-validate-docs.sh
```

Tests disponibles :
- `test-validate-docs.sh` : validation des documents
- `test-notify.sh` : notifications
- `test-metrics.sh` : métriques
- `test-common-functions.sh` : fonctions utilitaires
- `test-generate-from-context.sh` : génération depuis contexte
- `test-processing-utils.sh` : utilitaires de traitement
- `test-xml-utils.sh` : parsing XML

### Linting et type-checking

```bash
cd jira-mcp-server

# ESLint
npm run lint
npm run lint:fix

# Type-checking TypeScript
npm run type-check
```

---

## CI/CD

Le workflow GitHub Actions (`.github/workflows/qa-pipeline.yml`) s'exécute :

- **Quotidiennement** (lundi-vendredi, 8h UTC) via cron
- **Manuellement** via `workflow_dispatch`

Jobs :

| Job       | Description                                          |
| --------- | ---------------------------------------------------- |
| `detect`  | Détecte les tickets sans documentation QA            |
| `process` | Traite les tickets détectés en parallèle             |
| `test`    | Lint, type-check, tests TypeScript et Bash           |
| `notify`  | Notification Slack (succès / échec)                  |

---

## Structure de la documentation générée

Pour chaque ticket, le pipeline génère :

```
projets/[PROJET]/us-[NUMBER]/
├── README.md                 # Vue d'ensemble du ticket
├── extraction-jira.md        # Contexte extrait de Jira
├── 01-questions.md           # Questions et clarifications
├── 02-strategie.md           # Stratégie de test
└── 03-cas-test.md            # Cas de test détaillés (synchronisés vers Xray)
```

---

## Workflow de documentation QA

1. **Détection** : le pipeline identifie les tickets Jira sans le label `qa-documented`
2. **Extraction** : le contexte complet du ticket est extrait via l'API Jira (description, commentaires, liens, sous-tâches)
3. **Génération** : les 3 documents de documentation QA sont générés à partir du contexte
4. **Validation** : les documents sont validés (taille, structure, sections obligatoires)
5. **Synchronisation Xray** : les cas de test sont synchronisés vers Xray Test Management
6. **Labelling** : le label `qa-documented` est appliqué au ticket Jira
7. **Notification** : une notification résume le traitement (succès, échecs, métriques)

---

## Contact

Pour toute question sur ce projet, contacter l'équipe QA.
