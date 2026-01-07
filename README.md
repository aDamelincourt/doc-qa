# Documentation QA - Guide d'utilisation

## 📁 Structure du projet

Cette arborescence organise la documentation QA par projet et par User Story (US).

```
Doc QA/
├── README.md                          # Ce fichier - Guide général
├── GUIDE-RAPIDE.md                    # Guide rapide d'utilisation
├── scripts/                           # Scripts d'automatisation ⭐
│   ├── README.md                      # Documentation des scripts
│   └── process-xml-file.sh           # Traiter un fichier XML spécifique
├── templates/                         # Templates réutilisables
│   ├── README.md                      # Guide des templates
│   ├── extraction-jira-template.md   # Template d'extraction depuis Jira
│   ├── extraction-jira-xml-guide.md  # Guide pour parser XML
│   ├── prompt-generation-qa.md       # Prompt complet pour IA
│   ├── prompt-rapide.md              # Prompt rapide pour IA
│   ├── questions-clarifications-template.md
│   ├── strategie-test-template.md
│   ├── cas-test-template.md
│   └── us-readme-template.md
├── Jira/                              # Exports XML des tickets Jira
│   ├── README.md                      # Guide de la structure Jira
│   └── [NOM_PROJET]/                 # Ex: "SPEX", "MME"
│       └── [TICKET-ID].xml           # Ex: "SPEX-2990.xml"
├── projets/                          # Documentation par projet
│   ├── README.md                      # Guide des projets
│   └── [NOM_PROJET]/                 # Ex: "SPEX", "addons-marketplace"
│       └── us-[NUMBER]/              # Ex: "us-2990", "us-123"
│           ├── README.md             # Vue d'ensemble de l'US
│           ├── extraction-jira.md    # Informations extraites du XML
│           ├── 01-questions-clarifications.md
│           ├── 02-strategie-test.md
│           └── 03-cas-test.md
└── archives/                         # Anciennes documentations (optionnel)
```

---

## 📋 Workflow de documentation QA

### Étape 0 : Exporter depuis Jira (Si applicable)

**Structure** : `Jira/[NOM_PROJET]/[TICKET-ID].xml`

**Objectif** : Exporter et sauvegarder les tickets Jira en XML pour référence.

**Processus** :
1. Exporter le ticket Jira au format XML
2. Sauvegarder dans `Jira/[NOM_PROJET]/[TICKET-ID].xml`
   - Exemple : `Jira/SPEX/SPEX-2990.xml`
3. **Traitement automatique** : Utiliser les scripts pour traiter automatiquement les exports XML
   - Traiter un fichier spécifique : `./scripts/process-xml-file.sh "Jira/[PROJET]/[TICKET].xml"`
   - Régénérer tous les documents : `./scripts/regenerate-all-docs.sh`
4. Voir `scripts/README.md` et `Jira/README.md` pour plus de détails

### Étape 1 : Questions et Clarifications

**Fichier** : `01-questions-clarifications.md`

**Objectif** : Clarifier tous les points d'ombre avant de rédiger les tests.

**Processus** :
1. Copier le template `templates/questions-clarifications-template.md`
2. Si vous avez un export XML, extraire les informations depuis `Jira/[NOM_PROJET]/[TICKET-ID].xml`
3. Adapter les questions selon la feature
4. Solliciter les équipes (PM, Dev, Designer)
5. Documenter les réponses
6. Une fois toutes les réponses obtenues, passer à l'étape 2

---

### Étape 2 : Stratégie de Test

**Fichier** : `02-strategie-test.md`

**Objectif** : Définir la stratégie de test et les axes prioritaires.

**Processus** :
1. Copier le template `templates/strategie-test-template.md`
2. Définir les axes de test en fonction de la feature
3. Identifier les zones à risque pour la non-régression
4. Valider la stratégie avec l'équipe QA
5. Une fois validée, passer à l'étape 3

---

### Étape 3 : Cas de Test

**Fichier** : `03-cas-test.md`

**Objectif** : Décrire en détail tous les scénarios de test.

**Processus** :
1. Copier le template `templates/cas-test-template.md`
2. Rédiger tous les scénarios de test détaillés
3. Utiliser les réponses de l'étape 1 pour compléter les données de test
4. Suivre la stratégie définie à l'étape 2
5. Exécuter les tests et documenter les résultats

