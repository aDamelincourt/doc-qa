# Vérification remontées data dans HubSpot - Cas de Test

## 📋 Informations générales

- **Feature** : Vérification et correction des remontées de données dans HubSpot pour les propriétés MBO
- **User Story** : MME-545 : Vérification remontées data dans HubSpot
- **Type** : Bug
- **Sprint/Version** : [À compléter]
- **Date de création** : 2025-11-18
- **Auteur** : [Nom du QA]
- **Statut** : Draft
- **Lien Jira/Ticket** : https://forge.prestashop.com/browse/MME-545

---

## 🔗 Documents associés

- **Stratégie de test** : [02-strategie-test.md]
- **Questions et Clarifications** : [01-questions-clarifications.md]

---

## 🧪 Scénarios de test

### 📌 CAS NOMINAUX

### Scénario 1 : Suppression des IDs opposés - Événement Install

**Objectif** : Vérifier que lors d'un événement "Install", l'ID du module est supprimé des propriétés opposées (uninstalled, upgraded, activated, deactivated) et ajouté à la propriété "installed".

**Étapes** :

1. Préparer un contact HubSpot avec un module ID dans les propriétés "uninstalled", "upgraded", "activated", "deactivated"
2. Déclencher un événement "Install" pour ce module
3. Vérifier dans Segment que la fonction supprime l'ID des propriétés opposées
4. Vérifier dans HubSpot que l'ID est supprimé des propriétés opposées
5. Vérifier dans HubSpot que l'ID est ajouté à la propriété "installed"

**Données de test** :

```
Contact de test :
- Email : test-install@example.com
- Module ID : 46347 (Checkout)
- Propriétés initiales :
  - mbo_id_s_module_s_uninstalled : [46347]
  - mbo_id_s_module_s_upgraded : [46347]
  - mbo_id_s_module_s_activation : [46347]
  - mbo_id_s_module_s_desactivated : [46347]
- Action : Install du module 46347
```

**Résultat attendu** :

- ✅ L'ID 46347 est supprimé de "uninstalled", "upgraded", "activation", "desactivated"
- ✅ L'ID 46347 est ajouté à "installed"
- ✅ Les données dans HubSpot sont cohérentes
- ✅ Aucune erreur dans Segment ou HubSpot

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 2 : Suppression des IDs opposés - Événement Uninstall

**Objectif** : Vérifier que lors d'un événement "Uninstall", l'ID du module est supprimé des propriétés opposées (installed, upgraded, activated, deactivated) et ajouté à la propriété "uninstalled".

**Étapes** :

1. Préparer un contact HubSpot avec un module ID dans les propriétés "installed", "upgraded", "activated", "deactivated"
2. Déclencher un événement "Uninstall" pour ce module
3. Vérifier dans Segment que la fonction supprime l'ID des propriétés opposées
4. Vérifier dans HubSpot que l'ID est supprimé des propriétés opposées
5. Vérifier dans HubSpot que l'ID est ajouté à la propriété "uninstalled"

**Données de test** :

```
Contact de test :
- Email : test-uninstall@example.com
- Module ID : 46347 (Checkout)
- Propriétés initiales :
  - mbo_id_s_module_s_installed : [46347]
  - mbo_id_s_module_s_upgraded : [46347]
  - mbo_id_s_module_s_activation : [46347]
  - mbo_id_s_module_s_desactivated : [46347]
- Action : Uninstall du module 46347
```

**Résultat attendu** :

- ✅ L'ID 46347 est supprimé de "installed", "upgraded", "activation", "desactivated"
- ✅ L'ID 46347 est ajouté à "uninstalled"
- ✅ Les données dans HubSpot sont cohérentes
- ✅ Aucune erreur dans Segment ou HubSpot

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 3 : Suppression des IDs opposés - Événement Upgrade

**Objectif** : Vérifier que lors d'un événement "Upgrade", l'ID du module est supprimé des propriétés opposées (installed, uninstalled, activated, deactivated) et ajouté à la propriété "upgraded".

**Étapes** :

1. Préparer un contact HubSpot avec un module ID dans les propriétés "installed", "uninstalled", "activated", "deactivated"
2. Déclencher un événement "Upgrade" pour ce module
3. Vérifier dans Segment que la fonction supprime l'ID des propriétés opposées
4. Vérifier dans HubSpot que l'ID est supprimé des propriétés opposées
5. Vérifier dans HubSpot que l'ID est ajouté à la propriété "upgraded"

**Données de test** :

