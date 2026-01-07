# Dossier Jira - Exports XML

## 📁 Structure

Ce dossier contient les exports XML des tickets Jira, organisés par projet :

```
Jira/
├── [NOM_PROJET]/              # Ex: SPEX, MME, etc.
│   ├── [TICKET-ID].xml        # Ex: SPEX-2990.xml, MME-931.xml
│   └── [TICKET-ID].xml        # Autres tickets du projet
└── [AUTRE_PROJET]/            # Autres projets
    └── [TICKET-ID].xml
```

### Convention de nommage

- **Dossier projet** : Nom du projet en majuscules (ex: `SPEX`, `MME`, `BACKOFFICE`)
- **Fichier XML** : Clé du ticket avec extension `.xml` (ex: `SPEX-2990.xml`)

---

## 🔍 Exemples

- `Jira/SPEX/SPEX-2990.xml` : Ticket SPEX-2990 du projet SPEX
- `Jira/MME/MME-931.xml` : Ticket MME-931 du projet MME
- `Jira/BACKOFFICE/BO-123.xml` : Ticket BO-123 du projet BACKOFFICE

---

## 📝 Utilisation

### Pour extraire des informations depuis un export XML

1. **Localiser le fichier XML** :
   - Ouvrir `Jira/[NOM_PROJET]/[TICKET-ID].xml`

2. **Parser le XML** :
   - Utiliser le guide `../templates/extraction-jira-xml-guide.md`
   - Ou ouvrir directement dans un éditeur/viewer XML

3. **Structurer les informations** :
   - Utiliser le template `../templates/extraction-jira-template.md`
   - Extraire les informations depuis le XML
   - Remplir le template

4. **Générer la documentation** :
   - Utiliser le prompt `../templates/prompt-generation-qa.md`
   - Personnaliser avec les informations extraites
   - Générer la documentation QA complète

---

## 🛠️ Workflow recommandé

### Étape 1 : Exporter depuis Jira

1. Dans Jira, exporter le ticket au format XML
2. Sauvegarder dans `Jira/[NOM_PROJET]/[TICKET-ID].xml`
3. Si le dossier projet n'existe pas, le créer

### Étape 2 : Parser et extraire

1. Ouvrir `Jira/[NOM_PROJET]/[TICKET-ID].xml`
2. Consulter `../templates/extraction-jira-xml-guide.md` pour parser
3. Utiliser `../templates/extraction-jira-template.md` pour structurer

### Étape 3 : Générer la documentation

1. Créer la structure : `projets/[NOM_PROJET]/us-[NUMBER]/`
2. Utiliser le prompt `../templates/prompt-generation-qa.md`
3. Remplir avec les informations extraites du XML
4. Générer les 3 documents QA

### Étape 4 : Sauvegarder

1. Sauvegarder la documentation générée dans `projets/[NOM_PROJET]/us-[NUMBER]/`
2. Le fichier XML reste dans `Jira/[NOM_PROJET]/` pour référence

---

## 💡 Astuces

### Organiser les exports

- **Un dossier par projet** : Facilite la recherche et l'organisation
- **Nom de fichier = Clé du ticket** : Facilite l'identification
- **Garder les exports** : Utile pour référence ultérieure et historique

### Exporter plusieurs tickets

Pour exporter plusieurs tickets d'un projet :
1. Créer un fichier par ticket : `[TICKET-1].xml`, `[TICKET-2].xml`, etc.
2. Ou créer un fichier global : `[PROJET]-export.xml` (nécessite parsing différent)

### Rechercher un ticket

Pour trouver rapidement un ticket :
```bash
# Rechercher par clé de ticket
find Jira/ -name "SPEX-2990.xml"

# Lister tous les tickets d'un projet
ls Jira/SPEX/
```

---

## 🔗 Voir aussi

- `../templates/extraction-jira-xml-guide.md` : Guide pour parser le XML
- `../templates/extraction-jira-template.md` : Template pour structurer les informations
- `../templates/prompt-generation-qa.md` : Prompt pour générer la documentation
- `../README.md` : Guide général de la documentation QA

---

## 📋 Checklist

Avant de générer la documentation QA :

- [ ] Fichier XML exporté et sauvegardé dans `Jira/[NOM_PROJET]/[TICKET-ID].xml`
- [ ] XML parsé et informations extraites (voir guide XML)
- [ ] Template d'extraction rempli (voir template)
- [ ] Prompt personnalisé avec les informations extraites
- [ ] Documentation générée et sauvegardée dans `projets/[NOM_PROJET]/us-[NUMBER]/`

