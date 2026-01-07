# Produit MCP Server Compliant - ajouter une coche sur les pages produits dans DS - Stratégie de Test

## 📋 Informations générales

- **Feature** : Case à cocher "MCP Compliant" sur les pages produits DisneyStore
- **User Story** : MME-1436 : Produit MCP Server Compliant - ajouter une coche sur les pages produits dans DS
- **Sprint/Version** : [À compléter]
- **Date de création** : 2025-11-18
- **Auteur** : [Nom du QA]
- **Statut** : Draft
- **Lien Jira/Ticket** : https://forge.prestashop.com/browse/MME-1436

---

## 🎯 Objectif de la fonctionnalité

**Description** : 

Cette fonctionnalité permet à l'équipe Solution Engineer (notamment Agathe) de flaguer les modules comme "MCP Compliant" directement depuis la page produit DisneyStore. L'objectif est de pouvoir identifier et mettre en avant dans le futur les produits qui utilisent le MCP PrestaShop Server.

La fonctionnalité consiste à :
- Ajouter une colonne "MCP Server" dans le tableau des ZIPs de la page produit
- Ajouter une case à cocher dans chaque ligne de ZIP pour indiquer si le ZIP est MCP Compliant
- Enregistrer l'état de la case (YES/NO) en base de données
- Afficher l'état persistant après rechargement de la page

**User Stories couvertes** :

- MME-1436 : Produit MCP Server Compliant - ajouter une coche sur les pages produits dans DS

---

## ✅ Prérequis

### Environnement

- **OS** : Windows/Mac/Linux
- **Navigateurs** : Chrome 120+, Firefox 115+, Safari 17+, Edge
- **Résolution min** : 1920x1080

### Données nécessaires

- [ ] Compte utilisateur avec rôle Solution Engineer (Agathe ou équivalent)
- [ ] Accès à DisneyStore (DS)
- [ ] Produits avec plusieurs ZIPs soumis
- [ ] ZIPs avec code MCP Compliant pour test
- [ ] ZIPs sans code MCP Compliant pour test
- [ ] Accès à la base de données pour vérifier la persistance

### Dépendances

- Page produit DisneyStore accessible
- Tableau des ZIPs fonctionnel
- Base de données avec la nouvelle propriété "MCP Complaint" créée

---

## 🎯 Objectif principal

Valider que la colonne "MCP Server" avec la case à cocher fonctionne correctement : affichage, clic, enregistrement en base de données, et persistance après rechargement de la page.

---

## 📊 Axes de test et points de vigilance

### 1. Scénarios nominaux

**Objectif** : Vérification du comportement standard de la case à cocher dans les cas d'usage principaux.

**Approche** :
- Tester l'affichage de la colonne "MCP Server" dans le tableau (CA1)
- Tester le clic sur la case à cocher et le basculement d'état (CA2)
- Tester l'enregistrement en base de données (CA3.a et CA3.b)
- Tester la persistance après rechargement (CA3)

**Points de vigilance** :
- S'assurer que la colonne s'affiche correctement dans le tableau
- Vérifier que la case est décochée par défaut pour les nouveaux ZIPs
- Valider que l'enregistrement fonctionne correctement (YES/NO)
- Vérifier que l'état persiste après rechargement

---

### 2. Cas limites et robustesse

**Objectif** : Tester les cas limites et les situations particulières.

**Approche** :
- Tester avec des produits ayant de nombreux ZIPs
- Tester avec des ZIPs très anciens
- Tester avec des ZIPs en cours de traitement
- Tester les clics rapides multiples

**Points de vigilance** :
- Vérifier que le comportement est cohérent dans tous les cas limites
- S'assurer qu'il n'y a pas de conflits lors de clics rapides
- Valider que les performances restent acceptables

---

### 3. Gestion des erreurs

**Objectif** : Validation de la gestion des erreurs et des cas d'échec.

**Approche** :
- Tester le comportement en cas d'erreur d'enregistrement
- Tester le comportement si la base de données est inaccessible
- Tester le comportement en cas de timeout
- Tester avec des données invalides

**Points de vigilance** :
- S'assurer que les erreurs ne cassent pas l'interface
- Vérifier que les messages d'erreur sont appropriés
- Valider que l'état de la case reste cohérent même en cas d'erreur

---

### 4. Sécurité et autorisations

**Objectif** : Vérifier que les contrôles d'accès sont correctement implémentés.

**Approche** :
- Tester l'accès avec différents rôles utilisateurs
- Vérifier que seuls les utilisateurs autorisés peuvent modifier la case
- Tester la validation côté backend
- Vérifier qu'il n'y a pas de fuite d'informations

**Points de vigilance** :
- Valider que seuls les Solution Engineers peuvent modifier la case
- Vérifier que les modifications sont validées côté backend
- S'assurer qu'il n'y a pas d'exposition de données sensibles

---

### 5. Performance

**Objectif** : S'assurer que l'ajout de la colonne n'impacte pas les performances.

**Approche** :
- Mesurer le temps de chargement de la page produit avec la nouvelle colonne
- Tester le temps de réponse de l'enregistrement
- Vérifier l'impact sur les requêtes base de données
- Tester avec des produits ayant de nombreux ZIPs