---

## 🚀 Utilisation rapide

### Option A : Traitement automatique depuis XML Jira (Recommandé)

1. **Exporter depuis Jira** :
   - Exporter le ticket Jira au format XML
   - Sauvegarder dans `Jira/[NOM_PROJET]/[TICKET-ID].xml`

2. **Traiter automatiquement** :
   ```bash
   # Traiter un fichier spécifique
   ./scripts/process-xml-file.sh "Jira/SPEX/SPEX-2990.xml"
   
   # Régénérer tous les documents existants
   ./scripts/regenerate-all-docs.sh
   ```

3. **Documentation générée automatiquement** :
   - Le script crée automatiquement la structure complète dans `projets/[PROJET]/us-[NUMBER]/`
   - **Les fichiers suivants sont générés automatiquement** :
     - `01-questions-clarifications.md` : ~30-40 questions pertinentes basées sur le contenu XML
     - `02-strategie-test.md` : Stratégie complète avec 8 axes de test détaillés
     - `03-cas-test.md` : ~15-25 cas de test complets avec étapes, données et résultats attendus
   - Compléter `extraction-jira.md` avec toutes les informations du XML (optionnel)

### Option B : Création manuelle

1. **Créer la structure de dossiers** :
   ```bash
   mkdir -p projets/[NOM_PROJET]/us-[NUMBER]
   cd projets/[NOM_PROJET]/us-[NUMBER]
   ```

2. **Créer le README de l'US** :
   - Copier le template `templates/us-readme-template.md`
   - Adapter avec les informations de l'US

3. **Créer les 3 documents** :
   ```bash
   # Étape 1 : Questions
   cp ../../templates/questions-clarifications-template.md 01-questions-clarifications.md
   
   # Étape 2 : Stratégie
   cp ../../templates/strategie-test-template.md 02-strategie-test.md
   
   # Étape 3 : Cas de test
   cp ../../templates/cas-test-template.md 03-cas-test.md
   ```

4. **Compléter les documents dans l'ordre** :
   - D'abord les questions et clarifications
   - Ensuite la stratégie de test
   - Enfin les cas de test détaillés

---

## 📝 Convention de nommage

### Fichiers

- **Questions et clarifications** : `01-questions-clarifications.md`
- **Stratégie de test** : `02-strategie-test.md`
- **Cas de test** : `03-cas-test.md`
- **README** : `README.md`

### Dossiers

- **Projets** : `projets/[NOM_PROJET]/` (en minuscules avec tirets)
- **User Stories** : `us-[NUMBER]/` (ex: `us-123`, `us-456`)

---

## 🔗 Liens entre documents

Chaque document contient une section "Documents associés" avec :
- Lien vers les questions/clarifications
- Lien vers la stratégie de test
- Lien vers les cas de test
- Lien vers la User Story (Jira/Ticket)

---

## 🤖 Processus automatisé

### Traitement automatique des exports XML Jira

Le projet inclut des scripts pour automatiser le traitement des exports XML Jira :

1. **Traiter un fichier XML** :
   ```bash
   # Traiter un fichier spécifique
   ./scripts/process-xml-file.sh "Jira/SPEX/SPEX-2990.xml"
   ```
   - Extrait les informations du XML (clé, titre, lien, description)
   - Crée automatiquement la structure complète dans `projets/[PROJET]/us-[NUMBER]/`
   - Génère tous les fichiers de documentation pré-remplis

2. **Régénérer tous les documents** :
   ```bash
   # Régénérer tous les documents existants
   ./scripts/regenerate-all-docs.sh
   ```
   - Régénère les 3 fichiers de documentation pour toutes les US traitées
   - Utile après une mise à jour des templates ou des scripts

3. **Mettre à jour les README** :
   - Les README sont automatiquement complétés lors de la création
   - Pour mettre à jour tous les README existants : `./scripts/update-all-readmes.sh`
   - Pour mettre à jour un README spécifique : `./scripts/update-readme-from-xml.sh projets/SPEX/us-2990`

4. **Archiver les traitements** :
   - Pour archiver un ticket spécifique : `./scripts/archive-treatments.sh --ticket SPEX-2990`
   - Pour archiver tous les tickets d'un projet : `./scripts/archive-treatments.sh --project SPEX`
   - Voir `archives/README.md` pour plus de détails

