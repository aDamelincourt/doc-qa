# [Products] - I want to provide Module Benefits - Cas de Test

## 📋 Informations générales

- **Feature** : [Products] - I want to provide Module Benefits
- **User Story** : SPEX-3143 : [Products] - I want to provide Module Benefits
- **Sprint/Version** : [ex: Sprint 24, v2.3.0]
- **Date de création** : 2025-11-18
- **Auteur** : [Nom du QA]
- **Statut** : Draft
- **Lien Jira/Ticket** : https://forge.prestashop.com/browse/SPEX-3143

---

## 🔗 Documents associés

- **Stratégie de test** : [02-strategie-test.md]
- **Questions et Clarifications** : [01-questions-clarifications.md]

---

## 🧪 Scénarios de test

### 📌 CAS NOMINAUX


### Scénario 1 : Affichage de la section bénéfices selon le type de produit

**Objectif** : Vérifier que Affichage de la section bénéfices selon le type de produit

**Étapes** :

1. Se connecter en tant que vendeur
2. Naviguer vers la page marketing sheet et accéder à la catégorie 'What will users do with your product?'

**Données de test** :

```
Type de produit: Module / Pack / Theme / Email
Section: 'What will users do with your product?'
```

**Résultat attendu** :

- ✅ Pour un produit Module : La section bénéfices est visible avec le titre 'What benefits can your clients gain from your module?'
- ✅ Pour un produit Pack : La section bénéfices est visible avec le titre 'What benefits can your clients gain from your pack?'
- ✅ Pour un produit Theme : La section bénéfices n'est PAS visible
- ✅ Pour un produit Email : La section bénéfices n'est PAS visible

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 2 : Sélection d'un bénéfice quand la limite est 1

**Objectif** : Vérifier que Sélection d'un bénéfice quand la limite est 1

**Étapes** :

1. Créer un nouveau produit avec une limite de bénéfices de 1
2. Cliquer sur une checkbox sous 'Would you mention some benefits for customers?' (par exemple 'Conversion rate')

**Données de test** :

```
Produit: Nouveau produit
Limite de bénéfices: 1
Bénéfice sélectionné: Conversion rate
```

**Résultat attendu** :

- ✅ La checkbox 'Conversion rate' est cochée
- ✅ Toutes les autres checkboxes de bénéfices sont désactivées (grisées, non cliquables)
- ✅ Le message informatif sur la limite est affiché correctement

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 3 : Désélection d'un bénéfice quand la limite est 1

**Objectif** : Vérifier que Désélection d'un bénéfice quand la limite est 1

**Étapes** :

1. Avoir un produit avec 'Conversion rate' actuellement sélectionné (limite de 1)
2. Cliquer à nouveau sur la checkbox 'Conversion rate'

**Données de test** :

```
Produit: Produit existant
Limite de bénéfices: 1
Bénéfice actuellement sélectionné: Conversion rate
Action: Désélection de 'Conversion rate'
```

**Résultat attendu** :

- ✅ La checkbox 'Conversion rate' est décochée
- ✅ Toutes les autres checkboxes de bénéfices redeviennent actives (cliquables)
- ✅ L'utilisateur peut maintenant sélectionner un autre bénéfice

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 4 : Gestion des bénéfices après augmentation permanente de la limite par un admin

**Objectif** : Vérifier que Gestion des bénéfices après augmentation permanente de la limite par un admin

**Étapes** :

1. Avoir un produit existant avec 1 bénéfice sélectionné ('Conversion rate'), puis un admin PrestaShop augmente la limite à 3 bénéfices depuis le back-office
2. Retourner sur la page d'édition du produit et vérifier l'affichage, puis sélectionner un 4ème bénéfice

**Données de test** :

```
Produit: Produit existant
Bénéfices initiaux: Conversion rate (1)
Action admin: Ajout de 2 bénéfices (SEO optimized, Customer loyalty)
Nouvelle limite: 3 bénéfices
```

**Résultat attendu** :

- ✅ Les 3 bénéfices ('Conversion rate', 'SEO optimized', 'Customer loyalty') sont tous sélectionnés
- ✅ La règle de sélection est mise à jour pour permettre un maximum de 3 sélections
- ✅ L'utilisateur peut désélectionner n'importe quel bénéfice et en sélectionner d'autres, tant que le total ne dépasse pas 3
- ✅ Si on tente de sélectionner un 4ème bénéfice, les autres checkboxes non sélectionnées se désactivent

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### ❌ CAS D'ERREUR


