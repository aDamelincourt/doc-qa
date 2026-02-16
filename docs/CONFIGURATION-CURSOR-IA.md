# 🤖 Configuration de l'IA Cursor comme Voie Prépondérante

Ce document explique les 3 options pour intégrer l'IA Cursor dans les scripts et comment les configurer.

---

## 📋 Les 3 Options d'Intégration

### Option 1 : CLI Cursor avec Génération Directe (Recommandée)

**Description** : Les scripts utilisent le CLI Cursor (`cursor-agent`) pour générer directement les documents.

**Avantages** :
- ✅ Génération automatique sans intervention manuelle
- ✅ Intégration native dans les scripts
- ✅ Compatible avec CI/CD
- ✅ Voie prépondérante par défaut

**Configuration** :
1. Installer le CLI Cursor (voir `INSTALLATION-CURSOR-CLI.md`)
2. Configurer `CURSOR_API_KEY`
3. Les scripts détectent automatiquement le CLI et l'utilisent

**Utilisation** :
```bash
./scripts/process-xml-file.sh "Jira/ACCOUNT/ACCOUNT-2608.xml"
# Les documents sont générés automatiquement avec Cursor IA
```

---

### Option 2 : Mode Prompt avec Fallback Automatique

**Description** : Si le CLI n'est pas disponible, les scripts préparent des prompts optimisés pour traitement manuel.

**Avantages** :
- ✅ Fonctionne même sans CLI installé
- ✅ Prompts optimisés et détaillés
- ✅ Compatible avec l'agent Cursor dans l'interface

**Configuration** :
- Aucune configuration nécessaire
- Les scripts basculent automatiquement vers ce mode si le CLI n'est pas disponible

**Utilisation** :
```bash
./scripts/process-xml-file.sh "Jira/ACCOUNT/ACCOUNT-2608.xml"
# Les prompts sont affichés, copiez-les dans Cursor pour génération
```

---

### Option 3 : Mode Mixte (CLI + Fallback)

**Description** : Les scripts tentent d'abord le CLI, puis basculent vers le mode prompt si nécessaire.

**Avantages** :
- ✅ Flexibilité maximale
- ✅ Fonctionne dans tous les environnements
- ✅ Dégradation gracieuse

**Configuration** :
- Installer le CLI (optionnel mais recommandé)
- Si le CLI n'est pas disponible, le mode prompt est utilisé automatiquement

**Utilisation** :
```bash
# Avec CLI : génération directe
# Sans CLI : prompts affichés
./scripts/process-xml-file.sh "Jira/ACCOUNT/ACCOUNT-2608.xml"
```

---

## 🚀 Installation du CLI Cursor

### Étape 1 : Installer le CLI

```bash
curl https://cursor.com/install -fsS | bash
```

### Étape 2 : Vérifier l'installation

```bash
cursor-agent --version
```

### Étape 3 : Ajouter au PATH (si nécessaire)

**Pour zsh (macOS)** :
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

**Pour bash** :
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

## 🔑 Récupération de la Clé API Cursor

### Méthode 1 : Clé API Cursor (Recommandée)

1. **Ouvrir Cursor** → `Settings` (ou `Cmd+,`)
2. **Section "Models" ou "API Keys"**
3. **Cliquer sur "Generate API Key" ou "Create API Key"**
4. **Copier la clé** (commence par `cur_`)
   - ⚠️ Copiez-la immédiatement, elle ne sera affichée qu'une fois

### Méthode 2 : Clé API Personnalisée

1. **Ouvrir Cursor** → `Settings` → `Models`
2. **Section "API Keys"**
3. **Choisir le fournisseur** (OpenAI, Anthropic, Google, etc.)
4. **Entrer votre clé API**
5. **Cliquer sur "Verify"**

---

## ⚙️ Configuration de la Clé API

### Méthode 1 : Variable d'environnement (Recommandée)

**Temporaire** :
```bash
export CURSOR_API_KEY="cur_votre_cle_api_ici"
```

**Permanent (zsh)** :
```bash
echo 'export CURSOR_API_KEY="cur_votre_cle_api_ici"' >> ~/.zshrc
source ~/.zshrc
```

**Permanent (bash)** :
```bash
echo 'export CURSOR_API_KEY="cur_votre_cle_api_ici"' >> ~/.bashrc
source ~/.bashrc
```

### Méthode 2 : Fichier .env (Plus sécurisé)

Créer `.env` à la racine du projet :
```bash
# .env
CURSOR_API_KEY=cur_votre_cle_api_ici
```

Ajouter au `.gitignore` :
```
.env
```

Charger dans les scripts (déjà fait dans `config.sh`) :
```bash
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi
```

---

## ✅ Vérification de la Configuration

### Test 1 : CLI Disponible

