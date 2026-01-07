# [Compte Addons] Ajouter bouton "leave a review" - Order Detail Page - Cas de Test

## 📋 Informations générales

- **Feature** : Bouton "leave a review" sur la page de détail de commande
- **User Story** : MME-1384 : [Compte Addons] Ajouter bouton "leave a review" - Order Detail Page
- **Sprint/Version** : [À compléter]
- **Date de création** : 2025-11-18
- **Auteur** : [Nom du QA]
- **Statut** : Draft
- **Lien Jira/Ticket** : https://forge.prestashop.com/browse/MME-1384

---

## 🔗 Documents associés

- **Stratégie de test** : [02-strategie-test.md]
- **Questions et Clarifications** : [01-questions-clarifications.md]

---

## 🧪 Scénarios de test

### 📌 CAS NOMINAUX

### Scénario 1 : Affichage du bouton "leave a review" - CA1

**Objectif** : Vérifier que le bouton "leave a review" s'affiche dans la modale de commande lorsque le lien avis vérifié est généré et que l'avis n'est pas encore déposé.

**Étapes** :

1. Se connecter avec un compte utilisateur ayant passé une commande
2. Accéder à la page de détail de la commande
3. Ouvrir la modale de commande
4. Vérifier l'affichage du bouton "leave a review"

**Données de test** :

```
Commande avec :
- Lien avis vérifié généré : Oui (présent dans ps_avis_verifie_order_url)
- Avis déposé : Non (absent de ps_avis_verifie_product_review)
- ID commande : [id_order de test]
```

**Résultat attendu** :

- ✅ Le bouton "leave a review" est visible dans la modale de commande
- ✅ Le bouton est cliquable
- ✅ Le bouton est correctement positionné selon la maquette Figma
- ✅ Le texte du bouton est correct ("leave a review" ou "Laisser un avis")

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 2 : Redirection vers la page review

**Objectif** : Vérifier que le clic sur le bouton redirige correctement vers la page review filtrée sur la bonne commande.

**Étapes** :

1. Se connecter avec un compte utilisateur ayant passé une commande
2. Accéder à la page de détail de la commande
3. Ouvrir la modale de commande
4. Cliquer sur le bouton "leave a review"
5. Vérifier la redirection

**Données de test** :

```
Commande avec :
- ID commande : [id_order de test]
- Lien review : [review_link de l'API]
- URL attendue : [URL de la page review avec filtre sur id_order]
```

**Résultat attendu** :

- ✅ La redirection fonctionne correctement
- ✅ L'URL contient les bons paramètres pour filtrer sur la commande
- ✅ La page review s'affiche avec le bon filtre appliqué
- ✅ Le formulaire d'avis est pré-rempli avec les informations de la commande (si applicable)

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 3 : Disparition du bouton après dépôt d'avis - CA2

**Objectif** : Vérifier que le bouton "leave a review" disparaît de la modale après qu'un avis ait été déposé.

**Étapes** :

1. Se connecter avec un compte utilisateur ayant passé une commande
2. Accéder à la page de détail de la commande
3. Ouvrir la modale de commande
4. Vérifier que le bouton "leave a review" est visible
5. Cliquer sur le bouton et laisser un avis via le formulaire
6. Retourner à la page de détail de la commande
7. Ouvrir à nouveau la modale de commande
8. Vérifier que le bouton n'est plus visible

**Données de test** :

```
Commande avec :
- ID commande : [id_order de test]
- Avis déposé : Oui (présent dans ps_avis_verifie_product_review après étape 5)
```

**Résultat attendu** :

- ✅ Le bouton "leave a review" n'est plus visible dans la modale
- ✅ La modale s'affiche normalement sans le bouton
- ✅ Aucune erreur n'est affichée
- ✅ Le comportement est cohérent après rafraîchissement de la page

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 4 : Vérification de l'API - Champ review_link présent

**Objectif** : Vérifier que l'API GET /request3/clientaccount/orders/{id_order} retourne correctement le champ review_link.

**Étapes** :

1. Préparer une commande avec un lien avis vérifié généré
2. Appeler l'API GET /request3/clientaccount/orders/{id_order}
3. Vérifier la réponse JSON
4. Vérifier la présence et le format du champ review_link

