# Vérification remontées data dans HubSpot - Stratégie de Test

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

## 🎯 Objectif de la fonctionnalité

**Description** : 

Ce bug concerne la vérification et la correction des remontées de données dans HubSpot pour les propriétés MBO (Marketplace Back Office). Les valeurs remontées dans HubSpot sont très basses par rapport aux valeurs attendues (comparaison avec Mixpanel), et il y a des incohérences dans les données (même module ID dans plusieurs propriétés opposées).

Les problèmes identifiés incluent :
- Valeurs très basses dans les propriétés HubSpot par rapport aux valeurs attendues
- Modules ID présents dans plusieurs propriétés opposées simultanément (ex: installé et désinstallé le même jour)
- Propriété `mbo_id_s_module_s_configured` jamais connectée
- Données non fiables pour le targeting marketing

**Corrections apportées** :
- Correction de la fonction dans Segment pour supprimer les IDs de modules des propriétés opposées lors d'un événement
- Règles de suppression : à l'install, supprimer de "uninstalled", "upgraded", "activated", "deactivated" ; à l'uninstall, supprimer de "installed", "upgraded", "activated", "deactivated" ; etc.

**User Stories couvertes** :

- MME-545 : Vérification remontées data dans HubSpot

---

## ✅ Prérequis

### Environnement

- **OS** : Windows/Mac/Linux
- **Outils** : Accès à HubSpot, Segment, Mixpanel (pour comparaison)
- **Résolution min** : 1920x1080

### Données nécessaires

- [ ] Accès à HubSpot avec les propriétés MBO configurées
- [ ] Accès à Segment pour vérifier la fonction de correction
- [ ] Accès à Mixpanel pour comparaison des valeurs
- [ ] Comptes de test avec différents modules installés/désinstallés/upgradés
- [ ] Données de référence (valeurs attendues vs valeurs actuelles)
- [ ] Liste des modules de test (ex: 46347 - Checkout, 48896, etc.)

### Dépendances

- Segment fonctionnel avec la fonction corrigée
- API HubSpot accessible
- Données d'événements (install, uninstall, upgrade, activation, desactivation) disponibles

---

## 🎯 Objectif principal

Valider que les corrections apportées dans Segment fonctionnent correctement : suppression des IDs de modules des propriétés opposées lors d'un événement, cohérence des données remontées dans HubSpot, et fiabilité des données pour le targeting marketing.

---

## 📊 Axes de test et points de vigilance

### 1. Scénarios nominaux

**Objectif** : Vérification du comportement standard après les corrections.

**Approche** :
- Tester la suppression des IDs opposés lors d'un événement install
- Tester la suppression des IDs opposés lors d'un événement uninstall
- Tester la suppression des IDs opposés lors d'un événement upgrade
- Tester la suppression des IDs opposés lors d'un événement activation
- Tester la suppression des IDs opposés lors d'un événement desactivation
- Vérifier la cohérence des données dans HubSpot après chaque événement

**Points de vigilance** :
- S'assurer que les IDs sont correctement supprimés des propriétés opposées
- Vérifier que les IDs sont correctement ajoutés à la propriété correspondante
- Valider que les données dans HubSpot sont cohérentes après chaque événement

---

### 2. Cas limites et robustesse

**Objectif** : Tester les cas limites et les situations particulières.

**Approche** :
- Tester avec des modules désactivés sur la marketplace
- Tester avec des modules introuvables sur la marketplace
- Tester avec des modules payants sans deal associé
- Tester avec des utilisateurs non connectés
- Tester avec des événements multiples le même jour
- Tester avec des modules ayant plusieurs versions

**Points de vigilance** :
- Vérifier que le comportement est cohérent dans tous les cas limites
- S'assurer qu'il n'y a pas de conflits lors d'événements multiples
- Valider que les données restent cohérentes même dans les cas limites

---

### 3. Gestion des erreurs

**Objectif** : Validation de la gestion des erreurs et des cas d'échec.

**Approche** :
- Tester le comportement en cas d'erreur API HubSpot
- Tester le comportement en cas de timeout
- Tester le comportement avec des données invalides
- Tester le comportement si Segment est indisponible

**Points de vigilance** :
- S'assurer que les erreurs ne cassent pas le système
- Vérifier que les erreurs sont loggées correctement
- Valider que le système peut récupérer après une erreur

---

### 4. Sécurité et autorisations

**Objectif** : Vérifier que les contrôles d'accès sont correctement implémentés.

**Approche** :
- Tester l'authentification avec HubSpot
- Vérifier que seuls les événements autorisés sont envoyés
- Tester la validation des données avant l'envoi
- Vérifier qu'il n'y a pas de fuite d'informations

**Points de vigilance** :
- Valider que l'authentification est sécurisée
- Vérifier que les données sont validées avant l'envoi
- S'assurer qu'il n'y a pas d'exposition de données sensibles

---

### 5. Performance

**Objectif** : S'assurer que les corrections n'impactent pas les performances.

**Approche** :
- Mesurer le temps de traitement des événements
- Tester le temps de réponse de l'API HubSpot
- Vérifier l'impact sur les requêtes Segment
- Tester avec un volume élevé d'événements

**Points de vigilance** :
- Temps de traitement acceptable (< 5 secondes par événement)
- Temps de réponse API acceptable (< 2 secondes)
- Pas de dégradation des performances avec un volume élevé

