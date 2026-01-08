# 📖 Fonctionnement détaillé du projet Doc QA

## 🎯 Vue d'ensemble

Ce projet automatise la génération de documentation QA à partir d'exports XML de tickets Jira. Il transforme des fichiers XML bruts en documentation structurée et complète pour les tests.

---

## 🔄 Flux de traitement principal

### 1. Point d'entrée : `process-xml-file.sh`

**Fichier** : `scripts/process-xml-file.sh`

**Rôle** : Orchestrateur principal qui coordonne tout le processus de traitement.

**Flux d'exécution** :

```
Fichier XML (Jira/ACCOUNT/ACCOUNT-2608.xml)
    ↓
1. Validation du XML
    ↓
2. Extraction des données de base (KEY, TITLE, LINK, DESCRIPTION)
    ↓
3. Vérification de l'historique (déjà traité ?)
    ↓
4. Création de la structure (projets/ACCOUNT/us-2608/)
    ↓
5. Génération des fichiers :
   ├── extraction-jira.md (extraction complète)
   ├── README.md (template rempli)
   ├── 01-questions-clarifications.md (généré automatiquement)
   ├── 02-strategie-test.md (généré automatiquement)
   └── 03-cas-test.md (généré automatiquement)
    ↓
6. Enregistrement dans l'historique
```

---

## 📊 Générateurs de données de sortie

### 🎨 Générateur 1 : `extraction-jira.md`

**Script responsable** : `scripts/process-xml-file.sh` (lignes 145-186)

**Bibliothèques utilisées** :
- `lib/xml-utils.sh` : Extraction des données XML
- `lib/acceptance-criteria-utils.sh` : Extraction des critères d'acceptation

**Données générées** :
- ✅ **Informations générales** : Clé, Titre, Type, Statut, Priorité, Lien
- ✅ **Description/User Story** : Section USER STORY extraite et formatée
- ✅ **Critères d'acceptation** : Tous les AC extraits avec Given/When/Then
- ✅ **Informations techniques** : Section SPECS TECHNIQUES
- ✅ **Designs** : Liens Figma et Miro extraits automatiquement
- ✅ **Commentaires** : Commentaires formatés avec auteur et date

**Fonctions d'extraction utilisées** :
- `extract_status()` : Statut du ticket
- `extract_type()` : Type (Story, Bug, etc.)
- `extract_priority()` : Priorité
- `extract_acceptance_criteria()` : Critères d'acceptation
- `extract_figma_links()` : Liens Figma
- `extract_miro_links()` : Liens Miro
- `extract_comments_formatted()` : Commentaires formatés

---

### 🎨 Générateur 2 : `01-questions-clarifications.md`

**Script responsable** : `scripts/generate-questions-from-xml.sh`

**Méthode de génération** :
1. **Bash pur** : Analyse du XML et génération de questions basées sur des patterns
2. **Fallback Cursor AI** : Si disponible, prépare des prompts pour l'agent Cursor

**Données analysées** :
- Description complète du ticket
- Critères d'acceptation
- Commentaires de l'équipe
- Scénarios décrits dans le XML

**Questions générées** (~30-40 questions) :
- **Pour PM** : Règles métier, cas limites, messages utilisateur
- **Pour Dev** : Architecture, validation, API, stockage, logs
- **Pour Designer** : Feedback visuel, états UI, responsive, accessibilité

**Logique de génération** :
- Détection de patterns dans la description (ex: "upload", "validation", "error")
- Extraction des contraintes (taille, format, nommage)
- Identification des zones d'ambiguïté
- Génération de questions contextuelles

---

### 🎨 Générateur 3 : `02-strategie-test.md`

**Script responsable** : `scripts/generate-strategy-from-xml.sh`

**Méthode de génération** :
1. **Bash pur** : Analyse du XML et génération basée sur des règles
2. **Fallback Cursor AI** : Si disponible, prépare des prompts pour l'agent Cursor

**Données analysées** :
- User Story complète
- Critères d'acceptation
- Scénarios décrits
- Labels et composants
- Commentaires techniques

**Stratégie générée** :
- ✅ **Objectif principal** : Basé sur la User Story
- ✅ **8 axes de test** :
  1. Scénarios nominaux
  2. Cas limites et robustesse
  3. Gestion des erreurs
  4. Sécurité et autorisations
  5. Performance
  6. Intégration
  7. Compatibilité
  8. Accessibilité
- ✅ **Zones à risque** : Identifiées depuis les labels/composants
- ✅ **Critères de succès** : Métriques et validation

**Logique de génération** :
- Détection du type de fonctionnalité (Upload, Benefits, Autre)
- Identification des contraintes (taille, format, nommage)
- Extraction des scénarios d'erreur
- Analyse des dépendances

---

### 🎨 Générateur 4 : `03-cas-test.md`

**Script responsable** : `scripts/generate-test-cases-from-xml.sh`

**Méthode de génération** :
1. **Bash pur** : Conversion des AC en scénarios de test
2. **Fallback Cursor AI** : Si disponible, prépare des prompts pour l'agent Cursor

