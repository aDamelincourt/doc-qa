# 🤖 Guide d'utilisation de Cursor IA pour génération de documents QA

## 🎯 Objectif

Ce guide explique comment utiliser l'agent Cursor IA (moi) pour générer des documents QA **complets, exhaustifs et détaillés** à partir des exports XML Jira.

---

## 🚀 Workflow recommandé

### Étape 1 : Traiter le fichier XML

```bash
./scripts/process-xml-file.sh "Jira/ACCOUNT/ACCOUNT-2608.xml"
```

Le script va :
1. ✅ Créer la structure de dossiers
2. ✅ Extraire toutes les données du XML
3. ✅ Générer `extraction-jira.md` (complet automatiquement)
4. ✅ Préparer les prompts détaillés pour Cursor IA
5. ✅ Afficher les prompts dans la console

### Étape 2 : Utiliser les prompts avec l'agent Cursor

Le script affiche les prompts complets dans la console. **Copiez chaque prompt** et donnez-le à l'agent Cursor (moi) dans cette conversation.

**Exemple de commande à me donner** :

```
Génère le document questions en suivant exactement ce prompt :

[Collez ici le contenu complet du prompt affiché par le script]
```

### Étape 3 : Sauvegarder les documents générés

Une fois que j'ai généré le contenu, copiez-le et sauvegardez-le dans le fichier correspondant :
- `projets/ACCOUNT/us-2608/01-questions-clarifications.md`
- `projets/ACCOUNT/us-2608/02-strategie-test.md`
- `projets/ACCOUNT/us-2608/03-cas-test.md`

---

## 📋 Scripts disponibles

### 1. Générer un document spécifique

```bash
# Questions de clarifications
./scripts/generate-with-cursor-direct.sh questions projets/ACCOUNT/us-2608

# Stratégie de test
./scripts/generate-with-cursor-direct.sh strategy projets/ACCOUNT/us-2608

# Cas de test
./scripts/generate-with-cursor-direct.sh test-cases projets/ACCOUNT/us-2608
```

### 2. Générer tous les documents d'un coup

```bash
./scripts/generate-with-cursor-direct.sh all projets/ACCOUNT/us-2608
```

Le script affichera les 3 prompts complets que vous pourrez me donner un par un.

---

## 🎓 Avantages de l'utilisation de Cursor IA

### ✅ Exhaustivité
- Génère **50-80+ questions** au lieu de 30-40
- Génère **30-50+ cas de test** au lieu de 15-25
- Identifie **tous les axes de test** pertinents (15+ au lieu de 8)

### ✅ Détails
- Chaque section est **ultra-détaillée** avec exemples concrets
- Les questions incluent le **contexte et les risques**
- Les cas de test sont **actionnables** avec étapes précises

### ✅ Contexte
- **Comprend le domaine métier** et adapte le contenu
- **Analyse en profondeur** les AC et la description
- **Identifie les edge cases** non évidents

### ✅ Qualité
- Contenu **directement utilisable** sans modification
- **Terminologie exacte** du projet
- **Formatage Markdown** correct

---

## 📝 Format des prompts

Les prompts préparés contiennent :

1. **🎯 OBJECTIF** : Ce qui doit être généré
2. **📋 CONTEXTE COMPLET** : Toutes les données de la US
   - Informations générales
   - Description complète
   - Critères d'acceptation formatés
   - Commentaires de l'équipe
   - Liens de design (Figma, Miro)
   - Extraction Jira complète
3. **📝 TEMPLATE** : Format à suivre exactement
4. **🎓 INSTRUCTIONS DÉTAILLÉES** : Instructions ultra-détaillées
5. **✅ CRITÈRES DE QUALITÉ** : Standards à respecter
6. **🚀 TÂCHE** : Ce que l'agent doit faire

---

## 🔄 Workflow complet avec exemple

### Exemple : ACCOUNT-2608

```bash
# 1. Traiter le XML
./scripts/process-xml-file.sh "Jira/ACCOUNT/ACCOUNT-2608.xml"
```