**Données de test** :

```
API Call :
- Endpoint: GET /request3/clientaccount/orders/{id_order}
- Headers: [headers d'authentification]
- id_order: [id_order de test avec lien généré]

Réponse attendue :
{
  "id_order": "...",
  "review_link": "https://...",
  ...
}
```

**Résultat attendu** :

- ✅ L'API retourne une réponse 200 OK
- ✅ Le champ review_link est présent dans la réponse
- ✅ Le champ review_link contient une URL valide
- ✅ L'URL correspond au lien stocké dans ps_avis_verifie_order_url

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 5 : Vérification de l'API - Champ review_link absent

**Objectif** : Vérifier que l'API retourne un champ review_link vide ou absent lorsque le lien n'est pas généré.

**Étapes** :

1. Préparer une commande sans lien avis vérifié généré
2. Appeler l'API GET /request3/clientaccount/orders/{id_order}
3. Vérifier la réponse JSON
4. Vérifier l'absence ou la valeur vide du champ review_link

**Données de test** :

```
API Call :
- Endpoint: GET /request3/clientaccount/orders/{id_order}
- id_order: [id_order de test sans lien généré]

Réponse attendue :
{
  "id_order": "...",
  "review_link": null ou "",
  ...
}
```

**Résultat attendu** :

- ✅ L'API retourne une réponse 200 OK
- ✅ Le champ review_link est absent ou vide (null, "", ou absent)
- ✅ Le bouton ne s'affiche pas dans la modale (testé séparément)

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### 🔢 CAS LIMITES

### Scénario 6 : Commande avec plusieurs produits

**Objectif** : Vérifier le comportement du bouton pour une commande contenant plusieurs produits.

**Étapes** :

1. Se connecter avec un compte utilisateur
2. Passer une commande contenant plusieurs produits
3. Vérifier que le lien avis vérifié est généré pour la commande
4. Accéder à la page de détail de la commande
5. Ouvrir la modale de commande
6. Vérifier l'affichage du bouton "leave a review"
7. Cliquer sur le bouton et vérifier la redirection

**Données de test** :

```
Commande avec :
- Nombre de produits : 3+
- Lien avis vérifié : Généré pour la commande
- Avis déposé : Non
```

**Résultat attendu** :

- ✅ Le bouton s'affiche correctement
- ✅ La redirection fonctionne
- ✅ La page review permet de laisser un avis pour tous les produits ou pour un produit spécifique (selon la logique métier)

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 7 : Commande annulée ou remboursée

**Objectif** : Vérifier le comportement du bouton pour une commande annulée ou remboursée.

**Étapes** :

1. Se connecter avec un compte utilisateur
2. Accéder à la page de détail d'une commande annulée/remboursée
3. Vérifier si le lien avis vérifié est généré
4. Ouvrir la modale de commande
5. Vérifier l'affichage ou l'absence du bouton "leave a review"

**Données de test** :

```
Commande avec :
- Statut : Annulée ou Remboursée
- Lien avis vérifié : [selon la logique métier]
```

**Résultat attendu** :

- ✅ Le comportement est cohérent avec les règles métier définies
- ✅ Si le bouton s'affiche, il fonctionne correctement
- ✅ Si le bouton ne s'affiche pas, c'est intentionnel et documenté

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 8 : Lien avis vérifié expiré

**Objectif** : Vérifier le comportement lorsque le lien avis vérifié a expiré.

**Étapes** :

1. Se connecter avec un compte utilisateur
2. Accéder à la page de détail d'une commande avec un lien expiré
3. Ouvrir la modale de commande
4. Vérifier l'affichage du bouton
5. Si le bouton s'affiche, cliquer et vérifier le comportement

**Données de test** :

```
Commande avec :
- Lien avis vérifié : Généré mais expiré
- Date d'expiration : [date passée]
```

**Résultat attendu** :

- ✅ Le comportement est cohérent (bouton affiché ou non selon les règles)
- ✅ Si le bouton s'affiche et est cliqué, un message d'erreur approprié est affiché
- ✅ L'utilisateur est informé de l'expiration du lien

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### ❌ CAS D'ERREUR

