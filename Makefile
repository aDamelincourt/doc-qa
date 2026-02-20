# =============================================================================
# Makefile — Point d'entrée unique pour le projet Doc QA
#
# Usage :
#   make help           Affiche toutes les commandes disponibles
#   make setup          Installe et configure le projet
#   make detect         Détecte les tickets à documenter
#   make process T=ID   Traite un ticket spécifique
#   make process-all    Traite tous les tickets non documentés
# =============================================================================

# Configuration par défaut (surchargeable)
PROJECTS ?= SPEX,ACCOUNT,MME,EB,DATA
MAX ?= 50
T ?=
DAYS ?= 90
FORMAT ?= table
J ?= 0

# Chemins
SCRIPTS_DIR := scripts
PIPELINE := $(SCRIPTS_DIR)/qa-pipeline.sh
PROCESS_API := $(SCRIPTS_DIR)/process-from-api.sh
PROCESS_XML := $(SCRIPTS_DIR)/process-xml-file.sh
CLI_DIR := jira-mcp-server
CLI := node $(CLI_DIR)/dist/cli.js

.PHONY: help setup build detect process process-force process-all process-all-dry \
        generate process-xml process-unprocessed status \
        sync-xray sync-xray-dry read-xray-steps connection-test \
        validate metrics update-readmes export-notion sync-notion archive test clean

# ─── Aide ────────────────────────────────────────────────────────────────────

help: ## Affiche cette aide
	@echo ""
	@echo "  Doc QA — Pipeline de documentation QA automatisé"
	@echo ""
	@echo "  SETUP :"
	@grep -E '^(setup|build)' $(MAKEFILE_LIST) | grep '##' | awk -F ':|##' '{printf "    make %-20s %s\n", $$1, $$NF}'
	@echo ""
	@echo "  PIPELINE (API Jira Cloud) :"
	@grep -E '^(detect|process-all|process[^-]|generate|status)' $(MAKEFILE_LIST) | grep '##' | awk -F ':|##' '{printf "    make %-20s %s\n", $$1, $$NF}'
	@echo ""
	@echo "  XRAY CLOUD :"
	@grep -E '^(sync-xray|read-xray)' $(MAKEFILE_LIST) | grep '##' | awk -F ':|##' '{printf "    make %-20s %s\n", $$1, $$NF}'
	@echo ""
	@echo "  CONNEXION :"
	@grep -E '^connection-test:' $(MAKEFILE_LIST) | grep '##' | awk -F ':|##' '{printf "    make %-20s %s\n", $$1, $$NF}'
	@echo ""
	@echo "  LEGACY (fichiers XML) :"
	@grep -E '^(process-xml|process-unprocessed)' $(MAKEFILE_LIST) | grep '##' | awk -F ':|##' '{printf "    make %-20s %s\n", $$1, $$NF}'
	@echo ""
	@echo "  VALIDATION & METRIQUES :"
	@grep -E '^(validate|metrics):' $(MAKEFILE_LIST) | grep '##' | awk -F ':|##' '{printf "    make %-20s %s\n", $$1, $$NF}'
	@echo ""
	@echo "  OUTILS :"
	@grep -E '^(update-readmes|export-notion|sync-notion|archive|test|clean)' $(MAKEFILE_LIST) | grep '##' | awk -F ':|##' '{printf "    make %-20s %s\n", $$1, $$NF}'
	@echo ""
	@echo "  VARIABLES :"
	@echo "    PROJECTS=SPEX,ACCOUNT    Projets Jira (défaut: $(PROJECTS))"
	@echo "    T=SPEX-3143              Ticket ID pour 'make process'"
	@echo "    K=SPEX-3200              Clé du ticket Test Xray (pour sync-xray)"
	@echo "    MAX=10                   Nombre max de tickets (défaut: $(MAX))"
	@echo "    DAYS=90                  Jours pour l'archivage (défaut: $(DAYS))"
	@echo "    FORMAT=json              Format de sortie (table|json|keys)"
	@echo "    J=4                      Nombre de workers paralleles (process-all)"
	@echo "    FORCE=1                  Forcer la synchronisation Xray"
	@echo "    STRICT=1                 Validation stricte (validate)"
	@echo "    CONNECTION_TEST_WRITE=1  Inclure test d'écriture (connection-test)"
	@echo "    TICKET=SPEX-3143         Ticket pour test d'écriture (connection-test)"
	@echo "    NOTION_API_KEY=...       Secret intégration Notion (sync-notion)"
	@echo "    NOTION_PARENT_PAGE_ID=... Page racine Doc QA dans Notion (sync-notion)"
	@echo ""