```
Contact de test :
- Email : test-upgrade@example.com
- Module ID : 48896
- Propriétés initiales :
  - mbo_id_s_module_s_installed : [48896]
  - mbo_id_s_module_s_uninstalled : [48896]
  - mbo_id_s_module_s_activation : [48896]
  - mbo_id_s_module_s_desactivated : [48896]
- Action : Upgrade du module 48896
```

**Résultat attendu** :

- ✅ L'ID 48896 est supprimé de "installed", "uninstalled", "activation", "desactivated"
- ✅ L'ID 48896 est ajouté à "upgraded"
- ✅ Les données dans HubSpot sont cohérentes
- ✅ Aucune erreur dans Segment ou HubSpot

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 4 : Suppression des IDs opposés - Événement Activation

**Objectif** : Vérifier que lors d'un événement "Activation", l'ID du module est supprimé des propriétés opposées (installed, uninstalled, upgraded, deactivated) et ajouté à la propriété "activation".

**Étapes** :

1. Préparer un contact HubSpot avec un module ID dans les propriétés "installed", "uninstalled", "upgraded", "deactivated"
2. Déclencher un événement "Activation" pour ce module
3. Vérifier dans Segment que la fonction supprime l'ID des propriétés opposées
4. Vérifier dans HubSpot que l'ID est supprimé des propriétés opposées
5. Vérifier dans HubSpot que l'ID est ajouté à la propriété "activation"

**Données de test** :

```
Contact de test :
- Email : test-activation@example.com
- Module ID : 23864
- Propriétés initiales :
  - mbo_id_s_module_s_installed : [23864]
  - mbo_id_s_module_s_uninstalled : [23864]
  - mbo_id_s_module_s_upgraded : [23864]
  - mbo_id_s_module_s_desactivated : [23864]
- Action : Activation du module 23864
```

**Résultat attendu** :

- ✅ L'ID 23864 est supprimé de "installed", "uninstalled", "upgraded", "desactivated"
- ✅ L'ID 23864 est ajouté à "activation"
- ✅ Les données dans HubSpot sont cohérentes
- ✅ Aucune erreur dans Segment ou HubSpot

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 5 : Suppression des IDs opposés - Événement Desactivation

**Objectif** : Vérifier que lors d'un événement "Desactivation", l'ID du module est supprimé des propriétés opposées (installed, uninstalled, upgraded, activated) et ajouté à la propriété "desactivated".

**Étapes** :

1. Préparer un contact HubSpot avec un module ID dans les propriétés "installed", "uninstalled", "upgraded", "activated"
2. Déclencher un événement "Desactivation" pour ce module
3. Vérifier dans Segment que la fonction supprime l'ID des propriétés opposées
4. Vérifier dans HubSpot que l'ID est supprimé des propriétés opposées
5. Vérifier dans HubSpot que l'ID est ajouté à la propriété "desactivated"

**Données de test** :

```
Contact de test :
- Email : test-desactivation@example.com
- Module ID : 23864
- Propriétés initiales :
  - mbo_id_s_module_s_installed : [23864]
  - mbo_id_s_module_s_uninstalled : [23864]
  - mbo_id_s_module_s_upgraded : [23864]
  - mbo_id_s_module_s_activation : [23864]
- Action : Desactivation du module 23864
```

**Résultat attendu** :

- ✅ L'ID 23864 est supprimé de "installed", "uninstalled", "upgraded", "activation"
- ✅ L'ID 23864 est ajouté à "desactivated"
- ✅ Les données dans HubSpot sont cohérentes
- ✅ Aucune erreur dans Segment ou HubSpot

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 6 : Cohérence des données - Pas de module ID dans plusieurs propriétés opposées

**Objectif** : Vérifier qu'après les corrections, un module ID ne peut plus être présent dans plusieurs propriétés opposées simultanément.

**Étapes** :

1. Créer un contact de test avec un module ID dans plusieurs propriétés opposées (ex: installed et uninstalled)
2. Déclencher un événement pour ce module (ex: Install)
3. Vérifier dans HubSpot que l'ID n'est présent que dans la propriété correspondante
4. Vérifier qu'il n'y a plus de conflit

**Données de test** :

```
Contact de test :
- Email : test-coherence@example.com
- Module ID : 46347 (Checkout)
- Propriétés initiales (conflit) :
  - mbo_id_s_module_s_installed : [46347]
  - mbo_id_s_module_s_uninstalled : [46347]
- Action : Install du module 46347
```

**Résultat attendu** :

