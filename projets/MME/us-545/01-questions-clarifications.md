# Vérification remontées data dans HubSpot - Questions et Clarifications

## 📋 Informations générales

- **Feature** : Vérification et correction des remontées de données dans HubSpot pour les propriétés MBO
- **User Story** : MME-545 : Vérification remontées data dans HubSpot
- **Type** : Bug
- **Sprint/Version** : [À compléter]
- **Date de création** : 2025-11-18
- **Auteur** : [Nom du QA]
- **Statut** : À valider

---

## 🗣️ Pour le Product Manager (PM)

### Règles métier et critères d'acceptation

1. **Propriétés HubSpot concernées** : Quelles sont exactement les 6 propriétés HubSpot MBO qui doivent être vérifiées et corrigées ? Le ticket mentionne :
   - `mbo_id_s_module_s_installed`
   - `mbo_id_s_module_s_uninstalled`
   - `mbo_id_s_module_s_upgraded`
   - `mbo_id_s_module_s_activation`
   - `mbo_id_s_module_s_desactivated`
   - `mbo_id_s_module_s_configured`
   - **Contexte** : Il faut confirmer que toutes ces propriétés sont concernées par le bug et la correction.
   - **Réponse** : [À compléter par le PM]

2. **Valeurs attendues** : Quelles sont les valeurs attendues pour chaque propriété ? Le ticket mentionne que les valeurs sont "très basses" mais quelles sont les valeurs de référence (ex: Mixpanel montre 3175 tracks/mois pour Install) ?
   - **Contexte** : Pour tester, il faut connaître les valeurs attendues vs les valeurs actuelles.
   - **Réponse** : [À compléter par le PM]

3. **Période de référence** : Le ticket mentionne des valeurs au 28 août. Quelle est la période de référence pour la vérification ? Les corrections doivent-elles être rétroactives ?
   - **Contexte** : Il faut comprendre si les corrections s'appliquent aux données historiques ou uniquement aux nouvelles données.
   - **Réponse** : [À compléter par le PM]