---

### 6. Intégration

**Objectif** : Valider les interactions avec HubSpot et Segment.

**Approche** :
- Tester l'envoi des données à HubSpot
- Vérifier la réception des données dans HubSpot
- Tester la synchronisation après modification
- Valider l'intégration avec Segment

**Points de vigilance** :
- Vérifier que les données sont correctement envoyées
- S'assurer que la réception dans HubSpot est correcte
- Valider que la synchronisation est fiable

---

### 7. Compatibilité

**Objectif** : S'assurer que les corrections fonctionnent avec différentes configurations.

**Approche** :
- Tester avec différents types de modules (gratuits, payants, désactivés)
- Tester avec différents types d'utilisateurs (connectés, non connectés)
- Vérifier la compatibilité avec différentes versions de Segment

**Points de vigilance** :
- Aucune régression avec les différents types de modules
- Le comportement est cohérent pour tous les types d'utilisateurs
- La compatibilité avec Segment est maintenue

---

### 8. Données et cohérence

**Objectif** : Valider la cohérence et la fiabilité des données remontées.

**Approche** :
- Comparer les valeurs HubSpot avec les valeurs Mixpanel
- Vérifier qu'il n'y a plus de modules ID dans plusieurs propriétés opposées
- Tester la résolution des conflits de données existants
- Valider que les données sont fiables pour le targeting

**Points de vigilance** :
- Les valeurs HubSpot sont cohérentes avec Mixpanel (à marge près)
- Aucun module ID n'est présent dans plusieurs propriétés opposées simultanément
- Les conflits de données existants sont résolus lors des prochains événements
- Les données sont fiables pour le targeting marketing

---

## ⚠️ Impacts et non-régression

**Zones à risque identifiées** :

Une attention particulière sera portée sur les éléments suivants pour s'assurer qu'ils ne sont pas affectés :

1. **Autres propriétés HubSpot**
   - **Pourquoi** : Les corrections ne doivent pas impacter les autres propriétés HubSpot
   - **Tests de régression** : Vérifier que toutes les autres propriétés HubSpot fonctionnent toujours normalement

2. **Système Segment**
   - **Pourquoi** : Les corrections ne doivent pas impacter les autres fonctions Segment
   - **Tests de régression** : Tester que toutes les autres fonctions Segment fonctionnent toujours

3. **Données existantes**
   - **Pourquoi** : Les corrections ne doivent pas corrompre les données existantes valides
   - **Tests de régression** : Vérifier que les données existantes valides ne sont pas affectées

**Fonctionnalités connexes à vérifier** :

- [ ] Les autres propriétés HubSpot fonctionnent correctement
- [ ] Les autres fonctions Segment ne sont pas impactées
- [ ] Les données existantes valides ne sont pas corrompues
- [ ] Performance acceptable (< 5 secondes par événement)
- [ ] Aucune régression identifiée

---

## 📈 Métriques et critères de succès

### Critères de validation

- ✅ Les IDs de modules sont correctement supprimés des propriétés opposées lors d'un événement
- ✅ Les données dans HubSpot sont cohérentes (pas de modules ID dans plusieurs propriétés opposées)
- ✅ Les valeurs HubSpot sont cohérentes avec Mixpanel (à marge près)
- ✅ Les données sont fiables pour le targeting marketing
- ✅ Aucune régression identifiée
- ✅ Performance acceptable (< 5 secondes par événement)
- ✅ Couverture estimée : 100% des règles de suppression des IDs opposés

### Métriques de test

- **Nombre total de scénarios** : 20-25
- **Nombre de scénarios critiques** : 5 (un par type d'événement)
- **Temps estimé de test** : 8-10 heures
- **Environnements de test** : Staging, Preprod, Production (surveillance)

---

## 🔍 Tests de régression

**Stratégie** : 

Tester les fonctionnalités critiques de Segment et HubSpot pour s'assurer qu'elles ne sont pas impactées par les corrections.

**Checklist de régression** :

- [ ] Segment - Vérifier que toutes les autres fonctions fonctionnent
- [ ] HubSpot - Tester que toutes les autres propriétés fonctionnent toujours
- [ ] Données existantes - Vérifier que les données existantes valides ne sont pas affectées

---

## 📝 Notes & Observations

- Les corrections ont été apportées sur Segment en début décembre 2024
- Les données existantes ne peuvent pas être corrigées si l'événement ne concerne pas le module
- Seuls les événements avec un utilisateur loggué peuvent être bien remontés sur HubSpot
- La propriété `mbo_id_s_module_s_configured` n'a jamais été connectée et nécessite une revue des besoins spécifiques
- Page Notion de référence : https://www.notion.so/prestashopcorp/MBO-Hubspot-5dc55b8e8a6e482380692fa782044c22

---

## 🔗 Documents associés

- **Questions et Clarifications** : [01-questions-clarifications.md]
- **Cas de test** : [03-cas-test.md]
- **User Story** : https://forge.prestashop.com/browse/MME-545

---

## ✍️ Validation

- **Rédigé par** : [Nom]
- **Date de rédaction** : 2025-11-18
- **Validé par** : [Nom du responsable QA]
- **Date de validation** : [AAAA-MM-JJ]

