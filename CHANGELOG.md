# Changelog

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/),
et ce projet adhère au [Versioning Sémantique](https://semver.org/lang/fr/).

## [1.1.0] - 2026-02-16

### Ajouté

- **Validation centralisée des entrées** (`validators.ts`) : regex ticket ID, clés de projet,
  échappement JQL, protection path traversal, avec 24 tests unitaires.
- **Gestion centralisée des erreurs MCP** (`mcp-error-handler.ts`) : catégorisation des erreurs
  (404, auth, rate limiting, réseau) et réponses standardisées pour l'IA.
- **Retry avec backoff exponentiel** (`retry.ts`) : résilience face aux erreurs réseau et rate
  limiting, avec timeout par tentative et callback `onRetry`.
- **Client Xray Cloud** (`xray-client.ts`) : authentification JWT, requêtes GraphQL, lecture
  et synchronisation bidirectionnelle des test steps.
- **Parseur Markdown -> Xray** (`xray-markdown-parser.ts`) : extraction des scénarios, étapes,
  résultats attendus depuis `03-cas-test.md`.
- **CLI standalone** (`cli.ts`) : commandes `detect`, `context`, `label`, `sync-xray`,
  `read-xray-steps` pour le pipeline Bash.
- **ESLint** : configuration flat config v9+ avec règles TypeScript strictes, intégré à la CI.
- **Tests E2E** (18 tests) : flux complet Markdown -> parse -> validate -> convert -> sync Xray
  avec mocks fetch.
- **Tests Bash** : `test-validate-docs.sh`, `test-notify.sh`, `test-metrics.sh` ajoutés au runner.
- **Coverage reporting** : Jest configuré avec seuils (70% lignes, 55% branches), rapport lcov,
  artefact CI, badge README (87% statements).
- **Configuration centralisée** (`config/project.conf`) : toutes les valeurs hardcodées migrées
  vers le fichier de configuration ou variables d'environnement.
- **Trap cleanup** : nettoyage garanti du répertoire temporaire dans `qa-pipeline.sh` en cas
  d'interruption (INT, TERM).
- **CI/CD GitHub Actions** : jobs detect, process, test (lint + type-check + Jest + Bash), notify.
- **Makefile** : raccourcis `make detect`, `make process`, `make validate`, `make metrics`, etc.

### Modifié

- **Typage strict** : tous les `any` remplacés par des interfaces TypeScript dans `server.ts`,
  `cli.ts` et `adf-converter.ts`. Interfaces `CreateIssueFields`, `AdfNodeAttrs`, `AdfMarkAttrs`.
- **Logging des erreurs** : `2>/dev/null` remplacé par `2>>"$LOG_FILE"` pour les appels API
  critiques dans `qa-pipeline.sh` et `process-from-api.sh`.
- **README.md** : refonte complète avec architecture, prérequis, installation, utilisation,
  configuration, sécurité, tests, CI/CD.
- **`.gitignore`** : ajout de `node_modules/`, `dist/`, `*.tsbuildinfo`, `coverage/`, `logs/`.

### Sécurité

- Protection contre l'injection JQL via échappement des caractères spéciaux.
- Protection contre le path traversal via vérification des chemins résolus.
- Validation regex stricte des ticket IDs et clés de projet.
- Suppression des credentials hardcodés dans la documentation.

## [1.0.0] - 2025-01-01

### Ajouté

- Structure initiale du projet Doc QA.
- Scripts Bash de traitement XML Jira (`process-xml-file.sh`, `regenerate-all-docs.sh`).
- Templates Markdown pour la documentation QA.
- Serveur MCP initial avec outils Jira de base (`get_ticket`, `create_ticket`, etc.).
- Convertisseur ADF -> Markdown (`adf-converter.ts`).
- Export Notion.
- Tests Bash initiaux (`test-common-functions.sh`, `test-xml-utils.sh`).
