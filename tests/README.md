# Tests du projet Doc QA

Ce dossier contient les tests pour valider le bon fonctionnement des scripts d'automatisation.

## 📋 Structure

```
tests/
├── README.md                    # Ce fichier
├── test-common-functions.sh     # Tests des fonctions communes
├── test-xml-utils.sh            # Tests des utilitaires XML
├── test-processing-utils.sh     # Tests des utilitaires de traitement
├── test-ticket-utils.sh         # Tests des utilitaires de tickets
├── test-integration.sh          # Tests d'intégration end-to-end
└── fixtures/                    # Fichiers de test (XML, etc.)
    ├── sample-jira-export.xml
    └── invalid-xml.xml
```

## 🚀 Utilisation

### Exécuter tous les tests

```bash
./tests/run-all-tests.sh
```

### Exécuter un test spécifique

```bash
./tests/test-common-functions.sh
```

### Mode verbose

```bash
VERBOSE=1 ./tests/run-all-tests.sh
```

## 📝 Ajout de nouveaux tests

1. Créer un nouveau fichier `test-*.sh` dans ce dossier
2. Importer les fonctions de test : `source "$(dirname "$0")/test-helpers.sh"`
3. Utiliser les fonctions `test_assert`, `test_suite`, etc.
4. Ajouter le test à `run-all-tests.sh`

## ✅ Résultats attendus

Tous les tests doivent passer avant de commiter des changements.