Le script affiche :
```
📝 PROMPT PRÊT POUR L'AGENT CURSOR IA
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 CONTENU DU PROMPT (à copier ci-dessous)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Prompt pour génération questions avec l'agent Cursor IA
...
[Contenu complet du prompt]
...
```

### 2. Copier le prompt et me le donner

Dans cette conversation, dites-moi :

```
Génère le document questions en suivant exactement ce prompt :

# Prompt pour génération questions avec l'agent Cursor IA

## 🎯 OBJECTIF
...
[Collez TOUT le contenu du prompt]
...
```

### 3. Je génère le document complet

Je vais générer un document Markdown complet avec :
- 50-80+ questions pertinentes
- Contexte détaillé pour chaque question
- Organisation par catégories
- Exemples concrets

### 4. Sauvegarder le résultat

Copiez le contenu généré et sauvegardez-le dans :
```
projets/ACCOUNT/us-2608/01-questions-clarifications.md
```

---

## 💡 Astuces

### Pour obtenir encore plus de détails

Quand vous me donnez le prompt, vous pouvez ajouter :

```
Génère le document questions en suivant exactement ce prompt :

[Prompt complet]

IMPORTANT : Sois encore plus exhaustif et génère au minimum 80 questions avec des détails très précis pour chaque question.
```

### Pour régénérer un document

Si vous voulez régénérer un document existant :

```bash
./scripts/generate-with-cursor-direct.sh questions projets/ACCOUNT/us-2608
```

Puis donnez-moi le nouveau prompt.

### Pour traiter plusieurs US

```bash
# Traiter tous les XML non traités
./scripts/process-unprocessed.sh

# Puis pour chaque US, générer les prompts
./scripts/generate-with-cursor-direct.sh all projets/ACCOUNT/us-2608
```

---

## 📊 Comparaison : Bash vs Cursor IA

| Aspect | Génération Bash | Génération Cursor IA |
|--------|----------------|---------------------|
| **Questions** | 30-40 questions | 50-80+ questions |
| **Cas de test** | 15-25 scénarios | 30-50+ scénarios |
| **Stratégie** | 8 axes de test | 15+ axes de test |
| **Détails** | Basiques | Ultra-détaillés |
| **Contexte** | Patterns simples | Compréhension profonde |
| **Edge cases** | Limités | Exhaustifs |
| **Actionnabilité** | Moyenne | Directement utilisable |

---

## ✅ Checklist de génération

- [ ] XML traité avec `process-xml-file.sh`
- [ ] Prompts affichés dans la console
- [ ] Prompt questions copié et donné à l'agent Cursor
- [ ] Document questions généré et sauvegardé
- [ ] Prompt stratégie copié et donné à l'agent Cursor
- [ ] Document stratégie généré et sauvegardé
- [ ] Prompt cas de test copié et donné à l'agent Cursor
- [ ] Document cas de test généré et sauvegardé
- [ ] Tous les documents vérifiés et validés

---

## 🆘 Dépannage

### Le prompt n'est pas affiché

Vérifiez que :
- Le fichier XML existe et est valide
- Le dossier US existe
- Les bibliothèques sont correctement chargées

### L'agent Cursor ne génère pas assez de détails

Ajoutez dans votre demande :
```
IMPORTANT : Sois ultra-exhaustif et génère le maximum de détails possibles.
```

### Le document généré n'est pas au bon format

Vérifiez que vous avez copié **TOUT** le prompt, y compris la section "Template à suivre".

---

## 📚 Ressources

- **Scripts** : `scripts/README.md`
- **Fonctionnement** : `FONCTIONNEMENT-PROJET.md`
- **Templates** : `templates/README.md`

---

## 🎯 Résultat attendu

Avec Cursor IA, vous obtiendrez des documents :
- ✅ **Complets** : Tous les aspects couverts
- ✅ **Détaillés** : Chaque section est approfondie
- ✅ **Actionnables** : Directement utilisables par l'équipe QA
- ✅ **Contextuels** : Adaptés au domaine métier spécifique
- ✅ **Professionnels** : Formatage et structure parfaits