- ✅ L'ID 46347 n'est plus dans "uninstalled"
- ✅ L'ID 46347 est uniquement dans "installed"
- ✅ Aucun conflit de données
- ✅ Les données sont cohérentes

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### 🔢 CAS LIMITES

### Scénario 7 : Module désactivé sur la marketplace

**Objectif** : Vérifier le comportement avec un module désactivé sur la marketplace.

**Étapes** :

1. Identifier un module désactivé sur la marketplace (ex: 4178, 50756)
2. Déclencher un événement pour ce module (ex: Install)
3. Vérifier dans HubSpot que l'ID est correctement géré malgré le statut désactivé

**Données de test** :

```
Module désactivé :
- Module ID : 4178 (ou 50756)
- Statut marketplace : Désactivé
- Action : Install du module
```

**Résultat attendu** :

- ✅ L'ID est correctement géré dans HubSpot
- ✅ Les règles de suppression des IDs opposés fonctionnent
- ✅ Aucune erreur liée au statut désactivé

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 8 : Module payant sans deal associé

**Objectif** : Vérifier le comportement avec un module payant installé sans deal associé.

**Étapes** :

1. Identifier un contact avec un module payant installé sans deal (ex: info@cartadaparati.it avec module 44392)
2. Vérifier dans HubSpot que l'ID est présent dans "installed"
3. Déclencher un événement pour ce module (ex: Uninstall)
4. Vérifier que les règles de suppression fonctionnent

**Données de test** :

```
Contact de test :
- Email : info@cartadaparati.it (ou équivalent)
- Module ID : 44392 (module payant)
- Deal associé : Aucun
- Action : Uninstall du module
```

**Résultat attendu** :

- ✅ L'ID est correctement géré dans HubSpot
- ✅ Les règles de suppression des IDs opposés fonctionnent
- ✅ Aucune erreur liée à l'absence de deal

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 9 : Utilisateur non connecté

**Objectif** : Vérifier le comportement avec un événement déclenché par un utilisateur non connecté.

**Étapes** :

1. Déclencher un événement (ex: Install) avec un utilisateur non connecté
2. Vérifier dans Segment si l'événement est traité
3. Vérifier dans HubSpot si les données sont remontées

**Données de test** :

```
Événement :
- Utilisateur : Non connecté
- Module ID : 46347
- Action : Install du module
```

**Résultat attendu** :

- ✅ L'événement est traité ou ignoré selon les règles
- ✅ Si traité, les règles de suppression fonctionnent
- ✅ Si ignoré, aucun impact sur HubSpot

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 10 : Événements multiples le même jour

**Objectif** : Vérifier le comportement avec plusieurs événements pour le même module le même jour.

**Étapes** :

1. Déclencher plusieurs événements pour le même module le même jour (ex: Install, puis Uninstall, puis Install)
2. Vérifier dans HubSpot que les données sont cohérentes après chaque événement
3. Vérifier qu'il n'y a pas de conflit

**Données de test** :

```
Événements multiples :
- Module ID : 46347
- Jour : 2025-11-18
- Actions : Install → Uninstall → Install
```

**Résultat attendu** :

- ✅ Les données sont cohérentes après chaque événement
- ✅ Les règles de suppression fonctionnent à chaque fois
- ✅ Aucun conflit de données
- ✅ L'état final est correct (installed)

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### ❌ CAS D'ERREUR

### Scénario 11 : Erreur API HubSpot - Timeout

**Objectif** : Vérifier le comportement en cas de timeout de l'API HubSpot.

**Étapes** :

1. Simuler un timeout de l'API HubSpot
2. Déclencher un événement (ex: Install)
3. Vérifier le comportement de Segment
4. Vérifier si l'événement est retraité après résolution du timeout

**Données de test** :

```
API HubSpot :
- Timeout : > 30 secondes (timeout configuré)
- Action : Install du module 46347
```

**Résultat attendu** :

- ✅ L'erreur est loggée correctement
- ✅ L'événement est retraité après résolution du timeout
- ✅ Les données sont finalement correctes dans HubSpot
- ✅ Aucune perte de données

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 12 : Erreur API HubSpot - Données invalides

**Objectif** : Vérifier le comportement avec des données invalides envoyées à HubSpot.

**Étapes** :

1. Tenter d'envoyer des données invalides à HubSpot (ex: ID de module invalide, format incorrect)
2. Vérifier le comportement de Segment
3. Vérifier si l'erreur est gérée correctement

**Données de test** :

```
Données invalides :
- Module ID : "invalid" (au lieu d'un nombre)
- Format : Format incorrect
```

