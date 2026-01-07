# [Products] - Document upload CTA - Cas de Test

## 📋 Informations générales

- **Feature** : [Products] - Document upload CTA
- **User Story** : SPEX-2990 : [Products] - Document upload CTA
- **Sprint/Version** : [ex: Sprint 24, v2.3.0]
- **Date de création** : 2025-11-18
- **Auteur** : [Nom du QA]
- **Statut** : Draft
- **Lien Jira/Ticket** : https://forge.prestashop.com/browse/SPEX-2990

---

## 🔗 Documents associés

- **Stratégie de test** : [02-strategie-test.md]
- **Questions et Clarifications** : [01-questions-clarifications.md]

---

## 🧪 Scénarios de test

### 📌 CAS NOMINAUX


### Scénario 1 : Affichage de l'interface d'upload

**Objectif** : Vérifier que Affichage de l'interface d'upload

**Étapes** :

1. Se connecter en tant que vendeur avec un produit de type Module ou Theme
2. Naviguer vers la page marketing sheet, accéder à la section 'How to install your product?' puis scroller jusqu'à la section 'Share your product documentation'

**Données de test** :

```
Type de produit: Module ou Theme
Section: 'Share your product documentation'
Résolution: 1920x1080
```

**Résultat attendu** :

- ✅ La zone de drag-and-drop est visible et fonctionnelle
- ✅ Le message informatif sur la convention de nommage readme_iso.pdf est affiché correctement
- ✅ L'interface est responsive et s'adapte à différentes tailles d'écran

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 2 : Upload d'un fichier PDF valide via drag-and-drop

**Objectif** : Vérifier que Upload d'un fichier PDF valide via drag-and-drop

**Étapes** :

1. Se connecter en tant que vendeur et accéder à la section 'Share your product documentation'
2. Glisser-déposer un fichier PDF valide dans la zone d'upload OU cliquer sur la zone pour sélectionner le fichier

**Données de test** :

```
Fichier: readme_fr.pdf
Taille: 1.5MB
Format: PDF
Nommage: readme_fr.pdf conforme
```

**Résultat attendu** :

- ✅ Le fichier apparaît immédiatement dans la zone d'upload après le drag-and-drop
- ✅ Le nom du fichier readme_fr.pdf est affiché correctement
- ✅ L'icône de suppression X est visible à côté du nom du fichier
- ✅ Il n'est pas possible d'uploader un deuxième fichier pour la langue fr
- ✅ Le fichier est correctement uploadé et sauvegardé

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 3 : Upload d'un fichier PDF valide via clic

**Objectif** : Vérifier que Upload d'un fichier PDF valide via clic

**Étapes** :

1. Se connecter en tant que vendeur et accéder à la section 'Share your product documentation'
2. Cliquer sur la zone d'upload et sélectionner un fichier PDF valide depuis l'explorateur de fichiers

**Données de test** :

```
Fichier: readme_en.pdf
Taille: 2MB
Format: PDF
Nommage: readme_en.pdf conforme
```

**Résultat attendu** :

- ✅ Le sélecteur de fichier s'ouvre correctement au clic
- ✅ Le fichier sélectionné apparaît dans la zone d'upload
- ✅ Le nom du fichier readme_*.pdf est affiché correctement
- ✅ L'icône de suppression X est visible

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 4 : Suppression d'un fichier uploadé

**Objectif** : Vérifier que Suppression d'un fichier uploadé

**Étapes** :

1. Avoir uploadé avec succès un fichier de documentation readme_*.pdf
2. Cliquer sur l'icône 'X' à côté du nom du fichier

**Données de test** :

```
Fichier uploadé: readme_fr.pdf
Action: Clic sur l'icône 'X'
```

**Résultat attendu** :

- ✅ Le fichier est immédiatement retiré de l'interface
- ✅ La zone d'upload redevient vide et disponible pour un nouvel upload
- ✅ Aucune trace du fichier ne reste dans l'interface
- ✅ Le fichier est supprimé du serveur (vérification backend)

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### 🔢 CAS LIMITES


### Scénario 5 : Upload d'un fichier à la limite de taille maximale

**Objectif** : Vérifier que Upload d'un fichier à la limite de taille maximale

**Étapes** :

1. Se connecter en tant que vendeur et accéder à la section 'Share your product documentation'
2. Uploader un fichier PDF valide readme_*.pdf d'exactement 2MB

**Données de test** :

```
Fichier: readme_fr.pdf
Taille: 2MB limite exacte
Format: PDF
Nommage: readme_fr.pdf conforme
```

**Résultat attendu** :

- ✅ Le fichier de 2MB est accepté
- ✅ L'upload se termine avec succès
- ✅ Le fichier apparaît dans la zone d'upload avec son nom et l'icône 'X'

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 6 : Upload d'un fichier très petit

**Objectif** : Vérifier que Upload d'un fichier très petit

**Étapes** :

1. Se connecter en tant que vendeur et accéder à la section 'Share your product documentation'
2. Uploader un fichier PDF valide (readme_fr.pdf) de très petite taille (< 1KB)

**Données de test** :

```
Fichier: readme_fr.pdf
Taille: 0.5KB
Format: PDF
Nommage: readme_fr.pdf (conforme)
```

**Résultat attendu** :

- ✅ Le fichier très petit est accepté
- ✅ L'upload se termine avec succès
- ✅ Le fichier apparaît dans la zone d'upload

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 7 : Upload de fichiers pour différentes langues

**Objectif** : Vérifier que Upload de fichiers pour différentes langues

**Étapes** :

1. Se connecter en tant que vendeur et accéder à la section 'Share your product documentation'
2. Uploader successivement readme_fr.pdf, puis readme_en.pdf, puis readme_es.pdf

