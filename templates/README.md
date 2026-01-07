# Templates de documentation QA

Ce dossier contient les templates réutilisables pour créer la documentation QA d'une User Story.

---

## 📋 Liste des templates

### 1. `questions-clarifications-template.md`

**Usage** : Première étape - Clarifier tous les points d'ombre avant de rédiger les tests.

**Contenu** :
- Questions pour le Product Manager (PM)
- Questions pour les Développeur(se)s
- Questions pour le/la Product Designer
- Section de validation des réponses

**Quand l'utiliser** : 
- En début de sprint, avant de commencer les tests
- Lorsqu'il y a des ambiguïtés dans les critères d'acceptation
- Avant de créer les documents de stratégie et de cas de test

---

### 2. `strategie-test-template.md`

**Usage** : Deuxième étape - Définir la stratégie de test et les axes prioritaires.

**Contenu** :
- Objectif de la fonctionnalité
- Prérequis
- Axes de test et points de vigilance :
  - Scénarios nominaux
  - Cas limites et robustesse
  - Gestion des erreurs
  - Sécurité et autorisations
  - Performance
  - Intégration
  - Compatibilité
  - Accessibilité
- Impacts et non-régression
- Métriques et critères de succès
- Tests de régression

**Quand l'utiliser** : 
- Après avoir obtenu les réponses aux questions et clarifications
- Avant de rédiger les cas de test détaillés
- Pour valider l'approche de test avec l'équipe QA

---

### 3. `cas-test-template.md`

**Usage** : Troisième étape - Décrire en détail tous les scénarios de test.

**Contenu** :
- 21 scénarios de test structurés par catégorie :
  - 📌 Cas nominaux (2 scénarios)
  - 🔢 Cas limites (4 scénarios)
  - ❌ Cas d'erreur (5 scénarios)
  - 🔒 Cas de sécurité/autorisations (2 scénarios)
  - ⚡ Cas de performance (2 scénarios)
  - 🔄 Cas d'intégration (2 scénarios)
  - 🌐 Cas de compatibilité (2 scénarios)
  - ♿ Cas d'accessibilité (2 scénarios)
- Section pour bugs identifiés
- Résumé des tests

**Quand l'utiliser** : 
- Après avoir validé la stratégie de test
- Pour documenter tous les scénarios de test à exécuter
- Pendant et après l'exécution des tests pour documenter les résultats

---

### 4. `prompt-generation-qa.md` et `prompt-rapide.md`

**Usage** : Générer automatiquement la documentation QA avec l'aide de l'IA.

**Contenu** :
- Prompt complet avec instructions détaillées (`prompt-generation-qa.md`)
- Version simplifiée pour utilisation rapide (`prompt-rapide.md`)
- Guide d'utilisation et exemples

**Quand l'utiliser** : 
- Pour accélérer la création de documentation QA
- Lorsque vous avez une User Story complète avec spécifications
- Pour générer une première version à compléter avec votre expertise

---

### 5. `extraction-jira-template.md`

**Usage** : Structurer les informations extraites depuis un ticket Jira.

**Contenu** :
- Template d'extraction avec toutes les sections nécessaires
- Instructions pour extraire depuis Jira (web ou XML)
- Checklist d'extraction
- Astuces pour extraction rapide vs complète

**Quand l'utiliser** : 
- Avant d'utiliser les prompts de génération
- Pour structurer les informations extraites d'un ticket Jira
- Après avoir parsé un export XML (voir guide XML)
- Pour s'assurer de ne rien oublier lors de l'extraction

---

### 6. `extraction-jira-xml-guide.md`

**Usage** : Parser et extraire les informations depuis un export XML de Jira.

**Contenu** :
- Guide pour comprendre la structure XML de Jira
- Instructions pour parser le XML (manuel ou script)
- Informations à extraire depuis les balises XML
- Outils utiles pour parser XML
- Exemples de scripts (Python, JavaScript)

**Quand l'utiliser** : 
- Lorsque vous exportez les tickets Jira en format XML
- Pour comprendre la structure XML avant extraction
- Pour automatiser l'extraction avec des scripts

---

## 🔄 Processus de création

### Ordre recommandé

1. **Questions et Clarifications** → Clarifier les points d'ombre
2. **Stratégie de Test** → Définir l'approche
3. **Cas de Test** → Rédiger les scénarios détaillés

### Bonnes pratiques

- **Adaptez les templates** : Ne supprimez pas les sections, mais adaptez-les à votre contexte
- **Gardez les numéros** : Si vous supprimez un scénario, gardez la numérotation pour la cohérence
- **Complétez tous les champs** : Les placeholders `[À compléter]` doivent être remplis
- **Liez les documents** : Assurez-vous que les liens entre documents sont à jour

---

## 📝 Personnalisation

Chaque template contient des sections avec des exemples. Remplacez-les par :
- Les informations spécifiques à votre feature
- Les données réelles de test
- Les comportements attendus réels

---

## 🔗 Voir aussi

- `../README.md` : Guide général de la documentation QA
- Exemples dans `../projets/` : Voir des documentations complètes pour référence

