# 📦 Installation et Configuration du CLI Cursor

Ce guide explique comment installer le CLI Cursor et configurer la clé API pour utiliser l'IA Cursor directement dans les scripts.

---

## 🎯 Objectif

Permettre aux scripts d'utiliser directement l'IA Cursor pour générer les documents QA, sans intervention manuelle.

**Utilisation automatique** : l'IA Cursor est utilisée automatiquement par le pipeline lorsque :
- le CLI est installé (`cursor-agent` ou `cursor` dans le PATH),
- et `CURSOR_API_KEY` est définie (variable d'environnement ou chargée depuis le fichier `.env` à la racine du projet).

Le pipeline charge `$BASE_DIR/.env` au démarrage (voir [scripts/lib/config.sh](../scripts/lib/config.sh)) ; ne commitez jamais ce fichier (il est dans `.gitignore`).

---

## 📋 Installation du CLI Cursor

### Étape 1 : Installer le CLI Cursor

Sur **macOS**, **Linux** ou **Windows (via WSL)**, exécutez :

```bash
curl https://cursor.com/install -fsS | bash
```

Cette commande :
- Télécharge le CLI Cursor
- L'installe dans `~/.local/bin/`
- Configure les permissions d'exécution

### Étape 2 : Vérifier l'installation

```bash
cursor-agent --version
```

Si la commande fonctionne, vous verrez la version installée.

### Étape 3 : Ajouter au PATH (si nécessaire)

Si la commande `cursor-agent` n'est pas trouvée, ajoutez le chemin au PATH :

**Pour bash** :
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

**Pour zsh** (macOS par défaut) :
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Étape 4 : Vérifier que tout fonctionne

```bash
cursor-agent --help
```

Vous devriez voir l'aide du CLI Cursor.

---

## 🔑 Récupération de la Clé API Cursor

### Option 1 : Clé API Cursor (recommandée)

1. **Ouvrir Cursor** (l'application)
2. **Aller dans les paramètres** :
   - `Cursor` → `Settings` (ou `Cmd+,` sur macOS)
3. **Section "Models" ou "API Keys"** :
   - Chercher la section "API Keys" ou "User API Keys"
   - Cliquer sur "Generate API Key" ou "Create API Key"
4. **Copier la clé générée** :
   - La clé ressemble à : `cur_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`
   - ⚠️ **Important** : Copiez-la immédiatement, elle ne sera affichée qu'une seule fois

### Option 2 : Clé API personnalisée (OpenAI, Anthropic, etc.)

Si vous préférez utiliser votre propre clé API :

1. **Ouvrir Cursor** → `Settings` → `Models`
2. **Section "API Keys"** :
   - Choisir le fournisseur (OpenAI, Anthropic, Google, etc.)
   - Entrer votre clé API
   - Cliquer sur "Verify" pour valider
3. **Note** : Cette clé sera utilisée pour les appels API, mais certaines fonctionnalités Cursor peuvent nécessiter un abonnement Pro

---

## ⚙️ Configuration de la Clé API dans les Scripts

### Méthode 1 : Fichier .env à la racine du projet (recommandé)

Créer un fichier `.env` à la **racine du projet** (à côté de `README.md`) :

```bash
# .env (à la racine du projet — ne pas commiter)
CURSOR_API_KEY=cur_votre_cle_api_ici
```

Le pipeline charge ce fichier automatiquement via `config.sh`. Aucun export manuel n'est nécessaire.

### Méthode 2 : Variable d'environnement

**Temporaire (session actuelle)** :
```bash
export CURSOR_API_KEY="cur_votre_cle_api_ici"
```

**Permanent (ajouter à votre shell)** :

**Pour bash** :
```bash
echo 'export CURSOR_API_KEY="cur_votre_cle_api_ici"' >> ~/.bashrc
source ~/.bashrc
```

**Pour zsh** :
```bash
echo 'export CURSOR_API_KEY="cur_votre_cle_api_ici"' >> ~/.zshrc
source ~/.zshrc
```

### Méthode 3 : Fichier de configuration dédié

Créer `~/.cursor/config.sh` :
```bash
#!/bin/bash
export CURSOR_API_KEY="cur_votre_cle_api_ici"
```

Puis dans vos scripts :
```bash
if [ -f ~/.cursor/config.sh ]; then
    source ~/.cursor/config.sh
fi
```

---

## ✅ Vérification de la Configuration

### Test 1 : Vérifier que le CLI est disponible

```bash
which cursor-agent
# Devrait afficher : /Users/votre_user/.local/bin/cursor-agent
```

### Test 2 : Vérifier que la clé API est configurée

```bash
echo $CURSOR_API_KEY
# Devrait afficher votre clé (commence par cur_)
```

### Test 3 : Tester une génération directe

```bash
cd "/Users/aDamelincourt/Sites/Doc QA"
./scripts/generate-with-cursor.sh questions projets/ACCOUNT/us-2608 --auto
```

Si tout est configuré correctement, le document sera généré directement.

---

## 🔧 Dépannage

### Problème : `cursor-agent: command not found`

**Solution** :
1. Vérifier que `~/.local/bin` est dans le PATH :
   ```bash
   echo $PATH | grep -q ".local/bin" && echo "OK" || echo "Manquant"
   ```
2. Ajouter au PATH (voir Étape 3 ci-dessus)
3. Redémarrer le terminal

### Problème : `CURSOR_API_KEY not set`

**Solution** :
1. Vérifier que la variable est définie :
   ```bash
   echo $CURSOR_API_KEY
   ```
2. Si vide, configurer avec une des méthodes ci-dessus
3. Redémarrer le terminal ou recharger la configuration

### Problème : Erreur d'authentification

**Solution** :
1. Vérifier que la clé API est correcte
2. Vérifier que la clé n'a pas expiré (générer une nouvelle clé si nécessaire)
3. Vérifier les permissions de la clé dans les paramètres Cursor

### Problème : Le CLI ne génère pas les documents

**Solution** :
1. Vérifier que le CLI fonctionne :
   ```bash
   cursor-agent --version
   ```
2. Tester manuellement :
   ```bash
   echo "Test prompt" | cursor-agent -p
   ```
3. Vérifier les logs d'erreur dans les scripts

---

## 📚 Ressources

- **Documentation officielle Cursor CLI** : https://docs.cursor.com/en/cli
- **Guide d'installation** : https://docs.cursor.com/en/cli/installation
- **Référence API** : https://docs.cursor.com/en/cli/reference/authentication

---

## 🎯 Résultat Attendu

Une fois configuré, les scripts utiliseront automatiquement le CLI Cursor pour générer les documents :

```bash
./scripts/process-xml-file.sh "Jira/ACCOUNT/ACCOUNT-2608.xml"
```

Les documents seront générés **directement** sans intervention manuelle :
- ✅ `01-questions-clarifications.md` généré automatiquement
- ✅ `02-strategie-test.md` généré automatiquement
- ✅ `03-cas-test.md` généré automatiquement

Si le CLI n'est pas disponible, les scripts basculeront automatiquement vers le mode prompt (affichage du prompt pour copier-coller).

---

## 🔒 Sécurité

⚠️ **Important** : Ne commitez **jamais** votre clé API dans le repository Git !

- Ajoutez `.env` au `.gitignore`
- Ne partagez pas votre clé API
- Régénérez la clé si elle est compromise

---

## ✅ Checklist de Configuration

- [ ] CLI Cursor installé (`cursor-agent --version` fonctionne)
- [ ] CLI ajouté au PATH
- [ ] Clé API Cursor générée
- [ ] Variable `CURSOR_API_KEY` configurée
- [ ] Test de génération réussi
- [ ] Scripts utilisent automatiquement le CLI

---

Une fois ces étapes complétées, l'IA Cursor sera utilisée **directement** par les scripts comme voie prépondérante ! 🚀