**Résultat attendu** :

- ✅ L'erreur est détectée et loggée
- ✅ Les données invalides ne sont pas envoyées à HubSpot
- ✅ Aucune corruption des données existantes
- ✅ Un message d'erreur approprié est retourné

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 13 : Segment indisponible

**Objectif** : Vérifier le comportement si Segment est indisponible.

**Étapes** :

1. Simuler l'indisponibilité de Segment
2. Déclencher un événement (ex: Install)
3. Vérifier le comportement du système
4. Vérifier si l'événement est traité après récupération de Segment

**Données de test** :

```
Segment :
- Statut : Indisponible
- Action : Install du module 46347
```

**Résultat attendu** :

- ✅ L'événement est mis en file d'attente ou ignoré
- ✅ L'événement est traité après récupération de Segment
- ✅ Aucune perte de données
- ✅ Les données sont finalement correctes dans HubSpot

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### 🔒 CAS DE SÉCURITÉ ET AUTORISATIONS

### Scénario 14 : Authentification HubSpot

**Objectif** : Vérifier que l'authentification avec HubSpot est sécurisée.

**Étapes** :

1. Vérifier le mécanisme d'authentification (API key, OAuth, etc.)
2. Tenter d'accéder à l'API HubSpot sans authentification
3. Vérifier que l'accès est refusé

**Données de test** :

```
Authentification :
- Mécanisme : [API key / OAuth / etc.]
- Tentative sans auth : Requête sans credentials
```

**Résultat attendu** :

- ✅ L'authentification est requise
- ✅ L'accès sans authentification est refusé
- ✅ Les credentials sont sécurisés (pas exposés)

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 15 : Validation des données

**Objectif** : Vérifier que les données sont validées avant l'envoi à HubSpot.

**Étapes** :

1. Tenter d'envoyer des données invalides (ex: ID de module négatif, format incorrect)
2. Vérifier que la validation rejette les données invalides
3. Vérifier que seules les données valides sont envoyées

**Données de test** :

```
Données invalides :
- Module ID : -1, 0, "abc", null
- Format : Format incorrect
```

**Résultat attendu** :

- ✅ Les données invalides sont rejetées
- ✅ Seules les données valides sont envoyées à HubSpot
- ✅ Les erreurs de validation sont loggées

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### ⚡ CAS DE PERFORMANCE

### Scénario 16 : Temps de traitement d'un événement

**Objectif** : Vérifier que le temps de traitement d'un événement est acceptable.

**Étapes** :

1. Déclencher un événement (ex: Install)
2. Mesurer le temps entre l'événement et la mise à jour dans HubSpot
3. Vérifier que le temps est acceptable (< 5 secondes)

**Données de test** :

```
Métriques :
- Temps de traitement attendu : < 5 secondes
- Événement : Install du module 46347
```

**Résultat attendu** :

- ✅ Le temps de traitement est acceptable (< 5 secondes)
- ✅ La mise à jour dans HubSpot est rapide
- ✅ Aucune dégradation de performance

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 17 : Volume élevé d'événements

**Objectif** : Vérifier le comportement avec un volume élevé d'événements.

**Étapes** :

1. Déclencher un volume élevé d'événements (ex: 100 événements en 1 minute)
2. Vérifier que tous les événements sont traités
3. Vérifier que les performances restent acceptables
4. Vérifier que les données dans HubSpot sont correctes

**Données de test** :

```
Volume élevé :
- Nombre d'événements : 100
- Période : 1 minute
- Types : Install, Uninstall, Upgrade, Activation, Desactivation
```

**Résultat attendu** :

- ✅ Tous les événements sont traités
- ✅ Les performances restent acceptables
- ✅ Les données dans HubSpot sont correctes
- ✅ Aucune perte de données

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### 🔄 CAS D'INTÉGRATION

### Scénario 18 : Intégration Segment - HubSpot

**Objectif** : Vérifier que l'intégration entre Segment et HubSpot fonctionne correctement.

**Étapes** :

1. Déclencher un événement (ex: Install)
2. Vérifier dans Segment que l'événement est traité
3. Vérifier dans HubSpot que les données sont correctement mises à jour
4. Vérifier la cohérence entre Segment et HubSpot

**Données de test** :

```
Intégration :
- Événement : Install du module 46347
- Vérification Segment : Fonction de suppression appelée
- Vérification HubSpot : Données mises à jour
```

**Résultat attendu** :

