# [NOM_FEATURE] - Cas de Test

## 📋 Informations générales

- **Feature** : [Nom de la fonctionnalité]
- **User Story** : [US-XXX : Description]
- **Sprint/Version** : [ex: Sprint 24, v2.3.0]
- **Date de création** : [AAAA-MM-JJ]
- **Auteur** : [Nom du QA]
- **Statut** : [Draft / En révision / Validé]
- **Lien Jira/Ticket** : [URL du ticket]

---

## 🔗 Documents associés

- **Stratégie de test** : [Lien vers le document de stratégie]
- **Questions et Clarifications** : [Lien vers le document]

---

## 🧪 Scénarios de test

### 📌 CAS NOMINAUX

### Scénario 1 : [Nom du scénario - Cas nominal standard]

**Objectif** : Vérifier que [objectif du test]

**Étapes** :

1. Se connecter en tant que [utilisateur]
2. Naviguer vers [page/section]
3. Cliquer sur [élément]
4. Saisir [données] dans [champ]
5. Valider en cliquant sur [bouton]

**Données de test** :

```
Champ 1: "valeur1"
Champ 2: "valeur2"
Champ 3: 12345
```

**Résultat attendu** :

- ✅ [Comportement attendu 1]
- ✅ [Comportement attendu 2]
- ✅ Message affiché : "[Message exact]"

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 2 : [Nom du scénario - Cas nominal avec variante]

**Objectif** : Vérifier que [objectif du test avec données différentes]

**Étapes** :

1. [Étape 1]
2. [Étape 2]
3. [Étape 3]

**Données de test** :

```
Champ 1: "valeurAlternative"
Champ 2: "autreDonnee"
Champ 3: 99999
```

**Résultat attendu** :

- ✅ [Comportement attendu]
- ✅ [Comportement attendu 2]

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### 🔢 CAS LIMITES

### Scénario 3 : [Nom du scénario - Valeur minimale]

**Objectif** : Vérifier le comportement avec la valeur minimale autorisée

**Étapes** :

1. [Étape 1]
2. Saisir la valeur minimale dans [champ]
3. [Étape 3]

**Données de test** :

```
Champ numérique: [valeur minimale]
Champ texte: [longueur minimale]
```

**Résultat attendu** :

- ✅ La valeur minimale est acceptée
- ✅ [Comportement attendu]

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 4 : [Nom du scénario - Valeur maximale]

**Objectif** : Vérifier le comportement avec la valeur maximale autorisée

**Étapes** :

1. [Étape 1]
2. Saisir la valeur maximale dans [champ]
3. [Étape 3]

**Données de test** :

```
Champ numérique: [valeur maximale]
Champ texte: [longueur maximale - limite de caractères]
```

**Résultat attendu** :

- ✅ La valeur maximale est acceptée
- ✅ [Comportement attendu]

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 5 : [Nom du scénario - Champs vides/null]

**Objectif** : Vérifier le comportement avec des champs optionnels vides

**Étapes** :

1. [Étape 1]
2. Laisser [champ optionnel] vide
3. [Étape 3]

**Données de test** :

```
Champ obligatoire: "valeur"
Champ optionnel: [vide]
```

**Résultat attendu** :

- ✅ Les champs optionnels vides sont acceptés
- ✅ [Comportement attendu]

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 6 : [Nom du scénario - Caractères spéciaux]

**Objectif** : Vérifier le traitement des caractères spéciaux et accents

**Étapes** :

1. [Étape 1]
2. Saisir des caractères spéciaux dans [champ]
3. [Étape 3]

**Données de test** :