# ─── Setup ───────────────────────────────────────────────────────────────────

setup: ## Installe les dépendances et configure le projet
	@echo "Installation des dépendances du CLI Jira..."
	@cd $(CLI_DIR) && npm install
	@echo ""
	@echo "Build du CLI..."
	@cd $(CLI_DIR) && npm run build
	@echo ""
	@if [ ! -f $(CLI_DIR)/.env ]; then \
		echo "Création du fichier .env..."; \
		cp $(CLI_DIR)/.env.example $(CLI_DIR)/.env; \
		echo ""; \
		echo "IMPORTANT : Renseigner les identifiants dans $(CLI_DIR)/.env"; \
		echo "  - JIRA_EMAIL : ton email Atlassian"; \
		echo "  - JIRA_API_TOKEN : token depuis https://id.atlassian.com/manage-profile/security/api-tokens"; \
	else \
		echo "Fichier .env déjà configuré."; \
	fi
	@echo ""
	@echo "Setup terminé."

build: ## Rebuild le CLI Jira (après modification de cli.ts ou server.ts)
	@cd $(CLI_DIR) && npm run build

# ─── Pipeline API ────────────────────────────────────────────────────────────

detect: ## Détecte les tickets sans documentation QA
	@bash $(PIPELINE) detect --projects $(PROJECTS) --max $(MAX) --format $(FORMAT)

process: ## Traite un ticket via l'API Jira (T=TICKET-ID)
	@if [ -z "$(T)" ]; then \
		echo "Erreur : spécifier le ticket avec T=TICKET-ID"; \
		echo "  Exemple : make process T=SPEX-3143"; \
		exit 1; \
	fi
	@bash $(PIPELINE) process $(T)

process-force: ## Traite un ticket en forçant la régénération (T=TICKET-ID)
	@if [ -z "$(T)" ]; then \
		echo "Erreur : spécifier le ticket avec T=TICKET-ID"; \
		exit 1; \
	fi
	@bash $(PIPELINE) process $(T) --force

generate: ## Régénère les docs depuis extraction-jira.md (T=TICKET-ID ou D=projets/X/us-NNN)
	@if [ -n "$(D)" ]; then \
		bash $(SCRIPTS_DIR)/generate-from-context.sh all "$(D)"; \
	elif [ -n "$(T)" ]; then \
		PROJECT=$$(echo "$(T)" | sed 's/-[0-9]*//'); \
		NUM=$$(echo "$(T)" | sed 's/[A-Z]*-//'); \
		bash $(SCRIPTS_DIR)/generate-from-context.sh all "projets/$$PROJECT/us-$$NUM"; \
	else \
		echo "Erreur : spécifier T=TICKET-ID ou D=projets/PROJ/us-NNN"; \
		exit 1; \
	fi

process-all: ## Traite tous les tickets non documentes (J=N pour paralleliser)
	@bash $(PIPELINE) process-all --projects $(PROJECTS) --max $(MAX) $(if $(filter-out 0,$(J)),--parallel $(J),)

process-all-dry: ## Dry-run : voir ce qui serait traité sans rien faire
	@bash $(PIPELINE) process-all --projects $(PROJECTS) --max $(MAX) --dry-run

status: ## Affiche l'état du pipeline (tickets traités/en attente)
	@bash $(PIPELINE) status $(PROJECTS)

# ─── Xray Cloud ──────────────────────────────────────────────────────────────

sync-xray: ## Synchronise les cas de test vers Xray (T=TICKET-ID, K=TEST-KEY)
	@if [ -z "$(T)" ]; then \
		echo "Erreur : spécifier le ticket avec T=TICKET-ID"; \
		echo "  Exemple : make sync-xray T=SPEX-3143"; \
		echo "  Avec clé Test : make sync-xray T=SPEX-3143 K=SPEX-3200"; \
		exit 1; \
	fi
	@bash $(SCRIPTS_DIR)/sync-xray.sh $(T) $(if $(K),--test-key $(K),) $(if $(FORCE),--force,)