**Points de vigilance** :
- Temps de chargement acceptable (< 2 secondes)
- Temps de réponse de l'enregistrement acceptable (< 1 seconde)
- Requêtes base de données optimisées

---

### 6. Intégration

**Objectif** : Valider les interactions avec la base de données et l'API.

**Approche** :
- Tester l'enregistrement en base de données (YES/NO)
- Vérifier la lecture de l'état depuis la base de données
- Tester la synchronisation après modification
- Valider l'intégration avec le tableau existant

**Points de vigilance** :
- Vérifier que les données sont correctement enregistrées
- S'assurer que la lecture depuis la base de données fonctionne
- Valider que la synchronisation est immédiate ou avec un délai acceptable

---

### 7. Compatibilité

**Objectif** : S'assurer que la colonne fonctionne sur différents navigateurs et résolutions.

**Approche** :
- Tester sur les principaux navigateurs (Chrome, Firefox, Safari, Edge)
- Tester sur différentes résolutions (Desktop, Tablet, Mobile)
- Vérifier la cohérence visuelle du tableau

**Points de vigilance** :
- Aucune régression visuelle sur les différents navigateurs
- La colonne doit être visible et fonctionnelle sur toutes les résolutions
- Le tableau doit rester lisible avec la nouvelle colonne

---

### 8. Accessibilité

**Objectif** : Valider que la case à cocher est accessible à tous les utilisateurs.

**Approche** :
- Tester la navigation au clavier
- Vérifier la compatibilité avec les lecteurs d'écran
- Valider les contrastes et les tailles
- Vérifier les attributs ARIA

**Points de vigilance** :
- La case à cocher doit être accessible au clavier
- Les lecteurs d'écran doivent pouvoir annoncer la case correctement
- Les contrastes doivent respecter les standards WCAG

---

## ⚠️ Impacts et non-régression

**Zones à risque identifiées** :

Une attention particulière sera portée sur les éléments suivants pour s'assurer qu'ils ne sont pas affectés :

1. **Tableau des ZIPs existant**
   - **Pourquoi** : L'ajout de la colonne ne doit pas perturber l'affichage ou le fonctionnement du tableau
   - **Tests de régression** : Vérifier que toutes les fonctionnalités du tableau fonctionnent toujours normalement

2. **Page produit DisneyStore**
   - **Pourquoi** : L'ajout de la colonne ne doit pas impacter les autres fonctionnalités de la page
   - **Tests de régression** : Tester que toutes les autres fonctionnalités de la page fonctionnent toujours

3. **Base de données**
   - **Pourquoi** : L'ajout de la nouvelle propriété ne doit pas impacter les autres données
   - **Tests de régression** : Vérifier que les autres propriétés des produits/ZIPs ne sont pas affectées

**Fonctionnalités connexes à vérifier** :

- [ ] Le tableau des ZIPs reste fonctionnel
- [ ] La page produit fonctionne correctement
- [ ] Les autres colonnes du tableau ne sont pas impactées
- [ ] Performance acceptable (< 2 secondes)
- [ ] Aucune régression visuelle

---

## 📈 Métriques et critères de succès

### Critères de validation

- ✅ La colonne "MCP Server" est ajoutée dans le tableau (CA1)
- ✅ La case à cocher est cliquable et bascule entre cochée/décochée (CA2)
- ✅ La case est décochée par défaut pour les nouveaux ZIPs (CA2)
- ✅ L'état est correctement enregistré en base de données (CA3.a et CA3.b)
- ✅ L'état persiste après rechargement de la page (CA3)
- ✅ Aucune régression identifiée
- ✅ Performance acceptable (< 2 secondes)
- ✅ Couverture estimée : 100% des critères d'acceptation

### Métriques de test

- **Nombre total de scénarios** : 18-20
- **Nombre de scénarios critiques** : 4 (un par CA principal)
- **Temps estimé de test** : 4-6 heures
- **Environnements de test** : Staging, Preprod

---

## 🔍 Tests de régression

**Stratégie** : 

Tester les fonctionnalités critiques de la page produit DisneyStore et du tableau des ZIPs pour s'assurer qu'elles ne sont pas impactées par l'ajout de la colonne.

**Checklist de régression** :

- [ ] Tableau des ZIPs - Vérifier que toutes les fonctionnalités existantes fonctionnent
- [ ] Page produit - Tester que les autres fonctionnalités de la page fonctionnent toujours
- [ ] Base de données - Vérifier que les autres propriétés ne sont pas affectées

---

## 📝 Notes & Observations

- La propriété est stockée comme "MCP Complaint" en base de données (attention à l'orthographe)
- Par défaut, tous les ZIPs sont en "NO" jusqu'à ce que la case soit cochée
- La colonne est dans l'onglet ZIP de la page produit DisneyStore
- Plusieurs tickets de test sont bloqués par cette US (TEST-12265 à TEST-12272)

---

## 🔗 Documents associés

- **Questions et Clarifications** : [01-questions-clarifications.md]
- **Cas de test** : [03-cas-test.md]
- **User Story** : https://forge.prestashop.com/browse/MME-1436

---

## ✍️ Validation

- **Rédigé par** : [Nom]
- **Date de rédaction** : 2025-11-18
- **Validé par** : [Nom du responsable QA]
- **Date de validation** : [AAAA-MM-JJ]

