# [Compte Addons] Ajouter bouton "leave a review" - Order Detail Page - Stratégie de Test

## 📋 Informations générales

- **Feature** : Bouton "leave a review" sur la page de détail de commande
- **User Story** : MME-1384 : [Compte Addons] Ajouter bouton "leave a review" - Order Detail Page
- **Sprint/Version** : [À compléter]
- **Date de création** : 2025-11-18
- **Auteur** : [Nom du QA]
- **Statut** : Draft
- **Lien Jira/Ticket** : https://forge.prestashop.com/browse/MME-1384

---

## 🎯 Objectif de la fonctionnalité

**Description** : 

Cette fonctionnalité vise à améliorer la collecte d'avis clients sur la marketplace PrestaShop Addons en ajoutant un bouton "leave a review" directement dans la modale de détail de commande. L'objectif est de faciliter le processus de soumission d'avis pour les clients, qui trouvent actuellement le processus confus et ignorent souvent les règles ou le délai limité pour laisser un avis.

Le bouton doit s'afficher uniquement lorsque :
- Le lien avis vérifié est déjà généré pour la commande
- L'avis n'a pas encore été déposé pour cette commande

Le bouton doit disparaître après qu'un avis ait été déposé.

**User Stories couvertes** :

- MME-1384 : [Compte Addons] Ajouter bouton "leave a review" - Order Detail Page

---

## ✅ Prérequis

### Environnement

- **OS** : Windows/Mac/Linux
- **Navigateurs** : Chrome 120+, Firefox 115+, Safari 17+, Edge
- **Résolution min** : 1920x1080 (Desktop), 375x667 (Mobile)

### Données nécessaires

- [ ] Compte utilisateur avec commandes passées
- [ ] Commandes avec liens avis vérifiés générés
- [ ] Commandes avec avis déjà déposés
- [ ] Commandes sans lien avis vérifié
- [ ] Accès à la base de données pour vérifier les tables `ps_avis_verifie_product_review` et `ps_avis_verifie_order_url`

### Dépendances

- API GET /request3/clientaccount/orders/{id_order} fonctionnelle
- Tables de base de données `ps_avis_verifie_product_review` et `ps_avis_verifie_order_url` accessibles
- Page review du compte accessible et fonctionnelle

---

## 🎯 Objectif principal

Valider que le bouton "leave a review" s'affiche correctement dans la modale de commande selon les conditions définies (lien généré et avis non déposé) et qu'il redirige correctement vers la page review filtrée sur la bonne commande. Vérifier également que le bouton disparaît après qu'un avis ait été déposé.

---

## 📊 Axes de test et points de vigilance

### 1. Scénarios nominaux

**Objectif** : Vérification du comportement standard du bouton dans les cas d'usage principaux.

**Approche** :
- Tester l'affichage du bouton lorsque le lien est généré et l'avis non déposé (CA1)
- Tester la disparition du bouton après dépôt d'un avis (CA2)
- Tester la redirection vers la page review avec le bon filtre
- Valider que le bouton est cliquable et fonctionnel

**Points de vigilance** :
- S'assurer que le bouton s'affiche uniquement dans les bonnes conditions
- Vérifier que la redirection fonctionne correctement avec les bons paramètres
- Valider que le bouton disparaît immédiatement ou après rafraîchissement après dépôt d'avis

---

### 2. Cas limites et robustesse

**Objectif** : Tester les cas limites et les situations particulières.

**Approche** :
- Tester avec des commandes contenant plusieurs produits
- Tester avec des commandes annulées ou remboursées
- Tester avec des liens expirés
- Tester avec des avis en cours de modération
- Tester avec des commandes très anciennes

**Points de vigilance** :
- Vérifier que le comportement est cohérent dans tous les cas limites
- S'assurer qu'il n'y a pas de régression sur les fonctionnalités existantes
- Valider que les erreurs sont gérées de manière appropriée

---

### 3. Gestion des erreurs

**Objectif** : Validation de la gestion des erreurs et des cas d'échec.

**Approche** :
- Tester le comportement en cas d'erreur API
- Tester le comportement si les tables de base de données sont inaccessibles
- Tester le comportement si le lien review n'est pas valide
- Tester le comportement en cas de timeout

**Points de vigilance** :
- S'assurer que les erreurs ne cassent pas l'interface
- Vérifier que les messages d'erreur sont appropriés (si affichés)
- Valider que l'expérience utilisateur reste acceptable même en cas d'erreur

---

### 4. Sécurité et autorisations

**Objectif** : Vérifier que les contrôles d'accès sont correctement implémentés.

**Approche** :
- Tester l'accès avec différents rôles utilisateurs
- Vérifier que seuls les propriétaires de commande peuvent voir le bouton
- Tester la validation des liens review (tokens, sécurité)
- Vérifier qu'il n'y a pas de fuite d'informations

**Points de vigilance** :
- Valider que les utilisateurs ne peuvent pas accéder aux avis d'autres utilisateurs
- Vérifier que les liens sont sécurisés et ne peuvent pas être manipulés
- S'assurer qu'il n'y a pas d'exposition de données sensibles

---

### 5. Performance

**Objectif** : S'assurer que l'ajout du bouton n'impacte pas les performances.

**Approche** :
- Mesurer le temps de chargement de la modale avec et sans le bouton
- Tester le temps de réponse de l'API modifiée
- Vérifier l'impact sur les requêtes base de données
- Tester avec plusieurs commandes simultanées

