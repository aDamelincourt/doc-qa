# Export vers Notion

## 📋 Description

Ce script permet d'exporter l'ensemble du dossier `projets/` au format CSV pour l'import dans Notion, avec un système d'historisation pour éviter les doublons.

## 🚀 Usage

### Export de base

```bash
./scripts/export-to-notion.sh
```

Cette commande :
- Exporte tous les US non encore exportés
- Crée un fichier CSV dans `exports/notion-export-YYYYMMDD-HHMMSS.csv`
- Met à jour l'historique dans `.history/exports-notion.json`

### Options disponibles

#### Forcer l'export (ré-exporter tous les US)

```bash
./scripts/export-to-notion.sh --force
```

#### Spécifier un fichier de sortie

```bash
./scripts/export-to-notion.sh --output exports/mon-export.csv
```

#### Combiner les options

```bash
./scripts/export-to-notion.sh --force --output exports/export-complet.csv
```

## 📊 Format du CSV

Le CSV généré contient les colonnes suivantes :

| Colonne | Description |
|---------|-------------|
| **Name** | Titre de la User Story |
| **Ticket Key** | Clé unique du ticket (ex: MME-1332, SPEX-2990) |
| **Project** | Nom du projet (MME, SPEX, ACCOUNT, etc.) |
| **Description** | Description de la User Story |
| **Questions** | Contenu du fichier `01-questions-clarifications.md` (limité à 3000 caractères) |
| **Strategy** | Contenu du fichier `02-strategie-test.md` (limité à 3000 caractères) |
| **Test Cases** | Contenu du fichier `03-cas-test.md` (limité à 5000 caractères) |
| **Status** | Statut (par défaut: "Draft") |
| **Link** | Lien vers le ticket Jira |
| **Created Date** | Date de traitement (depuis `.history/traitements.json`) |
| **Last Updated** | Date de dernière modification du README.md |

## 🔄 Historisation

Le script utilise un système d'historisation basé sur la **clé unique du ticket** (ex: `MME-1332`, `SPEX-2990`).

### Fichier d'historique

L'historique est stocké dans : `.history/exports-notion.json`

Format :
```json
{
  "MME-1332": {
    "export_date": "2025-11-19",
    "export_file": "/path/to/export.csv"
  },
  "SPEX-2990": {
    "export_date": "2025-11-19",
    "export_file": "/path/to/export.csv"
  }
}
```

### Comportement

- **Premier export** : Tous les US sont exportés
- **Exports suivants** : Seuls les US non encore exportés sont inclus
- **Option `--force`** : Force l'export de tous les US, même déjà exportés

## 📥 Import dans Notion

1. Ouvrir Notion
2. Créer une nouvelle base de données (ou utiliser une existante)
3. Cliquer sur "..." (menu) → **Import** → **CSV**
4. Sélectionner le fichier CSV généré dans `exports/`
5. Notion va automatiquement créer les colonnes et importer les données

### Configuration recommandée dans Notion

Après l'import, configurer les colonnes comme suit :

- **Ticket Key** : Type "Text" (propriété unique)
- **Project** : Type "Select" (avec les valeurs : MME, SPEX, ACCOUNT, DATA, EB)
- **Status** : Type "Select" (avec les valeurs : Draft, En cours, Testé, Validé)
- **Link** : Type "URL"
- **Created Date** : Type "Date"
- **Last Updated** : Type "Date"
- **Description, Questions, Strategy, Test Cases** : Type "Text" (long)

## 🔍 Vérification

### Voir l'historique des exports

```bash
cat .history/exports-notion.json | python3 -m json.tool
```

### Lister les fichiers CSV exportés

```bash
ls -lh exports/notion-export-*.csv
```

### Vérifier quels US sont déjà exportés

```bash
cat .history/exports-notion.json | grep -o '"[A-Z]\+-[0-9]\+"' | sort
```

## ⚠️ Notes importantes

1. **Clé unique** : La clé du ticket (ex: `MME-1332`) est utilisée comme identifiant unique. Si un ticket est déjà exporté, il sera ignoré lors des exports suivants (sauf avec `--force`).

2. **Limitation de taille** : Les contenus des fichiers markdown sont limités pour éviter des CSV trop volumineux :
   - Questions : 3000 caractères max
   - Strategy : 3000 caractères max
   - Test Cases : 5000 caractères max

3. **Échappement CSV** : Les guillemets et caractères spéciaux sont automatiquement échappés pour la compatibilité CSV.

4. **Fichiers manquants** : Si un fichier markdown est absent, la colonne correspondante sera vide (pas d'erreur).

## 🐛 Dépannage

### Erreur : "Aucun dossier US trouvé"

Vérifier que le dossier `projets/` contient des dossiers `us-XXXX/` :
```bash
find projets -type d -name "us-*"
```

### Erreur : "Impossible d'extraire la clé du ticket"

Le script ne peut pas extraire la clé depuis `extraction-jira.md`. Vérifier que le fichier existe et contient la ligne :
```
**Clé du ticket** : MME-1332
```

### Réinitialiser l'historique

Pour réinitialiser l'historique et tout ré-exporter :
```bash
rm .history/exports-notion.json
./scripts/export-to-notion.sh
```

## 📝 Exemple de sortie

```
ℹ️  📤 Export vers Notion CSV...

ℹ️  📊 Dossiers US trouvés : 15

ℹ️  📄 Traitement de : MME-1332
ℹ️  📄 Traitement de : SPEX-2990
...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ℹ️  📊 Résumé de l'export
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ ✅ Exportés : 15
⏭️  Ignorés (déjà exportés) : 0

✅ 📁 Fichier CSV créé : exports/notion-export-20251119-084028.csv
```