**Données analysées** :
- Critères d'acceptation (AC.1, AC.2, AC.3...)
- Description complète
- Type de fonctionnalité détecté

**Cas de test générés** (~15-25 scénarios) :

#### A. Cas nominaux (basés sur les AC)
- **Source** : Conversion directe des critères d'acceptation
- **Format** : Given/When/Then → Étapes de test
- **Exemple** : AC.1 "Boutique non vérifiée" → Scénario de test complet

#### B. Cas spécifiques selon le type de fonctionnalité
- **Upload** : Scénarios d'upload, validation fichiers, drag-and-drop
- **Benefits** : Scénarios de sélection de bénéfices, limites
- **Générique** : Scénarios adaptés à la fonctionnalité

#### C. Cas systématiques
- **Intégration** : Persistance des données
- **Compatibilité** : Navigateurs, résolutions
- **Sécurité** : CSRF, autorisations
- **Accessibilité** : Navigation clavier

**Logique de génération** :
1. Extraction des AC via `extract_acceptance_criteria()`
2. Conversion AC → Scénario via `ac_to_test_scenario()`
3. Détection du type (Upload/Benefits/Autre)
4. Génération de scénarios spécifiques selon le type
5. Ajout de scénarios systématiques (sécurité, compatibilité, etc.)

---

## 🏗️ Architecture des bibliothèques

### `lib/xml-utils.sh` - Extraction XML

**Fonctions principales** :
- `parse_xml_file()` : Parse complet du XML avec cache
- `extract_key()` : Clé du ticket (ACCOUNT-2608)
- `extract_summary()` : Titre/Summary
- `extract_link()` : Lien Jira spécifique
- `extract_description()` : Description complète
- `extract_status()` : Statut
- `extract_type()` : Type
- `extract_priority()` : Priorité
- `extract_comments()` : Commentaires bruts
- `extract_figma_links()` : Liens Figma
- `extract_miro_links()` : Liens Miro
- `extract_comments_formatted()` : Commentaires formatés

**Optimisations** :
- Cache XML pour éviter les re-parsings
- Décodage HTML avec cache
- Validation XML optimisée

---

### `lib/acceptance-criteria-utils.sh` - Extraction AC

**Fonctions principales** :
- `extract_acceptance_criteria()` : Extraction des AC depuis XML
  - Support formats "AC 1" et "AC.1"
  - Extraction Given/When/Then
  - Décodage HTML
- `ac_to_test_scenario()` : Conversion AC → Scénario de test

**Format de sortie** :
```
AC.1|Titre|Given|When|Then
```

---

### `lib/common-functions.sh` - Utilitaires communs

**Fonctions principales** :
- `log_info()`, `log_error()`, `log_success()` : Logging
- `validate_file()`, `validate_directory()` : Validation
- `decode_html_cached()` : Décodage HTML avec cache
- `escape_for_sed()` : Échappement pour sed
- `safe_execute()` : Exécution sécurisée

---

### `lib/ticket-utils.sh` - Gestion des tickets

**Fonctions principales** :
- `get_ticket_key_from_path()` : Extraction clé depuis chemin
- `get_ticket_number()` : Extraction numéro (2608 depuis ACCOUNT-2608)
- `get_xml_file_from_key()` : Trouve le XML depuis la clé

---

### `lib/processing-utils.sh` - Traitement

**Fonctions principales** :
- `is_processed()` : Vérifie si un ticket est déjà traité
- `safe_mkdir()` : Création sécurisée de dossiers
- Cache pour optimiser les recherches

---

### `lib/history-utils.sh` - Historique

**Fonctions principales** :
- `record_treatment()` : Enregistre un traitement
- `get_treatment_info()` : Récupère les infos d'un traitement
- Gestion JSON pour l'historique

---

## 🔀 Modes de génération

### Mode 1 : Génération Bash pure (par défaut)

**Quand** : Toujours disponible, fonctionne sans dépendances externes

**Comment** :
- Analyse du XML avec `grep`, `sed`, `awk`
- Détection de patterns dans la description
- Génération basée sur des règles prédéfinies
- Conversion des AC en scénarios de test

**Avantages** :
- ✅ Rapide
- ✅ Pas de dépendances externes
- ✅ Déterministe

**Limitations** :
- ⚠️ Moins de contexte que l'IA
- ⚠️ Génération basée sur des patterns simples

---

### Mode 2 : Génération avec Cursor AI (optionnel)

**Quand** : Si l'agent Cursor est disponible

**Comment** :
- `scripts/generate-with-cursor.sh` prépare des prompts détaillés
- L'utilisateur copie le prompt dans Cursor
- Cursor génère le contenu avec l'IA
- L'utilisateur copie le résultat dans le fichier

**Avantages** :
- ✅ Génération plus intelligente et contextuelle
- ✅ Meilleure compréhension du contexte
- ✅ Génération plus créative

**Limitations** :
- ⚠️ Nécessite intervention manuelle
- ⚠️ Dépend de l'agent Cursor

**Scripts concernés** :
- `scripts/generate-with-cursor.sh` : Préparation des prompts
- `scripts/generate-all-with-cursor.sh` : Génération complète
- `lib/cursor-ai-utils.sh` : Utilitaires pour Cursor