5. **Exporter vers Notion** :
   - Pour exporter tous les US non encore exportés : `./scripts/export-to-notion.sh`
   - Pour forcer l'export de tous les US : `./scripts/export-to-notion.sh --force`
   - Le CSV est généré dans `exports/notion-export-YYYYMMDD-HHMMSS.csv`
   - L'historique des exports est géré automatiquement (pas de doublons)
   - Voir `EXPORT-NOTION.md` pour la documentation complète

6. **Voir les scripts** :
   - Consulter `scripts/README.md` pour la documentation complète des scripts
   - Les scripts vérifient automatiquement quels fichiers ont déjà été traités

---

## 📚 Ressources

- **Scripts** : Voir `scripts/README.md` pour la documentation des scripts d'automatisation
- **Templates** : Voir `templates/README.md` pour la description détaillée de chaque template
- **Exports Jira** : Voir `Jira/README.md` pour la structure et l'utilisation des exports XML
- **Export Notion** : Voir `EXPORT-NOTION.md` pour exporter vers Notion au format CSV
- **Exemples** : Consulter les documentations existantes dans `projets/` pour voir des exemples concrets

---

## 🤖 Génération automatique avec IA

Pour accélérer la création de documentation QA, vous pouvez utiliser des prompts d'IA :

### Prompts disponibles

1. **`templates/prompt-generation-qa.md`** : Prompt complet et détaillé
   - Version complète avec instructions détaillées
   - Guide pas à pas pour personnaliser le prompt
   - Consignes spécifiques PrestaShop
   - Support pour exports XML depuis Jira

2. **`templates/prompt-rapide.md`** : Version simplifiée
   - Prompt court pour utilisation rapide
   - Version allégée avec informations essentielles

### Comment utiliser

1. **Exporter depuis Jira** (si applicable) :
   - Exporter le ticket Jira au format XML
   - Sauvegarder dans `Jira/[NOM_PROJET]/[TICKET-ID].xml`
   - Voir `Jira/README.md` pour la structure

2. **Préparer le contexte** :
   - Extraire les informations depuis le XML (voir `templates/extraction-jira-xml-guide.md`)
   - Collecter la User Story complète
   - Rassembler les spécifications techniques
   - Inclure l'historique du projet (autres fichiers XML dans `Jira/[NOM_PROJET]/`)

3. **Personnaliser le prompt** :
   - Copier le prompt (complet ou rapide)
   - Remplacer les placeholders `[XXX]` par vos informations
   - Ajouter vos spécifications extraites du XML

4. **Générer avec l'IA** :
   - Coller dans votre outil d'IA (ChatGPT, Claude, etc.)
   - Récupérer les 3 fichiers générés
   - Vérifier et compléter avec votre expertise

5. **Sauvegarder** :
   - Placer les fichiers dans `projets/[PROJET]/us-[NUMBER]/`
   - Le fichier XML reste dans `Jira/[NOM_PROJET]/` pour référence
   - Vérifier et valider avec l'équipe

---

## ✅ Checklist pour une documentation complète

- [ ] Export XML sauvegardé dans `Jira/[NOM_PROJET]/[TICKET-ID].xml` (si applicable)
- [ ] Structure de dossiers créée (`projets/[PROJET]/us-[NUMBER]/`)
- [ ] README.md créé avec vue d'ensemble de l'US
- [ ] `01-questions-clarifications.md` créé et toutes les questions répondues
- [ ] `02-strategie-test.md` créé et validé
- [ ] `03-cas-test.md` créé avec tous les scénarios détaillés
- [ ] Tous les liens entre documents sont à jour
- [ ] Documentation prête pour l'exécution des tests

---

## 🧪 Tests

Le projet inclut une suite de tests pour valider le bon fonctionnement des scripts :

```bash
# Exécuter tous les tests
./tests/run-all-tests.sh

# Mode verbose
VERBOSE=1 ./tests/run-all-tests.sh

# Exécuter un test spécifique
./tests/test-common-functions.sh
```

Voir `tests/README.md` pour plus de détails.

---

## 📧 Contact

Pour toute question sur cette structure de documentation, contacter l'équipe QA.