```
Champ texte: "àéèùç€@#$%^&*()[]{}|\\/<>?~`"
Champ texte: "émojis: 😀🎉🚀"
```

**Résultat attendu** :

- ✅ Les caractères spéciaux sont correctement encodés/affichés
- ✅ [Comportement attendu]

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### ❌ CAS D'ERREUR

### Scénario 7 : [Nom du scénario - Champs obligatoires manquants]

**Objectif** : Vérifier la gestion d'erreur lorsque des champs obligatoires sont vides

**Étapes** :

1. [Étape 1]
2. Laisser [champ obligatoire] vide
3. Tenter de valider

**Données de test** :

```
Champ obligatoire 1: [vide]
Champ obligatoire 2: [vide]
```

**Résultat attendu** :

- ✅ Message d'erreur : "[Message exact pour champ obligatoire]"
- ✅ Les champs manquants sont clairement identifiés
- ✅ Le formulaire n'est pas soumis

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 8 : [Nom du scénario - Format invalide]

**Objectif** : Vérifier la validation du format des données (email, téléphone, date, etc.)

**Étapes** :

1. [Étape 1]
2. Saisir un format invalide dans [champ avec format spécifique]
3. Tenter de valider

**Données de test** :

```
Email: "email-invalide"
Téléphone: "abc123"
Date: "32/13/2024"
```

**Résultat attendu** :

- ✅ Message d'erreur : "[Message exact pour format invalide]"
- ✅ [Comportement de gestion d'erreur]

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 9 : [Nom du scénario - Valeur dépassant la limite]

**Objectif** : Vérifier la gestion lorsque la valeur dépasse la limite maximale

**Étapes** :

1. [Étape 1]
2. Saisir une valeur supérieure à [limite maximale]
3. Tenter de valider

**Données de test** :

```
Champ numérique: [valeur maximale + 1]
Champ texte: [longueur maximale + 1 caractères]
```

**Résultat attendu** :

- ✅ Message d'erreur : "[Message exact]"
- ✅ Le champ est marqué comme invalide
- ✅ Le formulaire n'est pas soumis

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 10 : [Nom du scénario - Valeur négative non autorisée]

**Objectif** : Vérifier la gestion des valeurs négatives quand elles ne sont pas autorisées

**Étapes** :

1. [Étape 1]
2. Saisir une valeur négative dans [champ numérique]
3. Tenter de valider

**Données de test** :

```
Champ numérique: -100
Champ numérique: -1
```

**Résultat attendu** :

- ✅ Message d'erreur : "[Message exact]"
- ✅ [Comportement de gestion d'erreur]

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 11 : [Nom du scénario - Injection SQL/XSS]

**Objectif** : Vérifier la protection contre les injections malveillantes

**Étapes** :

1. [Étape 1]
2. Saisir du code malveillant dans [champ texte]
3. [Étape 3]

**Données de test** :

```
Champ texte: "<script>alert('XSS')</script>"
Champ texte: "'; DROP TABLE users; --"
Champ texte: "<img src=x onerror=alert(1)>"
```

**Résultat attendu** :

- ✅ Le code malveillant est échappé/sanitisé
- ✅ Aucune exécution de code
- ✅ Affichage sécurisé des données

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### 🔒 CAS DE SÉCURITÉ ET AUTORISATIONS

### Scénario 12 : [Nom du scénario - Accès non autorisé]

**Objectif** : Vérifier que les utilisateurs sans droits ne peuvent pas accéder à la fonctionnalité

**Étapes** :

1. Se connecter en tant que [utilisateur sans droits]
2. Tenter d'accéder à [fonctionnalité réservée]
3. [Étape 3]

**Données de test** :

```
Utilisateur: [utilisateur avec rôle limité]
URL: [URL de la fonctionnalité]
```

**Résultat attendu** :

- ✅ Accès refusé / Redirection vers page d'erreur
- ✅ Message : "[Message d'autorisation]"
- ✅ [Comportement attendu]

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 13 : [Nom du scénario - Session expirée]

**Objectif** : Vérifier le comportement lorsque la session est expirée

**Étapes** :

1. Se connecter
2. Attendre l'expiration de la session
3. Tenter d'utiliser la fonctionnalité

**Données de test** :

```
Durée de session: [X minutes]
Action après expiration: [action]
```

**Résultat attendu** :

- ✅ Redirection vers la page de connexion
- ✅ Message : "[Message de session expirée]"
- ✅ Les données non sauvegardées sont perdues ou récupérées

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### ⚡ CAS DE PERFORMANCE

### Scénario 14 : [Nom du scénario - Volume de données important]

**Objectif** : Vérifier les performances avec un grand volume de données

**Étapes** :

1. [Étape 1]
2. Charger [nombre] d'éléments
3. Mesurer le temps de réponse

**Données de test** :

```
Nombre d'éléments: [1000+ éléments]
Taille des données: [X Mo]
```

**Résultat attendu** :

- ✅ Temps de chargement < [X] secondes
- ✅ Pas de dégradation de performance
- ✅ [Comportement attendu]

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 15 : [Nom du scénario - Actions simultanées]

**Objectif** : Vérifier le comportement avec plusieurs actions simultanées

**Étapes** :

1. [Étape 1]
2. Effectuer plusieurs actions en parallèle
3. [Étape 3]

**Données de test** :

```
Nombre d'actions simultanées: [X]
Type d'actions: [détails]
```

**Résultat attendu** :

- ✅ Aucune perte de données
- ✅ Pas de conflits
- ✅ [Comportement attendu]

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### 🔄 CAS D'INTÉGRATION

### Scénario 16 : [Nom du scénario - Intégration avec service externe]

**Objectif** : Vérifier l'intégration avec [service/API externe]

**Étapes** :

1. [Étape 1]
2. Déclencher l'appel à [service externe]
3. Vérifier la réponse

**Données de test** :

```
Service: [nom du service]
Données envoyées: [détails]
```

**Résultat attendu** :

- ✅ Appel réussi au service
- ✅ Données correctement échangées
- ✅ Gestion d'erreur si service indisponible

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 17 : [Nom du scénario - Service externe indisponible]

**Objectif** : Vérifier la gestion d'erreur lorsque le service externe est indisponible

**Étapes** :

1. [Étape 1]
2. Simuler l'indisponibilité de [service externe]
3. Déclencher l'action

**Données de test** :

```
Service: [nom du service]
Statut: [indisponible/timeout]
```

**Résultat attendu** :

- ✅ Message d'erreur approprié : "[Message exact]"
- ✅ Fallback/retry si applicable
- ✅ [Comportement attendu]

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### 🌐 CAS DE COMPATIBILITÉ

### Scénario 18 : [Nom du scénario - Compatibilité navigateurs]

**Objectif** : Vérifier le fonctionnement sur différents navigateurs

**Étapes** :

1. Ouvrir [navigateur: Chrome/Firefox/Safari/Edge]
2. Accéder à [fonctionnalité]
3. Exécuter [scénario nominal]

**Données de test** :

```
Navigateur: [Chrome 120+ / Firefox 115+ / Safari 17+ / Edge]
Version: [version]
```

**Résultat attendu** :

- ✅ Fonctionnement identique sur tous les navigateurs
- ✅ Aucune régression visuelle
- ✅ [Comportement attendu]

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 19 : [Nom du scénario - Responsive design]

**Objectif** : Vérifier l'adaptation sur différentes tailles d'écran

**Étapes** :

1. Ouvrir [navigateur]
2. Redimensionner la fenêtre à [résolution]
3. Tester la fonctionnalité

**Données de test** :

```
Résolutions: 
- Desktop: 1920x1080
- Tablet: 768x1024
- Mobile: 375x667
```

**Résultat attendu** :

- ✅ Interface adaptée à chaque résolution
- ✅ Tous les éléments sont accessibles
- ✅ Aucune perte de fonctionnalité

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### ♿ CAS D'ACCESSIBILITÉ

### Scénario 20 : [Nom du scénario - Navigation au clavier]

**Objectif** : Vérifier la navigation complète au clavier (accessibilité)

**Étapes** :

1. Accéder à [fonctionnalité]
2. Naviguer uniquement avec Tab/Enter/Echap
3. Utiliser toutes les fonctionnalités

**Données de test** :

```
Touches: Tab, Enter, Echap, Flèches
Lecteur d'écran: [si applicable]
```

**Résultat attendu** :

- ✅ Tous les éléments sont accessibles au clavier
- ✅ Ordre de tabulation logique
- ✅ Focus visible sur tous les éléments interactifs

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 21 : [Nom du scénario - Annulation/Retour]

**Objectif** : Vérifier les actions d'annulation et de retour

**Étapes** :

1. [Étape 1]
2. Cliquer sur "Annuler" / Bouton retour
3. Vérifier l'état de l'application

**Données de test** :

```
Action: [détails de l'action]
Données saisies: [détails]
```

**Résultat attendu** :

- ✅ Retour à l'état précédent
- ✅ Aucune perte de données non sauvegardées (ou confirmation si perte)
- ✅ [Comportement attendu]

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

## 🐛 Bugs identifiés

### Bug #1

- **Ticket** : [Lien Jira]
- **Sévérité** : [Critique/Majeur/Mineur/Trivial]
- **Description** : [Description du bug]
- **Étapes de reproduction** : [Étapes]
- **Statut** : [Ouvert/En cours/Résolu]

---

## 📊 Résumé des tests

- **Total de scénarios** : 21
  - Cas nominaux : 2
  - Cas limites : 4
  - Cas d'erreur : 5
  - Cas de sécurité/autorisations : 2
  - Cas de performance : 2
  - Cas d'intégration : 2
  - Cas de compatibilité : 2
  - Cas d'accessibilité : 2
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
- **Date de test** : [AAAA-MM-JJ]
- **Validé par** : [Nom du responsable QA]
- **Date de validation** : [AAAA-MM-JJ]