### Scénario 9 : Erreur API - Service indisponible

**Objectif** : Vérifier le comportement lorsque l'API est indisponible.

**Étapes** :

1. Simuler l'indisponibilité de l'API GET /request3/clientaccount/orders/{id_order}
2. Se connecter avec un compte utilisateur
3. Accéder à la page de détail de la commande
4. Ouvrir la modale de commande
5. Vérifier le comportement de l'interface

**Données de test** :

```
API Status :
- Service : Indisponible (timeout ou erreur 500)
- Commande : [id_order de test]
```

**Résultat attendu** :

- ✅ L'interface reste stable (pas de crash)
- ✅ Le bouton ne s'affiche pas ou un message d'erreur approprié est affiché
- ✅ L'utilisateur peut toujours utiliser les autres fonctionnalités de la modale
- ✅ Un message d'erreur clair est affiché si nécessaire

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 10 : Erreur base de données - Tables inaccessibles

**Objectif** : Vérifier le comportement lorsque les tables de base de données sont inaccessibles.

**Étapes** :

1. Simuler l'indisponibilité des tables `ps_avis_verifie_product_review` et `ps_avis_verifie_order_url`
2. Se connecter avec un compte utilisateur
3. Accéder à la page de détail de la commande
4. Ouvrir la modale de commande
5. Vérifier le comportement de l'interface

**Données de test** :

```
Base de données :
- Tables : Inaccessibles (timeout ou erreur de connexion)
- Commande : [id_order de test]
```

**Résultat attendu** :

- ✅ L'interface reste stable (pas de crash)
- ✅ Le bouton ne s'affiche pas (comportement sécurisé par défaut)
- ✅ Les erreurs sont loggées côté serveur
- ✅ L'utilisateur peut toujours utiliser les autres fonctionnalités

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 11 : Lien review invalide ou corrompu

**Objectif** : Vérifier le comportement lorsque le lien review retourné par l'API est invalide.

**Étapes** :

1. Préparer une commande avec un lien review invalide dans la base de données
2. Se connecter avec un compte utilisateur
3. Accéder à la page de détail de la commande
4. Ouvrir la modale de commande
5. Vérifier l'affichage du bouton
6. Si le bouton s'affiche, cliquer et vérifier le comportement

**Données de test** :

```
Commande avec :
- review_link : "invalid-url" ou URL corrompue
- Lien dans DB : Présent mais invalide
```

**Résultat attendu** :

- ✅ Le bouton ne s'affiche pas ou un message d'erreur est affiché
- ✅ Si le bouton s'affiche et est cliqué, un message d'erreur approprié est affiché
- ✅ L'utilisateur est informé du problème

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### 🔒 CAS DE SÉCURITÉ ET AUTORISATIONS

### Scénario 12 : Accès non autorisé - Utilisateur différent

**Objectif** : Vérifier qu'un utilisateur ne peut pas voir le bouton pour les commandes d'un autre utilisateur.

**Étapes** :

1. Se connecter avec l'utilisateur A
2. Noter l'ID d'une commande de l'utilisateur A
3. Se déconnecter
4. Se connecter avec l'utilisateur B
5. Tenter d'accéder à la page de détail de la commande de l'utilisateur A (via URL directe)
6. Vérifier le comportement

**Données de test** :

```
Utilisateurs :
- Utilisateur A : [compte avec commande]
- Utilisateur B : [autre compte]
- ID commande : [commande de l'utilisateur A]
```

**Résultat attendu** :

- ✅ L'accès à la commande d'un autre utilisateur est refusé
- ✅ Un message d'erreur approprié est affiché
- ✅ Aucune information sensible n'est exposée
- ✅ Le bouton n'est jamais visible pour les commandes d'autres utilisateurs

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 13 : Validation du lien review - Sécurité

**Objectif** : Vérifier que le lien review est sécurisé et ne peut pas être manipulé.

**Étapes** :