### Scénario 5 : Tentative de soumission sans sélectionner de bénéfice

**Objectif** : Vérifier que Tentative de soumission sans sélectionner de bénéfice

**Étapes** :

1. Se connecter en tant que vendeur et accéder à la page marketing sheet
2. Ne pas choisir de bénéfice et cliquer sur 'submit'

**Données de test** :

```
Produit: Module ou Pack
Action: Soumission sans sélectionner de bénéfice
```

**Résultat attendu** :

- ✅ L'utilisateur est redirigé vers le haut de la page
- ✅ Un banner d'erreur apparaît avec le texte 'Oops, it seems there is a mistake! Please correct the error highlighted below to submit your product sheet.'
- ✅ Un banner apparaît au-dessus du champ bénéfices avec le message exact: 'You must select at least one benefit to sell your product on the marketplace.'
- ✅ Le formulaire n'est pas soumis

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### ⚡ CAS DE PERFORMANCE


### Scénario 6 : Performance avec un grand nombre de bénéfices disponibles

**Objectif** : Vérifier que Performance avec un grand nombre de bénéfices disponibles

**Étapes** :

1. Se connecter en tant que vendeur et accéder à la section 'What benefits can your clients gain from your module/pack?'
2. Vérifier le temps de chargement et la réactivité de l'interface lorsque la liste contient 50+ bénéfices disponibles

**Données de test** :

```
Nombre de bénéfices: 50+
Type de produit: Module ou Pack
Résolution: 1920x1080
```

**Résultat attendu** :

- ✅ Le temps de chargement de la liste des bénéfices est acceptable (< 2 secondes)
- ✅ L'interface reste réactive lors du scroll dans la liste
- ✅ La sélection/désélection de bénéfices est instantanée
- ✅ Aucun freeze ou lag perceptible
- ✅ La désactivation automatique des autres checkboxes fonctionne rapidement même avec 50+ bénéfices

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 7 : Réactivité lors de sélection/désélection rapide de bénéfices

**Objectif** : Vérifier que Réactivité lors de sélection/désélection rapide de bénéfices

**Étapes** :

1. Avoir accès à la section bénéfices avec plusieurs bénéfices disponibles
2. Sélectionner et désélectionner rapidement plusieurs bénéfices (5-10 clics en moins de 2 secondes)

**Données de test** :

```
Action: Sélection/désélection rapide de 5-10 bénéfices
Temps: < 2 secondes
```

**Résultat attendu** :

- ✅ Aucun lag ou freeze lors des clics rapides
- ✅ Toutes les sélections/désélections sont correctement enregistrées
- ✅ L'état des checkboxes est cohérent avec les actions effectuées
- ✅ La limite de bénéfices est correctement appliquée même lors d'actions rapides

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### 🔄 CAS D'INTÉGRATION


### Scénario 8 : Persistance des bénéfices sélectionnés après soumission

**Objectif** : Vérifier que Persistance des bénéfices sélectionnés après soumission

**Étapes** :

1. Avoir sélectionné des bénéfices (ex: 'Conversion rate', 'SEO optimized') et soumis la marketing sheet avec succès
2. Recharger la page de la marketing sheet ou y revenir ultérieurement

**Données de test** :

```
Bénéfices sélectionnés: Conversion rate, SEO optimized
Action: Soumission puis rechargement de la page
```

**Résultat attendu** :

- ✅ Les bénéfices sélectionnés sont toujours présents après rechargement
- ✅ Les checkboxes correspondantes sont cochées
- ✅ La limite de bénéfices est correctement appliquée
- ✅ Les données sont correctement persistées en base de données

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### 🌐 CAS DE COMPATIBILITÉ


### Scénario 9 : Fonctionnement sur différents navigateurs

**Objectif** : Vérifier que Fonctionnement sur différents navigateurs

**Étapes** :

1. Ouvrir un navigateur (Chrome 120+, Firefox 115+, Safari 17+, Edge)
2. Accéder à la section 'What benefits can your clients gain from your module/pack?' et tester la sélection de bénéfices

**Données de test** :

```
Navigateur: Chrome 120+ / Firefox 115+ / Safari 17+ / Edge
Type de produit: Module ou Pack
```

**Résultat attendu** :