```bash
which cursor-agent
# Devrait afficher : /Users/votre_user/.local/bin/cursor-agent
```

### Test 2 : Clé API Configurée

```bash
echo $CURSOR_API_KEY
# Devrait afficher votre clé (commence par cur_)
```

### Test 3 : Génération Directe

```bash
cd "/Users/aDamelincourt/Sites/Doc QA"
./scripts/process-xml-file.sh "Jira/ACCOUNT/ACCOUNT-2608.xml"
```

Si tout est configuré :
- ✅ Les documents sont générés automatiquement
- ✅ Pas de prompts à copier-coller
- ✅ Génération directe avec Cursor IA

---

## 🔧 Modifications Apportées aux Scripts

### 1. `scripts/lib/cursor-ai-utils.sh`

**Fonction `generate_with_cursor_agent()`** :
- Détecte automatiquement `cursor-agent` ou `cursor`
- Utilise le CLI en mode non-interactif (`-p --force`)
- Utilise `CURSOR_API_KEY` si disponible
- Bascule vers le mode prompt si le CLI n'est pas disponible

**Fonction `generate_document_directly()`** :
- Fonction principale pour générer directement
- Prépare le contexte depuis le XML
- Appelle `generate_with_cursor_agent()`

### 2. `scripts/process-xml-file.sh`

**Modifications** :
- Charge `cursor-ai-utils.sh`
- Utilise `generate_document_directly()` comme voie principale
- Bascule vers les scripts classiques si Cursor IA échoue

**Avant** :
```bash
# Préparait juste un prompt
"$GENERATE_WITH_CURSOR_SCRIPT" "questions" "$US_DIR"
```

**Après** :
```bash
# Génère directement avec Cursor IA
generate_document_directly "questions" "$US_DIR"
```

---

## 📊 Flux de Génération

```
┌─────────────────────────────────────────────────────────┐
│  process-xml-file.sh                                    │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│  generate_document_directly()                           │
│  (voie prépondérante)                                   │
└────────────────────┬────────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
        ▼                         ▼
┌───────────────┐        ┌───────────────┐
│ CLI Cursor    │        │ Mode Prompt   │
│ disponible ?  │        │ (fallback)    │
└───────┬───────┘        └───────────────┘
        │
        ▼
┌─────────────────────────────────────────────────────────┐
│  cursor-agent -p --force                                │
│  (génération directe)                                   │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│  Document généré automatiquement                        │
│  (01-questions-clarifications.md)                       │
└─────────────────────────────────────────────────────────┘
```

---

## 🎯 Résultat Attendu

### Avec CLI Cursor Configuré

```bash
$ ./scripts/process-xml-file.sh "Jira/ACCOUNT/ACCOUNT-2608.xml"

📋 Génération avec agent Cursor IA (voie prépondérante)...
🤖 Utilisation du CLI Cursor pour génération directe (voie prépondérante)...
   Génération en cours avec Cursor CLI...
✅ Document généré directement avec Cursor CLI : projets/ACCOUNT/us-2608/01-questions-clarifications.md
✅ Document généré directement avec Cursor CLI : projets/ACCOUNT/us-2608/02-strategie-test.md
✅ Document généré directement avec Cursor CLI : projets/ACCOUNT/us-2608/03-cas-test.md
```

### Sans CLI Cursor

```bash
$ ./scripts/process-xml-file.sh "Jira/ACCOUNT/ACCOUNT-2608.xml"

📋 Génération avec agent Cursor IA (voie prépondérante)...
📋 Fichier de prompt créé : /tmp/prompt_xxx.md
🤖 Pour générer avec l'agent Cursor :
   1. Ouvrez le fichier : /tmp/prompt_xxx.md
   2. Copiez tout le contenu
   3. Dans Cursor, demandez à l'agent : ...
```

---

## 🔒 Sécurité

⚠️ **Important** :
- Ne commitez **jamais** votre clé API dans Git
- Ajoutez `.env` au `.gitignore`
- Ne partagez pas votre clé API
- Régénérez la clé si elle est compromise

---

## ✅ Checklist de Configuration

- [ ] CLI Cursor installé (`cursor-agent --version`)
- [ ] CLI ajouté au PATH
- [ ] Clé API Cursor générée
- [ ] Variable `CURSOR_API_KEY` configurée
- [ ] Test de génération réussi
- [ ] Scripts utilisent automatiquement le CLI
- [ ] Mode fallback fonctionne si CLI indisponible

---

## 📚 Ressources

- **Guide d'installation** : `docs/INSTALLATION-CURSOR-CLI.md`
- **Documentation Cursor CLI** : https://docs.cursor.com/en/cli
- **Référence API** : https://docs.cursor.com/en/cli/reference/authentication

---

Une fois configuré, l'IA Cursor sera utilisée **automatiquement** comme voie prépondérante dans tous les scripts ! 🚀