sync-xray-dry: ## Dry-run Xray, voir les steps qui seraient synchronisés (T=TICKET-ID)
	@if [ -z "$(T)" ]; then \
		echo "Erreur : spécifier le ticket avec T=TICKET-ID"; \
		exit 1; \
	fi
	@bash $(SCRIPTS_DIR)/sync-xray.sh $(T) $(if $(K),--test-key $(K),) --dry-run

read-xray-steps: ## Lit les test steps existants depuis Xray (T=TICKET-ID, FORMAT=text|json|markdown)
	@if [ -z "$(T)" ]; then \
		echo "Erreur : spécifier le ticket avec T=TICKET-ID"; \
		exit 1; \
	fi
	@node $(CLI_DIR)/dist/cli.js read-xray-steps $(T) $(if $(FORMAT),--format $(FORMAT),)

connection-test: ## Teste la connexion Jira Cloud et Xray (lecture ; CONNECTION_TEST_WRITE=1 et TICKET=KEY pour écriture)
	@if [ ! -f $(CLI_DIR)/dist/cli.js ]; then $(MAKE) -C $(CLI_DIR) build; fi
	@bash $(SCRIPTS_DIR)/connection-test.sh $(if $(CONNECTION_TEST_WRITE),--write,) $(if $(TICKET),--ticket $(TICKET),)

# ─── Legacy (XML) ───────────────────────────────────────────────────────────

process-xml: ## Traite un fichier XML Jira (T=chemin/vers/fichier.xml)
	@if [ -z "$(T)" ]; then \
		echo "Erreur : spécifier le fichier XML avec T=chemin/fichier.xml"; \
		echo "  Exemple : make process-xml T=Jira/SPEX/SPEX-3143.xml"; \
		exit 1; \
	fi
	@bash $(PROCESS_XML) $(T)

process-unprocessed: ## Traite tous les XML non encore traités
	@bash $(SCRIPTS_DIR)/process-unprocessed.sh

# ─── Validation ──────────────────────────────────────────────────────────────

validate: ## Valide la qualite des documents generes (T=TICKET-ID ou D=chemin)
	@if [ -n "$(D)" ]; then \
		bash $(SCRIPTS_DIR)/validate-docs.sh "$(D)" $(if $(STRICT),--strict,); \
	elif [ -n "$(T)" ]; then \
		PROJECT=$$(echo "$(T)" | sed 's/-[0-9]*//'); \
		NUM=$$(echo "$(T)" | sed 's/[A-Z]*-//'); \
		bash $(SCRIPTS_DIR)/validate-docs.sh "projets/$$PROJECT/us-$$NUM" $(if $(STRICT),--strict,); \
	else \
		echo "Erreur : specifier T=TICKET-ID ou D=projets/PROJ/us-NNN"; \
		exit 1; \
	fi

metrics: ## Affiche les metriques du pipeline QA (FORMAT=text|json|markdown)
	@bash $(SCRIPTS_DIR)/metrics.sh $(if $(FORMAT),--format $(FORMAT),)

# ─── Outils ──────────────────────────────────────────────────────────────────

update-readmes: ## Met à jour tous les README des US
	@bash $(SCRIPTS_DIR)/update-all-readmes.sh

export-notion: ## Exporte la documentation vers CSV pour Notion
	@bash $(SCRIPTS_DIR)/export-to-notion.sh

sync-notion: ## Envoie 01/02/03 vers Notion (Projet → EPIC → US/Bug). NOTION_API_KEY et NOTION_PARENT_PAGE_ID requis.
	@bash $(SCRIPTS_DIR)/sync-to-notion.sh

archive: ## Archive les traitements anciens selon DAYS
	@bash $(SCRIPTS_DIR)/archive-treatments.sh --older-than $(DAYS)

test: ## Lance les tests unitaires
	@bash tests/run-all-tests.sh

clean: ## Nettoie les caches et fichiers temporaires
	@echo "Nettoyage des caches..."
	@rm -rf /tmp/qa_doc_* 2>/dev/null || true
	@rm -rf $(CLI_DIR)/dist 2>/dev/null || true
	@echo "Terminé. Relancer 'make build' pour reconstruire le CLI."