- ✅ Les checkboxes de bénéfices fonctionnent sur tous les navigateurs
- ✅ La désactivation automatique des autres checkboxes fonctionne correctement
- ✅ L'affichage des bénéfices est identique
- ✅ Aucune régression visuelle

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 10 : Adaptation sur différentes tailles d'écran

**Objectif** : Vérifier que Adaptation sur différentes tailles d'écran

**Étapes** :

1. Ouvrir le navigateur et redimensionner la fenêtre à différentes résolutions
2. Accéder à la section 'What benefits can your clients gain from your module/pack?' et tester la sélection de bénéfices

**Données de test** :

```
Résolutions:
- Desktop: 1920x1080
- Tablet: 768x1024
- Mobile: 375x667
Type de produit: Module ou Pack
```

**Résultat attendu** :

- ✅ La section bénéfices est visible et fonctionnelle sur toutes les résolutions
- ✅ Les checkboxes sont accessibles et cliquables sur toutes les tailles d'écran
- ✅ Le texte et les labels sont lisibles
- ✅ Aucune perte de fonctionnalité sur mobile/tablette

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### 🔒 CAS DE SÉCURITÉ


### Scénario 11 : Protection contre l'injection XSS dans les labels de bénéfices

**Objectif** : Vérifier que Protection contre l'injection XSS dans les labels de bénéfices

**Étapes** :

1. Se connecter en tant qu'administrateur avec accès au back-office
2. Tenter d'injecter du code JavaScript dans un label de bénéfice (ex: '<script>alert("XSS")</script>') et vérifier l'affichage côté vendeur

**Données de test** :

```
Label de test: <script>alert('XSS')</script>
Contexte: Back-office admin → Interface vendeur
```

**Résultat attendu** :

- ✅ Le code JavaScript n'est pas exécuté dans le navigateur
- ✅ Les caractères spéciaux sont correctement échappés/encodés
- ✅ Le label s'affiche comme texte brut sans exécution de code
- ✅ Aucune alerte JavaScript n'apparaît
- ✅ La validation côté serveur rejette les entrées malveillantes

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 12 : Test d'autorisation - Accès aux bénéfices d'autres produits

**Objectif** : Vérifier que Test d'autorisation - Accès aux bénéfices d'autres produits

**Étapes** :

1. Se connecter en tant que vendeur A avec un produit Module
2. Tenter d'accéder ou modifier les bénéfices d'un produit appartenant à un autre vendeur (vendeur B) via manipulation d'URL ou API

**Données de test** :

```
Vendeur A: Produit Module ID 123
Vendeur B: Produit Module ID 456
Action: Tentative d'accès non autorisé
```

**Résultat attendu** :

- ✅ L'accès aux données d'un autre vendeur est refusé (403 Forbidden)
- ✅ Aucune modification n'est possible sur les bénéfices d'un autre produit
- ✅ Les données retournées par l'API sont filtrées par propriétaire
- ✅ Les logs de sécurité enregistrent la tentative d'accès non autorisé

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### ♿ CAS D'ACCESSIBILITÉ


### Scénario 13 : Navigation complète au clavier

**Objectif** : Vérifier que Navigation complète au clavier

**Étapes** :

1. Accéder à la section 'What benefits can your clients gain from your module/pack?' sans utiliser la souris
2. Naviguer uniquement avec Tab/Enter/Espace pour accéder aux checkboxes de bénéfices et les sélectionner

**Données de test** :

```
Touches: Tab, Enter, Espace, Flèches
Lecteur d'écran: [si applicable]
```

**Résultat attendu** :

- ✅ Les checkboxes de bénéfices sont accessibles via Tab
- ✅ Les checkboxes peuvent être cochées/décochées avec Espace
- ✅ L'ordre de tabulation est logique
- ✅ Le focus est visible sur tous les éléments interactifs
- ✅ Les labels sont correctement associés aux checkboxes

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

## 🐛 Bugs identifiés

### Bug #1

- **Ticket** : https://forge.prestashop.com/browse/SPEX-3143
- **Sévérité** : [Critique/Majeur/Mineur/Trivial]
- **Description** : [Description du bug]
- **Étapes de reproduction** : [Étapes]
- **Statut** : [Ouvert/En cours/Résolu]

---

## 📊 Résumé des tests

- **Total de scénarios** : 13
  - Cas nominaux : Variable (selon scénarios XML)
  - Cas d'erreur : Variable (selon scénarios XML)
  - Cas de performance : 2
  - Cas d'intégration : 1
  - Cas de sécurité : 2
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