- ✅ L'intégration fonctionne correctement
- ✅ Les données sont synchronisées entre Segment et HubSpot
- ✅ Aucune perte de données
- ✅ La cohérence est maintenue

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### 📊 CAS DE DONNÉES ET COHÉRENCE

### Scénario 19 : Comparaison HubSpot - Mixpanel

**Objectif** : Vérifier que les valeurs HubSpot sont cohérentes avec Mixpanel (à marge près).

**Étapes** :

1. Extraire les valeurs HubSpot pour une période donnée (ex: 01/01-28/08)
2. Extraire les valeurs Mixpanel pour la même période
3. Comparer les valeurs (à marge près)
4. Vérifier que les écarts sont acceptables

**Données de test** :

```
Comparaison :
- Période : 01/01-28/08
- Propriétés : installed, uninstalled, upgraded, activation, desactivated
- Valeurs Mixpanel de référence :
  - Install : ~3175 tracks/mois
  - Uninstall : ~250 tracks/mois
  - Upgrade : ~460 tracks/mois
```

**Résultat attendu** :

- ✅ Les valeurs HubSpot sont cohérentes avec Mixpanel (à marge près)
- ✅ Les écarts sont acceptables (différence due aux utilisateurs non connectés)
- ✅ Les tendances sont similaires

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 20 : Résolution des conflits de données existants

**Objectif** : Vérifier que les conflits de données existants sont résolus lors des prochains événements.

**Étapes** :

1. Identifier un contact avec un conflit de données (ex: module ID dans installed et uninstalled)
2. Déclencher un événement pour ce module (ex: Install)
3. Vérifier que le conflit est résolu
4. Vérifier que les données sont cohérentes

**Données de test** :

```
Conflit existant :
- Contact : contact@rawmotorsports.net (ou équivalent)
- Module ID : 46347 (Checkout)
- Conflit : Présent dans installed, uninstalled, upgraded
- Action : Install du module 46347
```

**Résultat attendu** :

- ✅ Le conflit est résolu
- ✅ L'ID est uniquement dans "installed"
- ✅ Les données sont cohérentes
- ✅ Aucun nouveau conflit n'est créé

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

### Scénario 21 : Fiabilité des données pour le targeting

**Objectif** : Vérifier que les données sont fiables pour le targeting marketing.

**Étapes** :

1. Créer un segment HubSpot basé sur les propriétés MBO (ex: contacts avec module 46347 installé)
2. Vérifier que le segment contient uniquement les contacts concernés
3. Vérifier qu'il n'y a pas de faux positifs ou de faux négatifs
4. Tester l'utilisation du segment pour un targeting

**Données de test** :

```
Targeting :
- Segment : Contacts avec module 46347 installé
- Vérification : Cohérence des contacts dans le segment
```

**Résultat attendu** :

- ✅ Le segment contient uniquement les contacts concernés
- ✅ Aucun faux positif ou faux négatif
- ✅ Les données sont fiables pour le targeting
- ✅ Le targeting fonctionne correctement

**Résultat obtenu** : [À compléter lors du test]

**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué

---

## 🐛 Bugs identifiés

[Aucun bug identifié pour le moment]

---

## 📊 Résumé des tests

- **Total de scénarios** : 21
  - Cas nominaux : 6
  - Cas limites : 4
  - Cas d'erreur : 3
  - Cas de sécurité/autorisations : 2
  - Cas de performance : 2
  - Cas d'intégration : 1
  - Cas de données et cohérence : 3
- **Passés** : X (XX%)
- **Échoués** : X (XX%)
- **Bloqués** : X (XX%)
- **Couverture estimée** : 100% des règles de suppression des IDs opposés

---

## 📝 Notes & Observations

- Les corrections ont été apportées sur Segment en début décembre 2024
- Les données existantes ne peuvent pas être corrigées si l'événement ne concerne pas le module
- Seuls les événements avec un utilisateur loggué peuvent être bien remontés sur HubSpot
- La propriété `mbo_id_s_module_s_configured` n'a jamais été connectée et nécessite une revue des besoins spécifiques
- Page Notion de référence : https://www.notion.so/prestashopcorp/MBO-Hubspot-5dc55b8e8a6e482380692fa782044c22
- Exemples de modules de test : 46347 (Checkout), 48896, 23864, 44392, 4178, 50756

---

## ✍️ Validation

- **Testé par** : [Nom]
- **Date de test** : [AAAA-MM-JJ]
- **Validé par** : [Nom du responsable QA]
- **Date de validation** : [AAAA-MM-JJ]