**Points de vigilance** :
- Temps de chargement acceptable (< 2 secondes)
- Pas de dégradation de performance de l'API
- Requêtes base de données optimisées

---

### 6. Intégration

**Objectif** : Valider les interactions avec l'API et la base de données.

**Approche** :
- Tester l'appel API GET /request3/clientaccount/orders/{id_order} avec le nouveau champ review_link
- Vérifier les requêtes vers les tables `ps_avis_verifie_product_review` et `ps_avis_verifie_order_url`
- Tester la synchronisation des données après dépôt d'avis
- Valider l'intégration avec la page review

**Points de vigilance** :
- Vérifier que l'API retourne correctement le champ review_link
- S'assurer que les vérifications en base de données sont correctes
- Valider que la synchronisation fonctionne après dépôt d'avis
- Vérifier que la redirection vers la page review fonctionne avec les bons filtres

---

### 7. Compatibilité

**Objectif** : S'assurer que le bouton fonctionne sur différents navigateurs et résolutions.

**Approche** :
- Tester sur les principaux navigateurs (Chrome, Firefox, Safari, Edge)
- Tester sur différentes résolutions (Desktop, Tablet, Mobile)
- Vérifier la cohérence visuelle selon la maquette Figma

**Points de vigilance** :
- Aucune régression visuelle sur les différents navigateurs
- Le bouton doit être visible et cliquable sur toutes les résolutions
- Respect de la maquette Figma

---

### 8. Accessibilité

**Objectif** : Valider que le bouton est accessible à tous les utilisateurs.

**Approche** :
- Tester la navigation au clavier
- Vérifier la compatibilité avec les lecteurs d'écran
- Valider les contrastes et les tailles de police
- Vérifier les attributs ARIA

**Points de vigilance** :
- Le bouton doit être accessible au clavier
- Les lecteurs d'écran doivent pouvoir annoncer le bouton correctement
- Les contrastes doivent respecter les standards WCAG

---

## ⚠️ Impacts et non-régression

**Zones à risque identifiées** :

Une attention particulière sera portée sur les éléments suivants pour s'assurer qu'ils ne sont pas affectés :

1. **Modale de commande existante**
   - **Pourquoi** : L'ajout du bouton ne doit pas perturber l'affichage ou le fonctionnement de la modale
   - **Tests de régression** : Vérifier que toutes les fonctionnalités de la modale fonctionnent toujours normalement

2. **API GET /request3/clientaccount/orders/{id_order}**
   - **Pourquoi** : La modification de l'API ne doit pas casser les fonctionnalités existantes qui l'utilisent
   - **Tests de régression** : Tester que toutes les autres fonctionnalités utilisant cette API fonctionnent toujours

3. **Page review du compte**
   - **Pourquoi** : La redirection vers la page review doit fonctionner correctement avec les filtres
   - **Tests de régression** : Vérifier que la page review fonctionne toujours normalement

**Fonctionnalités connexes à vérifier** :

- [ ] La modale de commande reste fonctionnelle
- [ ] L'API de commande ne régress pas
- [ ] La page review fonctionne correctement
- [ ] Performance acceptable (< 2 secondes)
- [ ] Aucune régression visuelle

---

## 📈 Métriques et critères de succès

### Critères de validation

- ✅ Le bouton s'affiche lorsque le lien est généré et l'avis non déposé (CA1)
- ✅ Le bouton disparaît après dépôt d'un avis (CA2)
- ✅ La redirection vers la page review fonctionne correctement
- ✅ Aucune régression identifiée
- ✅ Performance acceptable (< 2 secondes)
- ✅ Couverture estimée : 100% des critères d'acceptation

### Métriques de test

- **Nombre total de scénarios** : 18-20
- **Nombre de scénarios critiques** : 2 (un par CA)
- **Temps estimé de test** : 4-6 heures
- **Environnements de test** : Staging, Preprod

---

## 🔍 Tests de régression

**Stratégie** : 

Tester les fonctionnalités critiques de la modale de commande et de l'API pour s'assurer qu'elles ne sont pas impactées par l'ajout du bouton.

**Checklist de régression** :

- [ ] Modale de commande - Vérifier que toutes les fonctionnalités existantes fonctionnent
- [ ] API de commande - Tester que les autres fonctionnalités utilisant l'API fonctionnent toujours
- [ ] Page review - Vérifier que la page review fonctionne normalement

---

## 📝 Notes & Observations

- Le bouton doit être petit et discret selon la spécification ("petit bouton")
- La maquette Figma est disponible pour référence visuelle
- Il y a une subtask MME-1460 liée à cette US
- Plusieurs tickets de test (TEST-12252, TEST-12254, etc.) sont bloqués par cette US

---

## 🔗 Documents associés

- **Questions et Clarifications** : [01-questions-clarifications.md]
- **Cas de test** : [03-cas-test.md]
- **User Story** : https://forge.prestashop.com/browse/MME-1384
- **Maquette Figma** : https://www.figma.com/design/Ia0Py5YbdxcQmfQxPWRIP0/branch/2TsfBOW3m4AqA013aFeviY/-LIVE--PrestaShop-Marketplace--web-?node-id=6017-142189

---

## ✍️ Validation

- **Rédigé par** : [Nom]
- **Date de rédaction** : 2025-11-18
- **Validé par** : [Nom du responsable QA]
- **Date de validation** : [AAAA-MM-JJ]