**Données de test** :

```
Fichier 1: readme_fr.pdf (français)
Fichier 2: readme_en.pdf (anglais)
Fichier 3: readme_es.pdf (espagnol)
Taille: 1MB chacun
Format: PDF
```

**Résultat attendu** :

- ✅ Chaque fichier est accepté pour sa langue respective
- ✅ Tous les fichiers sont affichés dans l'interface
- ✅ Chaque fichier peut être supprimé indépendamment
- ✅ La convention de nommage readme_iso.pdf est respectée pour chaque langue

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### ❌ CAS D'ERREUR


### Scénario 8 : Tentative d'upload d'un fichier non-PDF

**Objectif** : Vérifier que Tentative d'upload d'un fichier non-PDF

**Étapes** :

1. Se connecter en tant que vendeur et accéder à la section 'Share your product documentation'
2. Sélectionner ou glisser-déposer un fichier non-PDF (ex: .docx, .txt, .jpg)

**Données de test** :

```
Fichier: document.docx
Format: DOCX (non-PDF)
Taille: 1MB
```

**Résultat attendu** :

- ✅ Le message d'erreur banner apparaît immédiatement sans attendre la fin de l'upload
- ✅ Le message d'erreur exact est: 'The file could not be uploaded. Only files with the following extensions are allowed: pdf.'
- ✅ L'upload est rejeté et le fichier n'apparaît pas dans la zone
- ✅ La zone d'upload reste disponible pour un nouvel essai

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 9 : Tentative d'upload d'un fichier dépassant la limite de taille

**Objectif** : Vérifier que Tentative d'upload d'un fichier dépassant la limite de taille

**Étapes** :

1. Se connecter en tant que vendeur et accéder à la section 'Share your product documentation'
2. Sélectionner ou glisser-déposer un fichier PDF de taille supérieure à 2MB

**Données de test** :

```
Fichier: readme_fr.pdf
Format: PDF
Taille: 3MB
```

**Résultat attendu** :

- ✅ Le message d'erreur banner apparaît immédiatement sans attendre la fin de l'upload
- ✅ Le message d'erreur exact est: 'The file could not be uploaded. File size must not exceed 2MB'
- ✅ L'upload est rejeté et le fichier n'apparaît pas dans la zone
- ✅ La zone d'upload reste disponible

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 10 : Tentative d'upload d'un fichier avec un nom incorrect

**Objectif** : Vérifier que Tentative d'upload d'un fichier avec un nom incorrect

**Étapes** :

1. Se connecter en tant que vendeur et accéder à la section 'Share your product documentation'
2. Sélectionner ou glisser-déposer un fichier PDF nommé mydocument.pdf (au lieu de readme_*.pdf)

**Données de test** :

```
Fichier: mydocument.pdf
Format: PDF
Taille: 1MB
Nommage: incorrect (ne respecte pas readme_iso.pdf)
```

**Résultat attendu** :

- ✅ Le message d'erreur banner apparaît immédiatement
- ✅ Le message d'erreur exact est: 'The file could not be uploaded. File must be titled readme_iso.pdf'
- ✅ L'upload est rejeté et le fichier n'apparaît pas dans la zone
- ✅ La zone d'upload reste disponible

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### ⚡ CAS DE PERFORMANCE


### Scénario 11 : Performance lors de l'upload d'un fichier à la limite de taille

**Objectif** : Vérifier que Performance lors de l'upload d'un fichier à la limite de taille

**Étapes** :

1. Se connecter en tant que vendeur et accéder à la section 'Share your product documentation'
2. Uploader un fichier PDF de 2MB (readme_fr.pdf)

**Données de test** :

```
Fichier: readme_fr.pdf
Taille: 2MB (limite)
Format: PDF
```

**Résultat attendu** :

- ✅ Le temps d'upload est acceptable (< 30 secondes pour 2MB)
- ✅ Un indicateur de progression est visible pendant l'upload
- ✅ Le fichier apparaît correctement après l'upload
- ✅ Aucun timeout ou erreur de performance

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### 🔄 CAS D'INTÉGRATION


### Scénario 12 : Persistance de la documentation après soumission de la marketing sheet

**Objectif** : Vérifier que Persistance de la documentation après soumission de la marketing sheet

**Étapes** :

1. Avoir uploadé un fichier de documentation (readme_fr.pdf) et soumis la marketing sheet avec succès
2. Recharger la page de la marketing sheet ou y revenir ultérieurement

**Données de test** :

```
Fichier uploadé: readme_fr.pdf
Action: Soumission puis rechargement de la page
```

**Résultat attendu** :

- ✅ Le fichier de documentation est toujours présent après rechargement
- ✅ Le nom du fichier (readme_fr.pdf) est correctement affiché
- ✅ L'icône de suppression ('X') est toujours visible
- ✅ Les données sont correctement persistées en base de données

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### 🌐 CAS DE COMPATIBILITÉ


### Scénario 13 : Fonctionnement sur différents navigateurs

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

### Scénario 14 : Adaptation sur différentes tailles d'écran

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


### Scénario 15 : Validation côté serveur des fichiers uploadés

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

### Scénario 16 : Protection CSRF sur le formulaire d'upload

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

### Scénario 17 : Test d'autorisation - Accès aux fichiers d'autres vendeurs

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


### Scénario 18 : Navigation complète au clavier

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

- **Ticket** : https://forge.prestashop.com/browse/SPEX-2990
- **Sévérité** : [Critique/Majeur/Mineur/Trivial]
- **Description** : [Description du bug]
- **Étapes de reproduction** : [Étapes]
- **Statut** : [Ouvert/En cours/Résolu]

---

## 📊 Résumé des tests

- **Total de scénarios** : 18
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