---

## 📁 Structure des données générées

### Fichiers créés dans `projets/[PROJET]/us-[NUMBER]/`

1. **`extraction-jira.md`** (Généré automatiquement)
   - Toutes les données extraites du XML
   - Format structuré et lisible

2. **`README.md`** (Template rempli)
   - Vue d'ensemble de l'US
   - Informations de base

3. **`01-questions-clarifications.md`** (Généré automatiquement)
   - ~30-40 questions pertinentes
   - Basées sur le contenu réel du XML

4. **`02-strategie-test.md`** (Généré automatiquement)
   - 8 axes de test détaillés
   - Zones à risque identifiées

5. **`03-cas-test.md`** (Généré automatiquement)
   - ~15-25 cas de test complets
   - Basés sur les AC + scénarios systématiques

---

## 🔄 Flux de données complet

```
┌─────────────────────────────────────────────────────────────┐
│                    FICHIER XML JIRA                          │
│              (Jira/ACCOUNT/ACCOUNT-2608.xml)                 │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              process-xml-file.sh                             │
│  (Orchestrateur principal)                                   │
└──────────────────────┬──────────────────────────────────────┘
                       │
        ┌──────────────┼──────────────┐
        │              │              │
        ▼              ▼              ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│  lib/        │ │  lib/        │ │  lib/        │
│  xml-utils   │ │  acceptance- │ │  common-     │
│              │ │  criteria-   │ │  functions   │
│  Extraction  │ │  utils       │ │              │
│  des données │ │              │ │  Utilitaires │
│  de base     │ │  Extraction  │ │  communs     │
│              │ │  des AC      │ │              │
└──────┬───────┘ └──────┬───────┘ └──────┬───────┘
       │                │                 │
       └────────────────┼─────────────────┘
                        │
        ┌───────────────┼───────────────┐
        │               │               │
        ▼               ▼               ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│ generate-    │ │ generate-    │ │ generate-    │
│ questions-   │ │ strategy-    │ │ test-cases-  │
│ from-xml.sh  │ │ from-xml.sh  │ │ from-xml.sh  │
│              │ │              │ │              │
│ Questions    │ │ Stratégie    │ │ Cas de test  │
│ (~30-40)     │ │ (8 axes)     │ │ (~15-25)     │
└──────────────┘ └──────────────┘ └──────────────┘
        │               │               │
        └───────────────┼───────────────┘
                        │
                        ▼
        ┌───────────────────────────────┐
        │   FICHIERS MARKDOWN GÉNÉRÉS    │
        │  (projets/ACCOUNT/us-2608/)    │
        └───────────────────────────────┘
```

---

## 🎯 Résumé : Qui génère quoi ?

| Fichier de sortie | Générateur principal | Méthode | Données sources |
|-------------------|---------------------|---------|-----------------|
| `extraction-jira.md` | `process-xml-file.sh` | Bash | XML complet |
| `01-questions-clarifications.md` | `generate-questions-from-xml.sh` | Bash + Cursor AI (optionnel) | Description, AC, Commentaires |
| `02-strategie-test.md` | `generate-strategy-from-xml.sh` | Bash + Cursor AI (optionnel) | User Story, AC, Labels |
| `03-cas-test.md` | `generate-test-cases-from-xml.sh` | Bash + Cursor AI (optionnel) | AC, Description, Type fonctionnalité |
| `README.md` | `process-xml-file.sh` | Template rempli | KEY, TITLE, LINK |

---

## 🔧 Scripts utilitaires

### `regenerate-all-docs.sh`
- Régénère tous les documents pour toutes les US traitées
- Utile après mise à jour des scripts/templates

### `process-unprocessed.sh`
- Traite uniquement les fichiers XML non encore traités
- Évite les doublons

### `export-to-notion.sh`
- Exporte tous les US vers CSV pour Notion
- Historisation pour éviter les doublons

### `fix-jira-links.sh`
- Corrige les liens Jira dans tous les documents
- Remplace les liens génériques par des liens spécifiques

### `archive-treatments.sh`
- Archive les anciennes documentations
- Gestion de l'historique d'archivage

---

## 📈 Optimisations implémentées

1. **Cache XML** : Évite les re-parsings multiples
2. **Cache HTML** : Décodage HTML mis en cache
3. **Cache find** : Résultats de `find` mis en cache
4. **Validation XML optimisée** : Lecture unique du fichier
5. **Centralisation des chemins** : Tous les chemins dans `config.sh`

---

## 🎓 Conclusion

Le projet utilise une **architecture modulaire** avec :
- **1 orchestrateur principal** (`process-xml-file.sh`)
- **3 générateurs spécialisés** (questions, stratégie, cas de test)
- **6 bibliothèques communes** (xml, acceptance-criteria, common, ticket, processing, history)
- **2 modes de génération** (Bash pur + Cursor AI optionnel)

Tous les fichiers de sortie sont générés **automatiquement** à partir du XML, sans intervention manuelle nécessaire (sauf pour l'option Cursor AI).

