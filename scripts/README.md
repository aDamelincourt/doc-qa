# Scripts d'automatisation QA

## 📋 Description

Ce dossier contient les scripts pour automatiser le traitement des exports XML Jira et la génération de documentation QA.

---

### 11. `fix-jira-links.sh`

**Usage** : Corriger tous les liens Jira dans les documents existants

```bash
./scripts/fix-jira-links.sh
```

**Fonctionnalités** :
- Corrige les liens génériques (`https://forge.prestashop.com`) en liens spécifiques (`https://forge.prestashop.com/browse/TICKET-KEY`)
- Met à jour tous les fichiers markdown (README.md, extraction-jira.md, 01-questions-clarifications.md, 02-strategie-test.md, 03-cas-test.md)
- Utilise la clé unique du ticket pour construire le lien correct

**Note** : La fonction `extract_link()` dans `lib/xml-utils.sh` a été améliorée pour extraire automatiquement le lien spécifique lors de la génération de nouveaux documents.

---

## 📚 Bibliothèques communes

Le projet utilise des bibliothèques communes dans `scripts/lib/` pour éviter la duplication de code :

- **`lib/common-functions.sh`** : Fonctions communes (logging, validation, décodage HTML)
- **`lib/xml-utils.sh`** : Fonctions d'extraction XML
- **`lib/ticket-utils.sh`** : Gestion des tickets (extraction clé, chemins)
- **`lib/processing-utils.sh`** : Traitement des fichiers (is_processed, permissions)
- **`lib/config.sh`** : Configuration centralisée (chemins, paramètres)

Tous les scripts chargent automatiquement ces bibliothèques.

---

## 🚀 Scripts disponibles

### 1. `process-xml-file.sh`

**Usage** : Traiter un fichier XML spécifique et créer la structure de documentation QA

```bash
./scripts/process-xml-file.sh [FICHIER_XML]
```

**Exemple** :
```bash
./scripts/process-xml-file.sh "Jira/SPEX/SPEX-2990.xml"
```

