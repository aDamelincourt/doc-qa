# Produit MCP Server Compliant - ajouter une coche sur les pages produits dans DS - Cas de Test

## 📋 Informations générales

- **Feature** : Case à cocher "MCP Compliant" sur les pages produits DisneyStore
- **User Story** : MME-1436 : Produit MCP Server Compliant - ajouter une coche sur les pages produits dans DS
- **Sprint/Version** : [À compléter]
- **Date de création** : 2025-11-18
- **Auteur** : [Nom du QA]
- **Statut** : Draft
- **Lien Jira/Ticket** : https://forge.prestashop.com/browse/MME-1436

---

## 🔗 Documents associés

- **Stratégie de test** : [02-strategie-test.md]
- **Questions et Clarifications** : [01-questions-clarifications.md]

---

## 🧪 Scénarios de test

### 📌 CAS NOMINAUX

### Scénario 1 : Affichage de la colonne "MCP Server" - CA1

**Objectif** : Vérifier que la colonne "MCP Server" est ajoutée dans le tableau des ZIPs avec une case à cocher dans chaque ligne.

**Étapes** :

1. Se connecter avec un compte Solution Engineer (Agathe ou équivalent)
2. Accéder à la page produit DisneyStore
3. Naviguer vers l'onglet ZIP
4. Vérifier l'affichage du tableau des ZIPs
5. Vérifier la présence de la colonne "MCP Server"
6. Vérifier qu'une case à cocher est présente dans chaque ligne de ZIP

**Données de test** :

```
Page produit :
- Produit : [produit de test avec plusieurs ZIPs]
- Onglet : ZIP
- Nombre de ZIPs : 3+
```

**Résultat attendu** :

- ✅ La colonne "MCP Server" est visible dans le tableau
- ✅ La colonne est correctement positionnée
- ✅ Chaque ligne de ZIP contient une case à cocher dans la colonne
- ✅ Le tableau reste lisible et fonctionnel

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 2 : Case décochée par défaut - CA2

**Objectif** : Vérifier que la case à cocher est décochée par défaut pour tous les ZIPs nouveaux ou existants qui n'ont jamais été flagués.

**Étapes** :

1. Se connecter avec un compte Solution Engineer
2. Accéder à la page produit DisneyStore
3. Naviguer vers l'onglet ZIP
4. Vérifier l'état de toutes les cases à cocher dans la colonne "MCP Server"
5. Vérifier dans la base de données que la propriété "MCP Complaint" est à "NO" pour ces ZIPs

**Données de test** :

```
ZIPs de test :
- ZIP 1 : Nouveau, jamais flagué
- ZIP 2 : Existant, jamais flagué
- Vérification DB : MCP Complaint = NO pour tous
```

**Résultat attendu** :

- ✅ Toutes les cases à cocher sont décochées par défaut
- ✅ La propriété "MCP Complaint" est à "NO" en base de données
- ✅ L'état est cohérent entre l'interface et la base de données

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 3 : Clic sur la case - Basculement d'état - CA2

**Objectif** : Vérifier que la case à cocher est cliquable et que son état peut être basculé entre cochée et décochée.

**Étapes** :

1. Se connecter avec un compte Solution Engineer
2. Accéder à la page produit DisneyStore
3. Naviguer vers l'onglet ZIP
4. Cliquer sur une case à cocher décochée
5. Vérifier que la case devient cochée
6. Cliquer à nouveau sur la case
7. Vérifier que la case redevient décochée

**Données de test** :

```
Case à cocher :
- État initial : Décochée
- Action 1 : Clic → État attendu : Cochée
- Action 2 : Clic → État attendu : Décochée
```

**Résultat attendu** :

- ✅ La case est cliquable
- ✅ Le clic bascule correctement l'état (cochée ↔ décochée)
- ✅ Le changement d'état est immédiat et visible
- ✅ Aucune erreur n'est affichée

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 4 : Enregistrement - Marquage comme Compliant (YES) - CA3.a

**Objectif** : Vérifier que lorsqu'un utilisateur coche la case et enregistre, la propriété "MCP Complaint" est mise à jour à "YES" en base de données.

**Étapes** :

