# [Compte Addons] Modale Download R&#233;ussi - Ajouter Block Review  - Cas de Test

## 📋 Informations générales

- **Feature** : [Compte Addons] Modale Download R&#233;ussi - Ajouter Block Review 
- **User Story** : MME-1385 : [Compte Addons] Modale Download R&#233;ussi - Ajouter Block Review 
- **Sprint/Version** : [ex: Sprint 24, v2.3.0]
- **Date de création** : 2025-11-18
- **Auteur** : [Nom du QA]
- **Statut** : Draft
- **Lien Jira/Ticket** : https://forge.prestashop.com/browse/MME-1385

---

## 🔗 Documents associés

- **Stratégie de test** : [02-strategie-test.md]
- **Questions et Clarifications** : [01-questions-clarifications.md]

---

## 🧪 Scénarios de test

### 📌 CAS NOMINAUX


### 🔄 CAS D'INTÉGRATION


### 🌐 CAS DE COMPATIBILITÉ


### Scénario 1 : Fonctionnement sur différents navigateurs

**Objectif** : Vérifier que Fonctionnement sur différents navigateurs

**Étapes** :

1. Ouvrir un navigateur (Chrome 120+, Firefox 115+, Safari 17+, Edge)
2. Accéder à la section 'Share your product documentation' et uploader un fichier PDF valide (readme_fr.pdf)

**Données de test** :

```
Navigateur: Chrome 120+ / Firefox 115+ / Safari 17+ / Edge
Fichier: readme_fr.pdf
Taille: 1MB
```

**Résultat attendu** :

- ✅ Le drag-and-drop fonctionne sur tous les navigateurs
- ✅ Le sélecteur de fichier fonctionne sur tous les navigateurs
- ✅ L'affichage du fichier uploadé est identique
- ✅ Aucune régression visuelle

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 2 : Adaptation sur différentes tailles d'écran

**Objectif** : Vérifier que Adaptation sur différentes tailles d'écran

**Étapes** :

1. Ouvrir le navigateur et redimensionner la fenêtre à différentes résolutions
2. Accéder à la section 'Share your product documentation' et tester l'upload d'un fichier

**Données de test** :

```
Résolutions:
- Desktop: 1920x1080
- Tablet: 768x1024
- Mobile: 375x667
Fichier: readme_fr.pdf
```

**Résultat attendu** :

- ✅ La zone d'upload est visible et fonctionnelle sur toutes les résolutions
- ✅ Le message informatif est lisible sur toutes les tailles d'écran
- ✅ L'icône de suppression est accessible et cliquable
- ✅ Aucune perte de fonctionnalité sur mobile/tablette

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### 🔒 CAS DE SÉCURITÉ


### Scénario 3 : Validation côté serveur des fichiers uploadés

**Objectif** : Vérifier que Validation côté serveur des fichiers uploadés

**Étapes** :

1. Se connecter en tant que vendeur et accéder à la section 'Share your product documentation'
2. Tenter d'uploader un fichier malveillant (ex: fichier .pdf renommé contenant du code exécutable) en contournant la validation côté client

**Données de test** :

```
Fichier: script.exe renommé en readme_fr.pdf
Méthode: Contournement validation client (modification manuelle des headers HTTP)
```

**Résultat attendu** :

- ✅ Le serveur valide le type MIME réel du fichier (pas seulement l'extension)
- ✅ Les fichiers malveillants sont rejetés même si l'extension est .pdf
- ✅ Un message d'erreur approprié est retourné
- ✅ Aucun fichier malveillant n'est stocké sur le serveur
- ✅ Les logs de sécurité enregistrent la tentative d'upload malveillant

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 4 : Protection CSRF sur le formulaire d'upload

**Objectif** : Vérifier que Protection CSRF sur le formulaire d'upload

**Étapes** :

1. Se connecter en tant que vendeur et obtenir un token CSRF valide
2. Tenter de soumettre un formulaire d'upload depuis un site externe (sans token CSRF valide)

**Données de test** :

```
Contexte: Site externe malveillant
Méthode: POST sans token CSRF valide
```

**Résultat attendu** :

- ✅ La requête est rejetée avec une erreur 403 Forbidden
- ✅ Aucun fichier n'est uploadé sur le serveur
- ✅ Le token CSRF est requis et validé côté serveur
- ✅ Les tentatives CSRF sont enregistrées dans les logs de sécurité

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 5 : Test d'autorisation - Accès aux fichiers d'autres vendeurs

**Objectif** : Vérifier que Test d'autorisation - Accès aux fichiers d'autres vendeurs

**Étapes** :

1. Se connecter en tant que vendeur A avec un fichier uploadé
2. Tenter d'accéder ou télécharger un fichier appartenant à un autre vendeur (vendeur B) via manipulation d'URL ou API

**Données de test** :

```
Vendeur A: Fichier readme_fr.pdf ID 123
Vendeur B: Fichier readme_fr.pdf ID 456
Action: Tentative d'accès non autorisé
```

**Résultat attendu** :

- ✅ L'accès au fichier d'un autre vendeur est refusé (403 Forbidden)
- ✅ Le fichier n'est pas téléchargeable même avec l'URL directe
- ✅ Les données retournées par l'API sont filtrées par propriétaire
- ✅ Les logs de sécurité enregistrent la tentative d'accès non autorisé

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### ♿ CAS D'ACCESSIBILITÉ


### Scénario 6 : Navigation complète au clavier

**Objectif** : Vérifier que Navigation complète au clavier

**Étapes** :

1. Accéder à la section 'Share your product documentation' sans utiliser la souris
2. Naviguer uniquement avec Tab/Enter/Echap pour accéder à la zone d'upload et utiliser toutes les fonctionnalités

**Données de test** :

```
Touches: Tab, Enter, Echap, Flèches
Lecteur d'écran: [si applicable]
```

**Résultat attendu** :

- ✅ La zone d'upload est accessible via Tab
- ✅ Le sélecteur de fichier peut être déclenché avec Enter
- ✅ L'icône de suppression est accessible au clavier
- ✅ L'ordre de tabulation est logique
- ✅ Le focus est visible sur tous les éléments interactifs

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

## 🐛 Bugs identifiés

### Bug #1

- **Ticket** : https://forge.prestashop.com/browse/MME-1385
- **Sévérité** : [Critique/Majeur/Mineur/Trivial]
- **Description** : [Description du bug]
- **Étapes de reproduction** : [Étapes]
- **Statut** : [Ouvert/En cours/Résolu]

---

## 📊 Résumé des tests

- **Total de scénarios** : 6
  - Cas nominaux : Variable (selon scénarios XML)
  - Cas limites : Variable (selon scénarios XML)
  - Cas d'erreur : Variable (selon scénarios XML)
  - Cas de performance : Variable (selon scénarios XML)
  - Cas d'intégration : 1
  - Cas de sécurité : 3
  - Cas de compatibilité : 2
  - Cas d'accessibilité : 1
- **Passés** : X (XX%)
- **Échoués** : X (XX%)
- **Bloqués** : X (XX%)
- **Couverture estimée** : XX%

---

## 📝 Notes & Observations

- [Note 1]
- [Note 2]
- [Recommandations]

---

## ✍️ Validation

- **Testé par** : [Nom]
- **Date de test** : 2025-11-18
- **Validé par** : [Nom du responsable QA]
- **Date de validation** : [AAAA-MM-JJ]