4. **Règle de suppression des IDs opposés** : Le ticket mentionne que lors d'un événement (install, uninstall, upgrade, activation, desactivation), l'ID du module doit être supprimé des propriétés opposées. Quelles sont les règles exactes ?
   - **Contexte** : Les commentaires mentionnent des règles spécifiques (ex: à l'install, supprimer de "uninstalled", "upgraded", "activated", "deactivated"). Il faut confirmer ces règles.
   - **Réponse** : [À compléter par le PM]

5. **Propriété "configured"** : Le ticket mentionne que `mbo_id_s_module_s_configured` n'a jamais été connectée. Est-ce que cette propriété doit être implémentée dans le cadre de ce bug ou est-ce un besoin séparé ?
   - **Contexte** : Il faut clarifier si cette propriété fait partie du scope de ce ticket.
   - **Réponse** : [À compléter par le PM]

6. **Utilisateurs non connectés** : Le ticket mentionne que seuls les événements avec un utilisateur loggué peuvent être bien remontés sur HubSpot. Est-ce un comportement attendu ou un bug à corriger ?
   - **Contexte** : Il faut comprendre si c'est une limitation acceptable ou un problème à résoudre.
   - **Réponse** : [À compléter par le PM]

7. **Données rétroactives** : Le ticket mentionne que les corrections ont été apportées sur Segment en début décembre. Les données existantes avant décembre doivent-elles être corrigées ou seulement les nouvelles données ?
   - **Contexte** : Il faut comprendre si une migration de données est nécessaire.
   - **Réponse** : [À compléter par le PM]

### Cas limites et comportements edge cases

8. **Modules désactivés sur marketplace** : Le ticket mentionne que certains modules peuvent être désactivés sur la marketplace (ex: support non assuré, déclinaison, changement de contrat). Comment ces modules doivent-ils être gérés dans les propriétés HubSpot ?
   - **Contexte** : Il faut comprendre si les modules désactivés doivent être retirés des propriétés ou conservés.
   - **Réponse** : [À compléter par le PM]

9. **Modules introuvables** : Le ticket mentionne des modules introuvables sur la marketplace (ex: 4178, 50756). Comment ces modules doivent-ils être gérés dans les propriétés HubSpot ?
   - **Contexte** : Il faut comprendre si ces modules doivent être retirés ou conservés avec un flag spécial.
   - **Réponse** : [À compléter par le PM]

10. **Modules payants sans deal** : Le ticket mentionne des cas où un module payant est installé sans deal associé. Comment ces cas doivent-ils être gérés ?
    - **Contexte** : Il faut comprendre si c'est un comportement attendu (ex: compte SSO, achat via autre compte) ou un bug.
    - **Réponse** : [À compléter par le PM]

11. **Conflits de données** : Le ticket montre des exemples où un même module ID se trouve dans plusieurs propriétés opposées en même temps (ex: installé et désinstallé le même jour). Comment ces conflits doivent-ils être résolus ?
    - **Contexte** : Il faut comprendre la logique de résolution des conflits (priorité temporelle, dernier événement, etc.).
    - **Réponse** : [À compléter par le PM]

12. **Mises à jour multiples le même jour** : Le ticket montre des exemples où l'API modifie plusieurs fois les valeurs le même jour. Est-ce un comportement attendu ou un bug ?
    - **Contexte** : Il faut comprendre si les mises à jour multiples sont normales ou doivent être évitées.
    - **Réponse** : [À compléter par le PM]

### Messages et notifications utilisateur

13. **Alertes de données incohérentes** : Y a-t-il un système d'alerte ou de notification lorsque des données incohérentes sont détectées ?
    - **Contexte** : Il faut comprendre si des alertes doivent être mises en place pour détecter les problèmes.
    - **Réponse** : [À compléter par le PM]

14. **Documentation Notion** : Le ticket mentionne une page Notion (https://www.notion.so/prestashopcorp/MBO-Hubspot-5dc55b8e8a6e482380692fa782044c22). Cette documentation est-elle à jour et complète ?
    - **Contexte** : Il faut vérifier que la documentation reflète les règles de gestion des propriétés.
    - **Réponse** : [À compléter par le PM]

---

## 💻 Pour les Développeur(se)s

### Architecture et implémentation technique

1. **Architecture Segment** : Quelle est l'architecture exacte de la fonction Segment qui gère les propriétés HubSpot ? Où se trouve le code source ?
   - **Contexte** : Pour tester, il faut comprendre l'architecture et l'emplacement du code.
   - **Réponse** : [À compléter par le développeur]

2. **Fonction de suppression des IDs opposés** : Le ticket mentionne qu'une fonction a été corrigée dans Segment pour supprimer les IDs de modules des propriétés opposées. Où se trouve cette fonction et comment fonctionne-t-elle exactement ?
   - **Contexte** : Il faut comprendre la logique de suppression pour tester correctement.
   - **Réponse** : [À compléter par le développeur]

3. **Format des données** : Quel est le format exact des données envoyées à HubSpot ? (JSON, format des IDs, structure des propriétés, etc.)
   - **Contexte** : Pour tester l'intégration, il faut connaître le format exact.
   - **Réponse** : [À compléter par le développeur]

### Contrats d'API et intégrations

4. **API HubSpot** : Quelle API HubSpot est utilisée pour mettre à jour les propriétés ? (REST API, GraphQL, etc.) Quel est l'endpoint exact ?
   - **Contexte** : Pour tester l'intégration, il faut connaître l'API utilisée.
   - **Réponse** : [À compléter par le développeur]

5. **Gestion des erreurs API** : Que se passe-t-il si l'appel API HubSpot échoue ? Y a-t-il un mécanisme de retry ? Les erreurs sont-elles loggées ?
   - **Contexte** : Il faut tester la robustesse de l'intégration.
   - **Réponse** : [À compléter par le développeur]

6. **Rate limiting** : Y a-t-il des limites de taux (rate limiting) sur les appels API HubSpot ? Comment sont-elles gérées ?
   - **Contexte** : Il faut tester les limites et la gestion des dépassements.
   - **Réponse** : [À compléter par le développeur]

7. **Synchronisation** : Y a-t-il un délai entre l'événement (install, uninstall, etc.) et la mise à jour dans HubSpot ? Y a-t-il un cache impliqué ?
   - **Contexte** : Pour tester la synchronisation, il faut comprendre le mécanisme exact.
   - **Réponse** : [À compléter par le développeur]

### Données et base de données

8. **Source de données** : D'où proviennent les données des événements (install, uninstall, upgrade, etc.) ? (Base de données, logs, événements en temps réel, etc.)
   - **Contexte** : Pour tester, il faut connaître la source des données.
   - **Réponse** : [À compléter par le développeur]

9. **Migration des données existantes** : Y a-t-il un script de migration pour corriger les données existantes dans HubSpot ? Si oui, comment fonctionne-t-il ?
   - **Contexte** : Le ticket mentionne que les données existantes ne peuvent pas être corrigées si l'événement ne concerne pas le module. Il faut comprendre les limitations.
   - **Réponse** : [À compléter par le développeur]

10. **Logs et audit** : Les modifications des propriétés HubSpot sont-elles loggées ? Y a-t-il un système d'audit pour tracer les changements ?
    - **Contexte** : Les logs sont importants pour déboguer les problèmes.
    - **Réponse** : [À compléter par le développeur]

### Sécurité et authentification

11. **Authentification HubSpot** : Comment l'authentification avec HubSpot est-elle gérée ? (API key, OAuth, etc.)
    - **Contexte** : Pour tester la sécurité, il faut connaître le mécanisme d'authentification.
    - **Réponse** : [À compléter par le développeur]

12. **Validation des données** : Y a-t-il une validation des données avant l'envoi à HubSpot ? (Format des IDs, valeurs autorisées, etc.)
    - **Contexte** : Il faut tester la validation des données.
    - **Réponse** : [À compléter par le développeur]

13. **Gestion des utilisateurs non connectés** : Le ticket mentionne que seuls les événements avec un utilisateur loggué peuvent être bien remontés. Comment cette limitation est-elle gérée techniquement ?
    - **Contexte** : Il faut comprendre si c'est une limitation technique ou une décision métier.
    - **Réponse** : [À compléter par le développeur]

---

## 🎨 Pour le/la Product Designer

### Comportement de l'interface utilisateur

1. **Interface de vérification** : Y a-t-il une interface utilisateur pour vérifier les données remontées dans HubSpot ou est-ce uniquement via l'API/export ?
    - **Contexte** : Pour tester, il faut connaître les outils disponibles.
    - **Réponse** : [À compléter par le designer]

2. **Visualisation des données** : Y a-t-il des dashboards ou des visualisations pour suivre les remontées de données ?
    - **Contexte** : Il faut comprendre comment les données sont visualisées.
    - **Réponse** : [À compléter par le designer]

---

## ✅ Validation des réponses

Une fois toutes les questions répondues :

- [ ] Toutes les questions ont reçu une réponse
- [ ] Les réponses sont suffisamment détaillées pour procéder aux tests
- [ ] Les réponses ont été validées par l'équipe
- [ ] Le document de stratégie de test peut être créé
- [ ] Le document de cas de test peut être créé

---

## 📝 Notes

- **Date de dernière mise à jour** : 2025-11-18
- **Dernière modification par** : [Nom]
- **Page Notion** : https://www.notion.so/prestashopcorp/MBO-Hubspot-5dc55b8e8a6e482380692fa782044c22
- **Corrections apportées** : Les corrections ont été apportées sur Segment en début décembre 2024
- **Propriété "configured"** : Cette propriété n'a jamais été connectée et nécessite une revue des besoins spécifiques

---

## 🔗 Documents associés

- **Stratégie de test** : [02-strategie-test.md]
- **Cas de test** : [03-cas-test.md]
- **User Story** : https://forge.prestashop.com/browse/MME-545

