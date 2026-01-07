# Projets - Documentation QA

Ce dossier contient la documentation QA organisée par projet et par User Story.

---

## 📁 Structure

```
projets/
├── [NOM_PROJET]/          # Nom du projet (minuscules avec tirets)
│   └── us-[NUMBER]/       # User Story (ex: us-001, us-123)
│       ├── README.md      # Vue d'ensemble de l'US
│       ├── 01-questions-clarifications.md
│       ├── 02-strategie-test.md
│       └── 03-cas-test.md
└── exemple-projet/        # Exemple de structure
    └── us-001/            # Exemple d'US
```

---

## 🚀 Créer une nouvelle documentation

### 1. Créer la structure de dossiers

```bash
mkdir -p projets/[NOM_PROJET]/us-[NUMBER]
cd projets/[NOM_PROJET]/us-[NUMBER]
```

### 2. Copier les templates

```bash
# Depuis le dossier us-[NUMBER]/
cp ../../../templates/us-readme-template.md README.md
cp ../../../templates/questions-clarifications-template.md 01-questions-clarifications.md
cp ../../../templates/strategie-test-template.md 02-strategie-test.md
cp ../../../templates/cas-test-template.md 03-cas-test.md
```

### 3. Compléter les documents dans l'ordre

1. **README.md** : Vue d'ensemble de l'US
2. **01-questions-clarifications.md** : Poser toutes les questions nécessaires
3. **02-strategie-test.md** : Définir la stratégie de test
4. **03-cas-test.md** : Rédiger tous les scénarios détaillés

---

## 📝 Convention de nommage

- **Projets** : `nom-projet` (minuscules, tirets)
- **User Stories** : `us-[NUMBER]` (ex: `us-123`, `us-456`)
- **Fichiers** : `01-questions-clarifications.md`, `02-strategie-test.md`, `03-cas-test.md`

---

## 🔗 Voir aussi

- `../templates/README.md` : Guide des templates
- `../README.md` : Guide général de la documentation QA