1. Se connecter avec un compte Solution Engineer
2. Accéder à la page produit DisneyStore
3. Naviguer vers l'onglet ZIP
4. Cocher la case à cocher pour un ZIP
5. Enregistrer (selon le mécanisme d'enregistrement)
6. Vérifier dans la base de données que la propriété "MCP Complaint" est à "YES" pour ce ZIP

**Données de test** :

```
ZIP de test :
- ID ZIP : [id_zip de test]
- Action : Cocher la case
- Enregistrement : [selon le mécanisme]
- Vérification DB : MCP Complaint = YES
```

**Résultat attendu** :

- ✅ La case reste cochée après enregistrement
- ✅ La propriété "MCP Complaint" est à "YES" en base de données
- ✅ L'enregistrement est réussi (message de confirmation si applicable)
- ✅ Aucune erreur n'est affichée

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 5 : Enregistrement - Marquage comme Non-Compliant (NO) - CA3.b

**Objectif** : Vérifier que lorsqu'un utilisateur décoche (ou laisse décochée) la case et enregistre, la propriété "MCP Complaint" est mise à jour à "NO" en base de données.

**Étapes** :

1. Se connecter avec un compte Solution Engineer
2. Accéder à la page produit DisneyStore
3. Naviguer vers l'onglet ZIP
4. S'assurer qu'une case est décochée (ou décocher une case cochée)
5. Enregistrer (selon le mécanisme d'enregistrement)
6. Vérifier dans la base de données que la propriété "MCP Complaint" est à "NO" pour ce ZIP

**Données de test** :

```
ZIP de test :
- ID ZIP : [id_zip de test]
- Action : Laisser décochée ou décocher
- Enregistrement : [selon le mécanisme]
- Vérification DB : MCP Complaint = NO
```

**Résultat attendu** :

- ✅ La case reste décochée après enregistrement
- ✅ La propriété "MCP Complaint" est à "NO" en base de données
- ✅ L'enregistrement est réussi (message de confirmation si applicable)
- ✅ Aucune erreur n'est affichée

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 6 : Persistance après rechargement - CA3

**Objectif** : Vérifier que l'état de la case à cocher correspond à la valeur enregistrée en base de données après rechargement de la page.

**Étapes** :

1. Se connecter avec un compte Solution Engineer
2. Accéder à la page produit DisneyStore
3. Naviguer vers l'onglet ZIP
4. Cocher la case pour un ZIP
5. Enregistrer
6. Vérifier dans la base de données que la propriété est à "YES"
7. Recharger la page
8. Vérifier que la case est toujours cochée

**Données de test** :

```
ZIP de test :
- ID ZIP : [id_zip de test]
- État enregistré : YES (cochée)
- Vérification après rechargement : Case toujours cochée
```

**Résultat attendu** :

- ✅ La case est toujours cochée après rechargement
- ✅ L'état correspond à la valeur en base de données
- ✅ La persistance fonctionne correctement
- ✅ Aucune perte de données

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### 🔢 CAS LIMITES

### Scénario 7 : Produit avec de nombreux ZIPs

**Objectif** : Vérifier le comportement avec un produit contenant de nombreux ZIPs.

**Étapes** :

1. Se connecter avec un compte Solution Engineer
2. Accéder à la page produit avec 10+ ZIPs
3. Naviguer vers l'onglet ZIP
4. Vérifier l'affichage de la colonne "MCP Server"
5. Tester le clic sur plusieurs cases
6. Vérifier les performances

**Données de test** :

```
Produit avec :
- Nombre de ZIPs : 10+
- Test : Clic sur plusieurs cases
```

**Résultat attendu** :

- ✅ La colonne s'affiche correctement même avec de nombreux ZIPs
- ✅ Les performances restent acceptables
- ✅ Le tableau reste lisible et fonctionnel
- ✅ Toutes les cases sont accessibles et cliquables

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 8 : Clics rapides multiples

**Objectif** : Vérifier le comportement lors de clics rapides multiples sur la même case.

**Étapes** :

1. Se connecter avec un compte Solution Engineer
2. Accéder à la page produit DisneyStore
3. Naviguer vers l'onglet ZIP
4. Effectuer plusieurs clics rapides sur une même case à cocher
5. Vérifier l'état final de la case
6. Vérifier dans la base de données l'état enregistré

**Données de test** :

```
Clics rapides :
- Nombre de clics : 5-10 clics rapides
- Case testée : [une case spécifique]
```

**Résultat attendu** :

- ✅ Aucun conflit n'est généré
- ✅ L'état final est cohérent (cochée ou décochée selon le nombre de clics)
- ✅ L'enregistrement en base de données est correct
- ✅ Aucune erreur n'est affichée

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 9 : ZIPs très anciens

**Objectif** : Vérifier le comportement avec des ZIPs très anciens qui n'ont jamais été flagués.

**Étapes** :

1. Se connecter avec un compte Solution Engineer
2. Accéder à la page produit avec des ZIPs très anciens
3. Naviguer vers l'onglet ZIP
4. Vérifier l'état des cases pour les ZIPs anciens
5. Tester le clic et l'enregistrement

**Données de test** :

```
ZIPs anciens :
- Date de soumission : [date très ancienne]
- Jamais flagués : Oui
```

**Résultat attendu** :

- ✅ Les cases sont décochées par défaut (comportement attendu)
- ✅ Les cases sont cliquables et fonctionnelles
- ✅ L'enregistrement fonctionne correctement
- ✅ Aucune erreur liée à l'ancienneté des ZIPs

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### ❌ CAS D'ERREUR

### Scénario 10 : Erreur d'enregistrement - Base de données inaccessible

**Objectif** : Vérifier le comportement lorsque la base de données est inaccessible lors de l'enregistrement.

**Étapes** :

1. Se connecter avec un compte Solution Engineer
2. Accéder à la page produit DisneyStore
3. Naviguer vers l'onglet ZIP
4. Cocher une case à cocher
5. Simuler l'indisponibilité de la base de données
6. Tenter d'enregistrer
7. Vérifier le comportement de l'interface

**Données de test** :

```
Base de données :
- Statut : Indisponible (timeout ou erreur de connexion)
- Action : Tentative d'enregistrement
```

**Résultat attendu** :

- ✅ Un message d'erreur approprié est affiché
- ✅ L'interface reste stable (pas de crash)
- ✅ L'état de la case peut être restauré ou reste dans l'état précédent
- ✅ L'utilisateur peut réessayer après résolution du problème

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 11 : Erreur API - Timeout

**Objectif** : Vérifier le comportement en cas de timeout lors de l'appel API d'enregistrement.

**Étapes** :

1. Se connecter avec un compte Solution Engineer
2. Accéder à la page produit DisneyStore
3. Naviguer vers l'onglet ZIP
4. Cocher une case à cocher
5. Simuler un timeout de l'API d'enregistrement
6. Tenter d'enregistrer
7. Vérifier le comportement

**Données de test** :

```
API :
- Timeout : > 30 secondes (timeout configuré)
- Action : Tentative d'enregistrement
```

**Résultat attendu** :

- ✅ Un message d'erreur de timeout est affiché
- ✅ L'interface reste stable
- ✅ L'utilisateur peut réessayer
- ✅ L'état de la case peut être restauré

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 12 : Données invalides

**Objectif** : Vérifier le comportement avec des données invalides (si possible à injecter).

**Étapes** :

1. Se connecter avec un compte Solution Engineer
2. Accéder à la page produit DisneyStore
3. Naviguer vers l'onglet ZIP
4. Tenter de modifier la valeur en base de données directement (si possible)
5. Recharger la page
6. Vérifier le comportement de l'interface

**Données de test** :

```
Données invalides :
- Valeur en DB : [valeur invalide, ex: "MAYBE", NULL, etc.]
- Test : Affichage de la page avec données invalides
```

**Résultat attendu** :

- ✅ L'interface gère gracieusement les données invalides
- ✅ Un comportement par défaut est appliqué (décochée)
- ✅ Aucune erreur ne casse l'interface
- ✅ Les données peuvent être corrigées via l'interface

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### 🔒 CAS DE SÉCURITÉ ET AUTORISATIONS

### Scénario 13 : Accès non autorisé - Utilisateur sans rôle Solution Engineer

**Objectif** : Vérifier qu'un utilisateur sans le rôle Solution Engineer ne peut pas modifier la case à cocher.

**Étapes** :

1. Se connecter avec un compte utilisateur standard (sans rôle Solution Engineer)
2. Accéder à la page produit DisneyStore
3. Naviguer vers l'onglet ZIP
4. Vérifier l'affichage de la colonne "MCP Server"
5. Tenter de cliquer sur une case à cocher
6. Vérifier le comportement

**Données de test** :

```
Utilisateur :
- Rôle : Utilisateur standard (pas Solution Engineer)
- Permissions : [permissions limitées]
```

**Résultat attendu** :

- ✅ La colonne est visible (lecture seule) ou masquée selon les règles
- ✅ La case à cocher n'est pas cliquable ou l'action est refusée
- ✅ Un message d'erreur approprié est affiché si tentative de modification
- ✅ Aucune modification n'est enregistrée en base de données

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 14 : Validation backend - Tentative de manipulation

**Objectif** : Vérifier que les modifications sont validées côté backend et ne peuvent pas être contournées.

**Étapes** :

1. Se connecter avec un compte utilisateur standard
2. Intercepter les requêtes HTTP (via DevTools)
3. Tenter de modifier directement l'API pour changer l'état d'une case
4. Vérifier que la requête est rejetée

**Données de test** :

```
Requête manipulée :
- Endpoint : [API d'enregistrement]
- Headers : [sans permissions appropriées]
- Body : [tentative de modification]
```

**Résultat attendu** :

- ✅ La requête est rejetée par le serveur (403 Forbidden ou équivalent)
- ✅ Aucune modification n'est effectuée en base de données
- ✅ Un message d'erreur approprié est retourné
- ✅ La sécurité est garantie côté backend

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### ⚡ CAS DE PERFORMANCE

### Scénario 15 : Temps de chargement de la page avec la nouvelle colonne

**Objectif** : Vérifier que l'ajout de la colonne n'impacte pas le temps de chargement de la page.

**Étapes** :

1. Se connecter avec un compte Solution Engineer
2. Mesurer le temps de chargement de la page produit (onglet ZIP) avant modification
3. Mesurer le temps de chargement après ajout de la colonne
4. Comparer les performances

**Données de test** :

```
Métriques :
- Temps de chargement attendu : < 2 secondes
- Produit : [produit de test avec plusieurs ZIPs]
```

**Résultat attendu** :

- ✅ Le temps de chargement reste acceptable (< 2 secondes)
- ✅ Pas de dégradation significative par rapport à la version sans la colonne
- ✅ L'interface reste réactive

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 16 : Temps de réponse de l'enregistrement

**Objectif** : Vérifier que le temps de réponse de l'enregistrement est acceptable.

**Étapes** :

1. Se connecter avec un compte Solution Engineer
2. Accéder à la page produit DisneyStore
3. Naviguer vers l'onglet ZIP
4. Cocher une case à cocher
5. Enregistrer
6. Mesurer le temps de réponse

**Données de test** :

```
Métriques :
- Temps de réponse attendu : < 1 seconde
- Action : Enregistrement d'une case cochée
```

**Résultat attendu** :

- ✅ Le temps de réponse est acceptable (< 1 seconde)
- ✅ L'enregistrement se termine rapidement
- ✅ Le feedback utilisateur est immédiat

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### 🔄 CAS D'INTÉGRATION

### Scénario 17 : Intégration avec le tableau existant

**Objectif** : Vérifier que la nouvelle colonne s'intègre correctement avec le tableau des ZIPs existant.

**Étapes** :

1. Se connecter avec un compte Solution Engineer
2. Accéder à la page produit DisneyStore
3. Naviguer vers l'onglet ZIP
4. Vérifier que toutes les colonnes existantes fonctionnent toujours
5. Vérifier que la nouvelle colonne ne perturbe pas les fonctionnalités existantes

**Données de test** :

```
Tableau existant :
- Colonnes : [toutes les colonnes existantes]
- Fonctionnalités : Tri, filtrage, pagination, etc.
```

**Résultat attendu** :

- ✅ Toutes les colonnes existantes fonctionnent toujours
- ✅ Les fonctionnalités du tableau (tri, filtrage, etc.) ne sont pas impactées
- ✅ La nouvelle colonne s'intègre harmonieusement
- ✅ Aucune régression fonctionnelle

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### 🌐 CAS DE COMPATIBILITÉ

### Scénario 18 : Compatibilité navigateurs - Chrome

**Objectif** : Vérifier le fonctionnement de la colonne sur Chrome.

**Étapes** :

1. Ouvrir Chrome (version 120+)
2. Se connecter avec un compte Solution Engineer
3. Accéder à la page produit DisneyStore
4. Naviguer vers l'onglet ZIP
5. Tester l'affichage et le fonctionnement de la colonne

**Données de test** :

```
Navigateur: Chrome 120+
Version: [version exacte]
```

**Résultat attendu** :

- ✅ La colonne s'affiche correctement
- ✅ Les cases à cocher sont fonctionnelles
- ✅ Aucune régression visuelle
- ✅ Toutes les fonctionnalités sont accessibles

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 19 : Compatibilité navigateurs - Firefox

**Objectif** : Vérifier le fonctionnement de la colonne sur Firefox.

**Étapes** :

1. Ouvrir Firefox (version 115+)
2. Se connecter avec un compte Solution Engineer
3. Accéder à la page produit DisneyStore
4. Naviguer vers l'onglet ZIP
5. Tester l'affichage et le fonctionnement de la colonne

**Données de test** :

```
Navigateur: Firefox 115+
Version: [version exacte]
```

**Résultat attendu** :

- ✅ La colonne s'affiche correctement
- ✅ Les cases à cocher sont fonctionnelles
- ✅ Aucune régression visuelle
- ✅ Toutes les fonctionnalités sont accessibles

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### ♿ CAS D'ACCESSIBILITÉ

### Scénario 20 : Navigation au clavier

**Objectif** : Vérifier que les cases à cocher sont accessibles au clavier.

**Étapes** :

1. Se connecter avec un compte Solution Engineer
2. Accéder à la page produit DisneyStore
3. Naviguer vers l'onglet ZIP
4. Naviguer uniquement avec Tab pour atteindre les cases à cocher
5. Activer une case avec Espace
6. Vérifier le fonctionnement

**Données de test** :

```
Navigation clavier :
- Touches: Tab, Espace
- Lecteur d'écran: [si applicable]
```

**Résultat attendu** :

- ✅ Toutes les cases à cocher sont accessibles au clavier (Tab)
- ✅ Les cases peuvent être activées avec Espace
- ✅ Le focus est visible sur toutes les cases
- ✅ L'ordre de tabulation est logique

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 21 : Compatibilité lecteur d'écran

**Objectif** : Vérifier que les cases à cocher sont correctement annoncées par les lecteurs d'écran.

**Étapes** :

1. Activer un lecteur d'écran (NVDA, JAWS, VoiceOver)
2. Se connecter avec un compte Solution Engineer
3. Accéder à la page produit DisneyStore
4. Naviguer vers l'onglet ZIP
5. Naviguer jusqu'aux cases à cocher avec le lecteur d'écran
6. Vérifier l'annonce des cases

**Données de test** :

```
Lecteur d'écran :
- Outil: NVDA / JAWS / VoiceOver
- Version: [version]
```

**Résultat attendu** :

- ✅ Les cases à cocher sont correctement annoncées
- ✅ Le label "MCP Server" ou "MCP Compliant" est annoncé
- ✅ L'état (cochée/décochée) est annoncé
- ✅ L'interface est utilisable avec un lecteur d'écran

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

## 🐛 Bugs identifiés

[Aucun bug identifié pour le moment]

---

## 📊 Résumé des tests

- **Total de scénarios** : 21
  - Cas nominaux : 6
  - Cas limites : 3
  - Cas d'erreur : 3
  - Cas de sécurité/autorisations : 2
  - Cas de performance : 2
  - Cas d'intégration : 1
  - Cas de compatibilité : 2
  - Cas d'accessibilité : 2
- **Passés** : X (XX%)
- **Échoués** : X (XX%)
- **Bloqués** : X (XX%)
- **Couverture estimée** : 100% des critères d'acceptation

---

## 📝 Notes & Observations

- Attention à l'orthographe : "MCP Complaint" en base de données (pas "Compliant")
- Par défaut, tous les ZIPs sont en "NO" jusqu'à ce que la case soit cochée
- La colonne est dans l'onglet ZIP de la page produit DisneyStore
- Plusieurs tickets de test sont bloqués par cette US (TEST-12265 à TEST-12272)
- Le contexte mentionne que dans le futur, on aimerait mettre en avant les produits MCP Compliant

---

## ✍️ Validation

- **Testé par** : [Nom]
- **Date de test** : [AAAA-MM-JJ]
- **Validé par** : [Nom du responsable QA]
- **Date de validation** : [AAAA-MM-JJ]