1. Se connecter avec un compte utilisateur
2. Accéder à la page de détail de la commande
3. Ouvrir la modale de commande
4. Inspecter le lien review retourné par l'API
5. Tenter de modifier le lien (changer l'ID commande, ajouter des paramètres, etc.)
6. Vérifier que le lien modifié est rejeté

**Données de test** :

```
Lien review :
- Lien original : [lien valide de l'API]
- Lien modifié : [lien avec ID commande modifié ou paramètres ajoutés]
```

**Résultat attendu** :

- ✅ Le lien original fonctionne correctement
- ✅ Les liens modifiés sont rejetés par le serveur
- ✅ Un message d'erreur approprié est affiché pour les liens invalides
- ✅ Aucun accès non autorisé n'est possible

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### ⚡ CAS DE PERFORMANCE

### Scénario 14 : Temps de chargement de la modale

**Objectif** : Vérifier que l'ajout du bouton n'impacte pas le temps de chargement de la modale.

**Étapes** :

1. Se connecter avec un compte utilisateur
2. Accéder à la page de détail de la commande
3. Mesurer le temps de chargement de la modale (avec et sans le bouton)
4. Comparer les performances

**Données de test** :

```
Métriques :
- Temps de chargement attendu : < 2 secondes
- Commande : [id_order de test]
```

**Résultat attendu** :

- ✅ Le temps de chargement reste acceptable (< 2 secondes)
- ✅ Pas de dégradation significative par rapport à la version sans le bouton
- ✅ L'interface reste réactive

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 15 : Performance de l'API modifiée

**Objectif** : Vérifier que la modification de l'API n'impacte pas ses performances.

**Étapes** :

1. Appeler l'API GET /request3/clientaccount/orders/{id_order} plusieurs fois
2. Mesurer le temps de réponse
3. Comparer avec les performances avant modification (si données disponibles)

**Données de test** :

```
API Call :
- Endpoint: GET /request3/clientaccount/orders/{id_order}
- Nombre d'appels : 10
- Temps de réponse attendu : < 500ms par appel
```

**Résultat attendu** :

- ✅ Le temps de réponse reste acceptable (< 500ms)
- ✅ Pas de dégradation significative
- ✅ Les requêtes base de données sont optimisées

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### 🔄 CAS D'INTÉGRATION

### Scénario 16 : Synchronisation après dépôt d'avis

**Objectif** : Vérifier que la mise à jour de la base de données après dépôt d'avis est correctement synchronisée.

**Étapes** :

1. Se connecter avec un compte utilisateur
2. Accéder à la page de détail de la commande
3. Vérifier que le bouton est visible
4. Cliquer sur le bouton et laisser un avis
5. Vérifier dans la base de données que l'avis est enregistré dans `ps_avis_verifie_product_review`
6. Retourner à la page de détail de la commande
7. Vérifier que le bouton n'est plus visible

**Données de test** :

```
Commande avec :
- ID commande : [id_order de test]
- Avis déposé : Oui (après étape 4)
- Vérification DB : Présent dans ps_avis_verifie_product_review
```

**Résultat attendu** :

- ✅ L'avis est correctement enregistré dans la base de données
- ✅ Le bouton disparaît après l'enregistrement
- ✅ La synchronisation est immédiate ou avec un délai acceptable (< 5 secondes)

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### 🌐 CAS DE COMPATIBILITÉ

### Scénario 17 : Compatibilité navigateurs - Chrome

**Objectif** : Vérifier le fonctionnement du bouton sur Chrome.

**Étapes** :

1. Ouvrir Chrome (version 120+)
2. Se connecter avec un compte utilisateur
3. Accéder à la page de détail de la commande
4. Ouvrir la modale de commande
5. Tester l'affichage et le clic sur le bouton

**Données de test** :

```
Navigateur: Chrome 120+
Version: [version exacte]
```

**Résultat attendu** :

- ✅ Le bouton s'affiche correctement
- ✅ Le bouton est cliquable
- ✅ La redirection fonctionne
- ✅ Aucune régression visuelle

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 18 : Compatibilité navigateurs - Firefox

**Objectif** : Vérifier le fonctionnement du bouton sur Firefox.

**Étapes** :

1. Ouvrir Firefox (version 115+)
2. Se connecter avec un compte utilisateur
3. Accéder à la page de détail de la commande
4. Ouvrir la modale de commande
5. Tester l'affichage et le clic sur le bouton

**Données de test** :

```
Navigateur: Firefox 115+
Version: [version exacte]
```

**Résultat attendu** :

- ✅ Le bouton s'affiche correctement
- ✅ Le bouton est cliquable
- ✅ La redirection fonctionne
- ✅ Aucune régression visuelle

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 19 : Responsive design - Mobile

**Objectif** : Vérifier l'adaptation du bouton sur mobile.

**Étapes** :

1. Ouvrir un navigateur sur mobile (ou mode responsive)
2. Se connecter avec un compte utilisateur
3. Accéder à la page de détail de la commande
4. Ouvrir la modale de commande
5. Vérifier l'affichage et la taille du bouton

**Données de test** :

```
Résolution: 375x667 (Mobile)
Navigateur: Chrome Mobile ou Safari Mobile
```

**Résultat attendu** :

- ✅ Le bouton s'affiche correctement sur mobile
- ✅ Le bouton est de taille appropriée (pas trop petit)
- ✅ Le bouton est facilement cliquable
- ✅ La modale reste lisible et fonctionnelle

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### ♿ CAS D'ACCESSIBILITÉ

### Scénario 20 : Navigation au clavier

**Objectif** : Vérifier que le bouton est accessible au clavier.

**Étapes** :

1. Se connecter avec un compte utilisateur
2. Accéder à la page de détail de la commande
3. Ouvrir la modale de commande
4. Naviguer uniquement avec Tab pour atteindre le bouton
5. Activer le bouton avec Enter
6. Vérifier la redirection

**Données de test** :

```
Navigation :
- Touches: Tab, Enter
- Lecteur d'écran: [si applicable]
```

**Résultat attendu** :

- ✅ Le bouton est accessible au clavier (Tab)
- ✅ Le bouton peut être activé avec Enter
- ✅ Le focus est visible sur le bouton
- ✅ La redirection fonctionne après activation au clavier

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 21 : Compatibilité lecteur d'écran

**Objectif** : Vérifier que le bouton est correctement annoncé par les lecteurs d'écran.

**Étapes** :

1. Activer un lecteur d'écran (NVDA, JAWS, VoiceOver)
2. Se connecter avec un compte utilisateur
3. Accéder à la page de détail de la commande
4. Ouvrir la modale de commande
5. Naviguer jusqu'au bouton avec le lecteur d'écran
6. Vérifier l'annonce du bouton

**Données de test** :

```
Lecteur d'écran :
- Outil: NVDA / JAWS / VoiceOver
- Version: [version]
```

**Résultat attendu** :

- ✅ Le bouton est correctement annoncé par le lecteur d'écran
- ✅ Le texte du bouton est clair et compréhensible
- ✅ Le contexte (commande, avis) est annoncé si applicable
- ✅ L'action (redirection) est claire

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

## 🐛 Bugs identifiés

[Aucun bug identifié pour le moment]

---

## 📊 Résumé des tests

- **Total de scénarios** : 21
  - Cas nominaux : 5
  - Cas limites : 3
  - Cas d'erreur : 3
  - Cas de sécurité/autorisations : 2
  - Cas de performance : 2
  - Cas d'intégration : 1
  - Cas de compatibilité : 3
  - Cas d'accessibilité : 2
- **Passés** : X (XX%)
- **Échoués** : X (XX%)
- **Bloqués** : X (XX%)
- **Couverture estimée** : 100% des critères d'acceptation

---

## 📝 Notes & Observations

- Le bouton doit être "petit" selon la spécification
- La maquette Figma est disponible pour référence
- Il y a une subtask MME-1460 liée à cette US
- Plusieurs tickets de test sont bloqués par cette US (TEST-12252, TEST-12254, etc.)
- Le PR GitHub est disponible : https://github.com/PrestaShopCorp/addons.prestashop.com/pull/3664

---

## ✍️ Validation

- **Testé par** : [Nom]
- **Date de test** : [AAAA-MM-JJ]
- **Validé par** : [Nom du responsable QA]
- **Date de validation** : [AAAA-MM-JJ]