**Fonctionnalités** :
- Extrait les informations du XML (clé, titre, lien, description)
- Crée la structure de dossier `projets/[PROJET]/us-[NUMBER]/`
- **Génère automatiquement des questions de clarifications pertinentes** basées sur le contenu réel du XML (au lieu de templates vides)
- **Génère automatiquement une stratégie de test détaillée** basée sur les scénarios et critères d'acceptation du ticket
- Génère les fichiers de documentation à partir des templates :
  - `README.md` (vue d'ensemble)
  - `extraction-jira.md` (informations extraites - À COMPLÉTER)
  - `01-questions-clarifications.md` (**généré automatiquement avec ~30-40 questions pertinentes**)
  - `02-strategie-test.md` (**généré automatiquement avec 8 axes de test détaillés**)
  - `03-cas-test.md` (template pré-rempli)

---

### 2. `generate-questions-from-xml.sh`

**Usage** : Générer automatiquement des questions de clarifications pertinentes basées sur le contenu réel du XML Jira

```bash
./scripts/generate-questions-from-xml.sh [US_DIR]
```

**Exemple** :
```bash
./scripts/generate-questions-from-xml.sh "projets/SPEX/us-2990"
```

**Fonctionnalités** :
- Analyse le contenu réel du XML Jira (User Story, critères d'acceptation, scénarios, commentaires)
- Identifie automatiquement les ambiguïtés et zones non claires
- Génère des questions pertinentes pour :
  - **PM** : Messages d'erreur exacts, contraintes (taille, format), scénarios désactivés, cas limites, comportements attendus
  - **Développeurs** : Validation (client/serveur), API endpoints, stockage, logs, données de test, persistance
  - **Designer** : Feedback visuel, états de l'interface, positionnement des erreurs, responsive, accessibilité

**Résultat** :
- Génère ~30-40 questions pertinentes basées sur le contenu réel au lieu d'un template vide
- Chaque question inclut un contexte expliquant pourquoi elle est importante
- Questions adaptées au contexte spécifique du ticket Jira

**Note** : Ce script est appelé automatiquement par `process-xml-file.sh`, mais peut aussi être exécuté manuellement pour régénérer les questions.

---

### 3. `generate-strategy-from-xml.sh`

**Usage** : Générer automatiquement une stratégie de test détaillée basée sur le contenu réel du XML Jira

```bash
./scripts/generate-strategy-from-xml.sh [US_DIR]
```

**Exemple** :
```bash
./scripts/generate-strategy-from-xml.sh "projets/SPEX/us-2990"
```

**Fonctionnalités** :
- Analyse le contenu réel du XML Jira (User Story, critères d'acceptation, scénarios, labels, composants)
- Identifie automatiquement les axes de test pertinents à partir des scénarios décrits
- Génère une stratégie complète avec :
  - **Objectif principal** basé sur la User Story
  - **8 axes de test détaillés** : Scénarios nominaux, Cas limites, Gestion des erreurs, Sécurité, Performance, Intégration, Compatibilité, Accessibilité
  - **Points de vigilance spécifiques** pour chaque axe basés sur les scénarios du ticket
  - **Zones à risque** pour la non-régression identifiées depuis les labels et composants
  - **Critères de succès** et métriques de test
  - **Prérequis** adaptés (environnement, données de test, dépendances)

**Résultat** :
- Génère une stratégie complète et détaillée basée sur le contenu réel au lieu d'un template vide
- Identifie automatiquement les contraintes (taille, format, nommage) et les intégre dans la stratégie
- Propose des points de vigilance spécifiques basés sur les scénarios décrits dans le ticket
- Met en évidence les zones à risque pour les tests de régression

**Note** : Ce script est appelé automatiquement par `process-xml-file.sh`, mais peut aussi être exécuté manuellement pour régénérer la stratégie.

---

### 4. `generate-test-cases-from-xml.sh`

**Usage** : Générer automatiquement des cas de test complets avec étapes, données de test et résultats attendus basés sur le contenu réel du XML Jira

```bash
./scripts/generate-test-cases-from-xml.sh [US_DIR]
```

**Exemple** :
```bash
./scripts/generate-test-cases-from-xml.sh "projets/SPEX/us-2990"
```

**Fonctionnalités** :
- Analyse le contenu réel du XML Jira (scénarios Given/When/Then, critères d'acceptation, commentaires)
- Génère automatiquement des cas de test complets avec :
  - **Étapes détaillées** : Convertit les scénarios Given/When/Then en étapes numérotées et actionnables
  - **Données de test concrètes** : Extrait les valeurs spécifiques du XML (tailles de fichiers, formats, noms, etc.)
  - **Résultats attendus** : Génère les résultats attendus basés sur les critères d'acceptation et messages d'erreur du ticket
- Organise les cas de test par catégories :
  - **Cas nominaux** : Scénarios principaux de la fonctionnalité
  - **Cas limites** : Valeurs limites (taille min/max, formats, etc.)
  - **Cas d'erreur** : Gestion des erreurs avec messages exacts extraits du XML
  - **Cas de sécurité** : Autorisations, désactivation pendant upload, etc.
  - **Cas de performance** : Tests de charge et temps de réponse
  - **Cas d'intégration** : Persistance, sauvegarde, etc.
  - **Cas de compatibilité** : Navigateurs, responsive design
  - **Cas d'accessibilité** : Navigation clavier, lecteurs d'écran

**Résultat** :
- Génère ~15-25 cas de test complets avec toutes les sections remplies
- Chaque cas de test inclut des étapes détaillées, des données de test concrètes et des résultats attendus spécifiques
- Les messages d'erreur sont extraits directement du XML pour garantir la cohérence
- Les limites (taille, format, nommage) sont détectées automatiquement depuis les commentaires et scénarios

**Exemple de cas de test généré** :
```markdown
### Scénario 1 : Upload d'un fichier PDF valide via drag-and-drop

**Objectif** : Vérifier que Upload d'un fichier PDF valide via drag-and-drop

**Étapes** :
1. Se connecter en tant que vendeur et accéder à la section 'Share your product documentation'
2. Glisser-déposer un fichier PDF valide (nommé readme_fr.pdf, < 10MB) dans la zone d'upload

**Données de test** :
```
Fichier: readme_fr.pdf
Taille: 1.5MB
Format: PDF
Nommage: readme_fr.pdf (conforme)
```

**Résultat attendu** :
- ✅ Le fichier apparaît immédiatement dans la zone d'upload après le drag-and-drop
- ✅ Le nom du fichier (readme_fr.pdf) est affiché correctement
- ✅ L'icône de suppression ('X') est visible à côté du nom du fichier
- ✅ Le fichier est correctement uploadé et sauvegardé
```

**Note** : Ce script est appelé automatiquement par `process-xml-file.sh`, mais peut aussi être exécuté manuellement pour régénérer les cas de test.

---

### 5. `update-readme-from-xml.sh`

**Usage** : Met à jour le README d'une US avec les informations extraites du XML et des fichiers générés

```bash
./scripts/update-readme-from-xml.sh [US_DIR]
```

**Exemple** :
```bash
./scripts/update-readme-from-xml.sh "projets/SPEX/us-2990"
```

**Fonctionnalités** :
- Extrait la User Story complète (As a... I want... So that...) depuis le XML
- Extrait les parties de la User Story (En tant que, Je veux, Afin de)
- Extrait le nom du projet depuis le XML
- Compte automatiquement le nombre de scénarios dans `03-cas-test.md`
- Calcule la progression des tests (passés, échoués, bloqués, à exécuter)
- Met à jour les dates de création des documents
- Met à jour la date de dernière mise à jour

**Note** : Ce script est appelé automatiquement par `process-xml-file.sh` après la génération des fichiers de documentation.

---

### 6. `update-all-readmes.sh`

**Usage** : Met à jour tous les README des US existantes dans le projet

```bash
./scripts/update-all-readmes.sh
```

**Fonctionnalités** :
- Parcourt tous les dossiers `us-XXXX` dans `projets/`
- Met à jour chaque README avec les informations extraites
- Affiche un résumé des mises à jour effectuées

**Note** : Utile pour mettre à jour tous les README après une modification des scripts ou des templates.

---

### 7. `regenerate-all-docs.sh`

**Usage** : Régénère tous les documents QA à partir des exports XML existants

```bash
# Régénérer tous les documents
./scripts/regenerate-all-docs.sh

# Forcer la régénération même si les fichiers existent
./scripts/regenerate-all-docs.sh --force

# Utiliser Cursor IA pour la génération
./scripts/regenerate-all-docs.sh --cursor

# Combiner les options
./scripts/regenerate-all-docs.sh --force --cursor
```

**Fonctionnalités** :
- Parcourt tous les fichiers XML dans `Jira/`
- Identifie les US déjà traitées
- Régénère les 3 fichiers de documentation pour chaque US :
  - `01-questions-clarifications.md`
  - `02-strategie-test.md`
  - `03-cas-test.md`
- Option `--cursor` : Utilise Cursor IA pour générer les documents (affiche les prompts)
- Utile après une mise à jour des templates ou des scripts

**Options** :
- `--force` : Forcer la régénération même si les documents existent
- `--cursor` : Utiliser Cursor IA pour la génération (équivalent à l'ancien `retreat-all-xml.sh`)

**Note** : Utile pour mettre à jour tous les documents après une modification des templates ou des scripts de génération.

---

### 8. `archive-treatments.sh`

**Usage** : Archiver automatiquement les anciens traitements

```bash
# Archiver un ticket spécifique
./scripts/archive-treatments.sh --ticket SPEX-2990

# Archiver tous les tickets d'un projet
./scripts/archive-treatments.sh --project SPEX

# Archiver les traitements plus anciens que 90 jours
./scripts/archive-treatments.sh --older-than 90

# Voir ce qui serait archivé (sans le faire)
./scripts/archive-treatments.sh --older-than 90 --dry-run

# Lister tous les traitements
./scripts/archive-treatments.sh --list
```

**Fonctionnalités** :
- Archive les dossiers de documentation QA vers `archives/`
- Conserve l'historique d'archivage dans `archives/archive-history.json`
- Options pour archiver par ticket, projet ou date
- Mode dry-run pour prévisualiser les actions

**Note** : Voir `archives/README.md` pour plus de détails sur l'archivage.

---

### 9. `generate-with-cursor.sh`

**Usage** : Script unifié pour générer des documents avec l'agent Cursor IA

```bash
# Mode interactif (défaut) - Générer un document
./scripts/generate-with-cursor.sh questions projets/SPEX/us-2990
./scripts/generate-with-cursor.sh strategy projets/SPEX/us-2990
./scripts/generate-with-cursor.sh test-cases projets/SPEX/us-2990

# Générer tous les documents en une fois
./scripts/generate-with-cursor.sh all projets/SPEX/us-2990

# Mode direct (affiche le prompt clairement)
./scripts/generate-with-cursor.sh questions projets/SPEX/us-2990 --direct

# Mode automatique (génère directement)
./scripts/generate-with-cursor.sh all projets/SPEX/us-2990 --auto

# Mode interactif explicite
./scripts/generate-with-cursor.sh questions projets/SPEX/us-2990 --interactive
```

**Fonctionnalités** :
- Prépare un prompt détaillé pour l'agent Cursor
- Extrait le contexte complet depuis le XML
- Génère un fichier temporaire avec le prompt prêt à utiliser
- Supporte plusieurs modes d'affichage

**Types de documents** :
- `questions` : Questions de clarifications
- `strategy` : Stratégie de test
- `test-cases` : Cas de test
- `all` : Tous les documents (équivalent à l'ancien `generate-all-with-cursor.sh`)

**Options** :
- `--all` : Générer tous les documents (déjà inclus avec `all` comme type)
- `--direct` : Mode direct (affiche le prompt clairement, équivalent à l'ancien `generate-with-cursor-direct.sh`)
- `--auto` : Mode automatique (génère directement, équivalent à l'ancien `generate-docs-directly.sh`)
- `--interactive` : Mode interactif (défaut, affiche le prompt pour copier-coller)

**Note** : Voir `GUIDE-CURSOR-IA.md` à la racine du projet pour plus de détails sur l'intégration avec Cursor.

---

## 🔄 Workflow automatisé

### Traitement d'un fichier XML

```bash
# Traiter un fichier spécifique
./scripts/process-xml-file.sh "Jira/SPEX/SPEX-2990.xml"
```

### Régénération de tous les documents

```bash
# Régénérer tous les documents existants
./scripts/regenerate-all-docs.sh
```

---

## 📁 Structure créée

Pour chaque fichier XML traité, la structure suivante est créée :

```
projets/
└── [NOM_PROJET]/
    └── us-[NUMBER]/
        ├── README.md                    # Vue d'ensemble (pré-rempli)
        ├── extraction-jira.md           # Informations extraites (À COMPLÉTER)
        ├── 01-questions-clarifications.md  # ⭐ Généré automatiquement avec ~30-40 questions pertinentes
        ├── 02-strategie-test.md         # ⭐ Généré automatiquement avec 8 axes de test détaillés
        ├── 03-cas-test.md               # ⭐ Généré automatiquement avec ~15-25 cas de test complets (étapes, données, résultats)
```

---

## ✅ Détection des fichiers traités

Un fichier XML est considéré comme **traité** si :
- Une documentation QA existe dans `projets/[PROJET]/us-[NUMBER]/`
- Le fichier `README.md` mentionne la clé du ticket (ex: SPEX-2990)

Les scripts vérifient automatiquement cette condition avant de traiter un fichier.

---

## 📝 Prochaines étapes après traitement

Une fois qu'un fichier XML est traité par le script :

1. **Compléter `extraction-jira.md`** :
   - Extraire toutes les informations du XML (critères d'acceptation, commentaires, etc.)
   - Utiliser `templates/extraction-jira-xml-guide.md` pour référence

2. **Compléter les documents générés** :
   - Les fichiers `01-`, `02-`, `03-` sont générés automatiquement
   - Compléter avec votre expertise ou via l'agent Cursor si besoin

3. **Compléter les templates** :
   - Les fichiers `01-`, `02-`, `03-` sont des templates pré-remplis
   - Complétez-les avec votre expertise ou via l'IA

---

## 🔍 Vérifier les fichiers traités

Pour voir quels fichiers ont été traités, consultez l'historique dans `.history/traitements.json` :

```bash
# Lister tous les traitements (si python3 est disponible)
python3 -c "import json; data = json.load(open('.history/traitements.json')); print('\n'.join([f\"{k}: {v['us_dir']}\" for k, v in data.items()]))"
```

---

## 📋 Checklist

Avant de lancer le traitement automatique :

- [ ] Les exports XML sont dans `Jira/[PROJET]/[TICKET-ID].xml`
- [ ] Les templates sont à jour dans `templates/`
- [ ] Vous avez les permissions d'écriture dans `projets/`

Après le traitement automatique :

- [ ] Vérifier que la structure a été créée dans `projets/[PROJET]/us-[NUMBER]/`
- [ ] Compléter `extraction-jira.md` avec toutes les informations
- [ ] Générer la documentation complète via l'IA ou manuellement

---

## 🐛 Résolution de problèmes

### Le script ne trouve pas les fichiers XML

Vérifier que :
- Les fichiers sont bien dans `Jira/[PROJET]/[TICKET-ID].xml`
- Les fichiers ont l'extension `.xml`
- Les permissions d'accès sont correctes

### Erreur lors de l'extraction XML

- Vérifier que le fichier XML est valide
- Le script utilise `sed` et `awk` qui doivent être disponibles sur le système

### Le dossier existe déjà

Si le dossier `projets/[PROJET]/us-[NUMBER]/` existe déjà, le script demandera confirmation avant d'écraser.

---

## 🔗 Voir aussi

- `../README.md` : Guide général de la documentation QA
- `../templates/extraction-jira-xml-guide.md` : Guide pour parser les XML
- `../Jira/README.md` : Structure du dossier Jira

---

## 📧 Support

Pour toute question ou problème avec les scripts, consultez la documentation ou contactez l'équipe QA.

