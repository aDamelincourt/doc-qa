# Guide Rapide - Documentation QA

## 🎯 Vue d'ensemble

Cette structure de documentation QA permet d'organiser les tests par **Projet** et par **User Story (US)**.

---

## 📂 Structure créée

```
Doc QA/
├── README.md                          # Guide général
├── GUIDE-RAPIDE.md                    # Ce fichier
├── templates/                         # Templates réutilisables
│   ├── README.md                      # Guide des templates
│   ├── us-readme-template.md          # Template pour README d'une US
│   ├── questions-clarifications-template.md  # Partie 1 : Questions
│   ├── strategie-test-template.md     # Partie 2a : Stratégie
│   └── cas-test-template.md           # Partie 2b : Cas de test
├── projets/                          # Documentation par projet
│   ├── README.md                      # Guide des projets
│   └── exemple-projet/               # Exemple de structure
│       └── us-001/
│           └── README.md
└── archives/                         # Anciennes documentations
```

---

## 🚀 Démarrage rapide

### Option 1 : Traitement automatique depuis XML Jira (Recommandé)

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
   - Les fichiers sont créés automatiquement dans `projets/[PROJET]/us-[NUMBER]/`
   - **Génération automatique** :
     - `01-questions-clarifications.md` : Questions pertinentes générées depuis le XML
     - `02-strategie-test.md` : Stratégie complète avec axes de test détaillés
     - `03-cas-test.md` : Cas de test complets avec étapes, données et résultats
   - Compléter `extraction-jira.md` avec toutes les informations du XML (optionnel)

### Option 2 : Mode dry-run (test sans modification)

Pour tester ce qui serait fait sans créer de fichiers :

```bash
DRY_RUN=true ./scripts/process-xml-file.sh "Jira/SPEX/SPEX-2990.xml"
```

### Option 3 : Génération automatique avec IA (Sans XML)

1. **Préparer le contexte** :
   - Collecter la User Story et spécifications
   - Rassembler l'historique du projet

2. **Utiliser le prompt** :
   - Ouvrir `templates/prompt-rapide.md` ou `prompt-generation-qa.md`
   - Personnaliser le prompt avec vos informations
   - Générer avec votre outil d'IA (ChatGPT, Claude, etc.)

3. **Sauvegarder** :
   - Placer les fichiers générés dans `projets/[PROJET]/us-[NUMBER]/`
   - Vérifier et compléter avec votre expertise

### Option 4 : Création manuelle

```bash
# Créer la structure
mkdir -p projets/[NOM_PROJET]/us-[NUMBER]
cd projets/[NOM_PROJET]/us-[NUMBER]

# Copier les templates
cp ../../../templates/us-readme-template.md README.md
cp ../../../templates/questions-clarifications-template.md 01-questions-clarifications.md
cp ../../../templates/strategie-test-template.md 02-strategie-test.md
cp ../../../templates/cas-test-template.md 03-cas-test.md
```

### 3. Compléter dans l'ordre

1. ✅ **README.md** : Vue d'ensemble de l'US
2. ✅ **01-questions-clarifications.md** : Poser toutes les questions
3. ✅ **02-strategie-test.md** : Définir la stratégie
4. ✅ **03-cas-test.md** : Rédiger les scénarios détaillés

---

## 📋 Les 3 types de documents

### 📝 Partie 1 : Questions et Clarifications

**Fichier** : `01-questions-clarifications.md`

**Objectif** : Clarifier tous les points d'ombre avant de rédiger les tests.

**Contenu** :
- 🗣️ Questions pour le Product Manager (PM)
- 💻 Questions pour les Développeur(se)s
- 🎨 Questions pour le/la Product Designer

**Quand** : En début de sprint, avant de créer les tests.

---

### 🎯 Partie 2a : Stratégie de Test

**Fichier** : `02-strategie-test.md`

**Objectif** : Définir la stratégie de test et les axes prioritaires.

**Contenu** :
- Objectif principal
- Axes de test (nominaux, limites, erreurs, sécurité, performance, etc.)
- Zones à risque et non-régression
- Métriques et critères de succès

**Quand** : Après avoir obtenu les réponses aux questions.

---

### 🧪 Partie 2b : Cas de Test

**Fichier** : `03-cas-test.md`

**Objectif** : Décrire en détail tous les scénarios de test.

**Contenu** :
- 21+ scénarios de test structurés par catégorie
- Données de test et résultats attendus
- Section pour bugs identifiés
- Résumé des tests

**Quand** : Après avoir validé la stratégie de test.

---

## 🔗 Liens entre documents

Chaque document contient une section "Documents associés" avec :
- ✅ Lien vers les questions/clarifications
- ✅ Lien vers la stratégie de test
- ✅ Lien vers les cas de test
- ✅ Lien vers la User Story (Jira/Ticket)

---

## 📝 Convention de nommage

### Dossiers
- **Projets** : `nom-projet` (minuscules avec tirets)
- **User Stories** : `us-[NUMBER]` (ex: `us-123`, `us-456`)

### Fichiers
- `README.md` : Vue d'ensemble de l'US
- `01-questions-clarifications.md` : Questions
- `02-strategie-test.md` : Stratégie
- `03-cas-test.md` : Cas de test

---

## ✅ Checklist

### Créer une nouvelle documentation

- [ ] Structure de dossiers créée (`projets/[PROJET]/us-[NUMBER]/`)
- [ ] README.md créé avec vue d'ensemble
- [ ] `01-questions-clarifications.md` créé
- [ ] `02-strategie-test.md` créé
- [ ] `03-cas-test.md` créé
- [ ] Tous les liens entre documents sont à jour

### Compléter la documentation

- [ ] Toutes les questions ont reçu une réponse
- [ ] Stratégie de test validée avec l'équipe
- [ ] Tous les scénarios de test sont documentés
- [ ] Tests exécutés et résultats documentés

---

## 📚 Ressources

- **Guide général** : `README.md`
- **Guide des templates** : `templates/README.md`
- **Guide des projets** : `projets/README.md`
- **Exemple** : `projets/exemple-projet/us-001/`

---

## 🆘 Besoin d'aide ?

Consultez les README dans chaque dossier pour plus de détails :
- `README.md` : Guide général complet
- `templates/README.md` : Description détaillée de chaque template
- `projets/README.md` : Guide de création d'une nouvelle documentation

