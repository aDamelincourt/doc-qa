# 🤖 Utilisation de l'agent Cursor IA (sans clé API externe)

Si vous n'avez pas de clé API externe (OpenAI, Claude), vous pouvez utiliser directement l'agent IA intégré dans Cursor pour générer vos documents QA.

## 🎯 Principe

Au lieu d'appeler une API externe, le système :
1. **Prépare un prompt optimisé** avec tout le contexte de la US
2. **Vous présente le prompt** dans la conversation
3. **Vous copiez le prompt** et me le donnez
4. **Je génère le contenu** directement dans cette conversation
5. **Vous sauvegardez** le résultat dans le fichier

## 🚀 Utilisation

### Méthode 1 : Automatique (recommandé)

Le script `process-xml-file.sh` détecte automatiquement l'absence de clé API et prépare les prompts :

```bash
./scripts/process-xml-file.sh Jira/ACCOUNT/ACCOUNT-3239.xml
```

Le script va :
1. Créer la structure de dossiers
2. Extraire les données du XML
3. Préparer des prompts optimisés pour chaque document
4. Vous indiquer comment procéder

### Méthode 2 : Manuelle

Générer un prompt pour un document spécifique :

```bash
# Questions de clarifications
./scripts/generate-with-cursor.sh questions projets/ACCOUNT/us-3239

# Stratégie de test
./scripts/generate-with-cursor.sh strategy projets/ACCOUNT/us-3239

# Cas de test
./scripts/generate-with-cursor.sh test-cases projets/ACCOUNT/us-3239
```

Générer tous les prompts d'un coup :

```bash
./scripts/generate-all-with-cursor.sh projets/ACCOUNT/us-3239
```

## 📝 Workflow détaillé

### Étape 1 : Préparer les prompts

```bash
./scripts/generate-all-with-cursor.sh projets/ACCOUNT/us-3239
```

Le script va créer des fichiers de prompt temporaires avec tout le contexte nécessaire.

### Étape 2 : Copier le prompt

Le script vous indiquera où se trouve le fichier de prompt. Ouvrez-le :

```bash
cat /tmp/prompt_questions_XXXXXX
```

Copiez **TOUT** le contenu.

### Étape 3 : Demander à l'agent

Dans cette conversation avec moi (l'agent Cursor), dites :

```
Génère le document questions en suivant exactement ce prompt :

[collez ici le contenu complet du prompt]
```

### Étape 4 : Sauvegarder le résultat

Je vais générer le contenu Markdown complet. Copiez-le et sauvegardez-le dans :

```bash
# Pour les questions
projets/ACCOUNT/us-3239/01-questions-clarifications.md

# Pour la stratégie
projets/ACCOUNT/us-3239/02-strategie-test.md

# Pour les cas de test
projets/ACCOUNT/us-3239/03-cas-test.md
```

## 🎯 Exemple complet

```bash
# 1. Préparer tous les prompts
./scripts/generate-all-with-cursor.sh projets/ACCOUNT/us-3239

# 2. Le script vous indique les fichiers de prompt
# Exemple : /tmp/prompt_questions_abc123

# 3. Copier le contenu
cat /tmp/prompt_questions_abc123

# 4. Dans Cursor, me dire :
# "Génère le document questions en suivant exactement ce prompt :
# [coller le contenu]"

# 5. Je génère le contenu, vous le copiez et le sauvegardez
```

## ✨ Avantages

- ✅ **Gratuit** : Pas besoin de clé API externe
- ✅ **Puissant** : Utilise les capacités complètes de l'agent Cursor
- ✅ **Flexible** : Vous pouvez ajuster les prompts si nécessaire
- ✅ **Interactif** : Vous pouvez demander des modifications ou clarifications

## 🔄 Alternative : Génération directe

Vous pouvez aussi me demander directement de générer sans passer par les scripts :

1. **Donnez-moi le contexte** :
   ```
   Génère les questions de clarifications pour la US ACCOUNT-3239.
   Le fichier XML est dans Jira/ACCOUNT/ACCOUNT-3239.xml
   ```

2. **Je vais** :
   - Lire le XML
   - Analyser le contexte
   - Générer le document complet

3. **Vous sauvegardez** le résultat dans le fichier approprié

## 📊 Comparaison

| Aspect | API Externe | Agent Cursor |
|--------|-------------|--------------|
| Coût | ~$0.01-0.03/US | Gratuit |
| Vitesse | Automatique | Interactif |
| Qualité | Excellente | Excellente |
| Flexibilité | Limitée | Totale |
| Configuration | Clé API requise | Aucune |

## 💡 Astuce

Pour accélérer le processus, vous pouvez me demander de générer les 3 documents d'un coup :

```
Génère les 3 documents QA (questions, stratégie, cas de test) pour la US ACCOUNT-3239.
Le fichier XML est dans Jira/ACCOUNT/ACCOUNT-3239.xml
Utilise les templates dans templates/
```

Je générerai les 3 documents complets que vous pourrez sauvegarder directement.

