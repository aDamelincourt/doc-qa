# Template d'extraction Jira

## 📋 Guide d'extraction depuis Jira

Ce template vous aide à extraire toutes les informations nécessaires depuis un ticket Jira pour générer la documentation QA complète.

**Formats supportés** :
- ✅ Export XML depuis Jira (voir `extraction-jira-xml-guide.md` pour le guide XML)
- ✅ Copier-coller depuis l'interface Jira web
- ✅ Export CSV ou autres formats

---

## 🔍 Informations à extraire du ticket Jira

> **Note** : Si vous exportez depuis XML, consultez d'abord `extraction-jira-xml-guide.md` pour savoir comment parser le XML, puis utilisez ce template pour structurer les informations extraites.

### 1. Informations générales

```
**Clé du ticket** : [Ex: MME-931]
**Titre/Summary** : [Titre de la User Story]
**Type** : [Story / Bug / Task / etc.]
**Statut** : [To Do / In Progress / Done / etc.]
**Sprint** : [Sprint XX]
**Version** : [vX.X.X]
**Lien Jira** : [URL complète du ticket]
```

---

### 2. Description / User Story

```
**En tant que** : [Persona/Type d'utilisateur]

**Je veux** : [Action souhaitée]

**Afin de** : [Bénéfice/objectif]

**Description détaillée** :
[Coller ici la description complète de la User Story]
```

---

### 3. Critères d'acceptation

```
**Scénario 1** : [Nom du scénario]
- Given : [Précondition]
- When : [Action]
- Then : [Résultat attendu]

**Scénario 2** : [Nom du scénario]
- Given : [Précondition]
- When : [Action]
- Then : [Résultat attendu]

[... Ajouter tous les scénarios ...]
```

---

### 4. Informations techniques (si disponibles dans Jira)

```
**Module/Section concerné** : [Ex: Back-office, Front-office, API]
**Fichiers modifiés** : [Liste des fichiers principaux]
**APIs concernées** : [Liste des APIs utilisées/modifiées]
**Intégrations** : [Services externes, modules tiers]
**Base de données** : [Tables/collections concernées]
```

---

### 5. Design / UI (si disponible)

```
**Lien Figma** : [URL du design]
**Composants utilisés** : [Liste des composants PUIK ou autres]
**États à tester** : [Vide, Chargement, Erreur, Succès, etc.]
**Responsive** : [Desktop / Tablet / Mobile]
**Maquettes** : [Liens vers les différents écrans]
```

---

### 6. Contraintes et dépendances

```
**Dépendances** : 
- [Dépendance 1]
- [Dépendance 2]

**Contraintes techniques** : 
- [Contrainte 1]
- [Contrainte 2]

**Tests de non-régression** :
- [Feature A à vérifier]
- [Feature B à vérifier]
```

---

### 7. Notes et commentaires (de l'équipe)

```
**Commentaires du PM** :
[Copier les commentaires pertinents du Product Manager]

**Commentaires des Dev** :
[Copier les commentaires techniques pertinents]

**Commentaires du Designer** :
[Copier les commentaires UI/UX pertinents]

**Questions soulevées** :
[Questions déjà posées dans le ticket]
```

---

### 8. Tickets liés

```
**Tickets bloquants** : [Liste des tickets qui bloquent celui-ci]
**Tickets liés** : [Liste des tickets connexes]
**Bugs connus** : [Liste des bugs déjà identifiés]
**Tickets de tests précédents** : [Documentations QA précédentes du même projet]
```

---

## 📝 Instructions d'utilisation

### Étape 1 : Extraire depuis Jira

1. Ouvrir le ticket Jira concerné
2. Utiliser ce template pour structurer les informations
3. Copier-coller chaque section dans le template ci-dessus
4. Si une section n'est pas disponible dans Jira, laisser vide ou mettre "N/A"

### Étape 2 : Utiliser dans le prompt

1. Ouvrir `prompt-generation-qa.md` ou `prompt-rapide.md`
2. Remplacer les sections correspondantes par les informations extraites
3. Coller dans votre outil d'IA pour générer la documentation

### Étape 3 : Compléter avec l'historique

1. Chercher les tickets QA précédents du même projet
2. Extraire les patterns identifiés, zones à risque
3. Ajouter dans la section "Historique du projet" du prompt

---

## 💡 Astuces

### Extraction rapide (vue d'ensemble)

Si vous manquez de temps, extraire au minimum :
- ✅ Clé du ticket et titre
- ✅ Description de la User Story
- ✅ Critères d'acceptation
- ✅ Lien Jira

### Extraction complète (recommandé)

Pour une documentation complète :
- ✅ Toutes les sections ci-dessus
- ✅ Commentaires de l'équipe pertinents
- ✅ Tickets liés et dépendances
- ✅ Historique des tests précédents du projet

### Extraction enrichie (excellente qualité)

Pour une documentation de qualité maximale :
- ✅ Tous les éléments ci-dessus
- ✅ Confluence/Specifications techniques détaillées
- ✅ Designs Figma avec toutes les variantes
- ✅ Historique complet du projet avec patterns récurrents
- ✅ Retours utilisateurs si disponibles

---

## 📋 Checklist d'extraction

Avant d'utiliser le prompt, vérifier :

- [ ] Informations générales du ticket (clé, titre, sprint)
- [ ] Description complète de la User Story
- [ ] Tous les critères d'acceptation
- [ ] Informations techniques disponibles
- [ ] Liens vers les designs/maquettes
- [ ] Contraintes et dépendances
- [ ] Tickets liés et historique

---

## 🔗 Voir aussi

- `prompt-generation-qa.md` : Prompt complet pour génération
- `prompt-rapide.md` : Version simplifiée du prompt
- `../README.md` : Guide général de la documentation QA

