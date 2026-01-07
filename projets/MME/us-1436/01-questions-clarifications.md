# Produit MCP Server Compliant - ajouter une coche sur les pages produits dans DS - Questions et Clarifications

## 📋 Informations générales

- **Feature** : Case à cocher "MCP Compliant" sur les pages produits DisneyStore
- **User Story** : MME-1436 : Produit MCP Server Compliant - ajouter une coche sur les pages produits dans DS
- **Sprint/Version** : [À compléter]
- **Date de création** : 2025-11-18
- **Auteur** : [Nom du QA]
- **Statut** : À valider

---

## 🗣️ Pour le Product Manager (PM)

### Règles métier et critères d'acceptation

1. **Wording exact de la colonne** : Quel est le wording exact de la colonne "MCP Server" ? Le ticket mentionne "MCP Compliant" dans le titre mais "MCP Server" dans la spécification. Quelle est la formulation finale ?
   - **Contexte** : Il y a une incohérence entre le titre ("MCP Compliant") et la spécification ("MCP Server"). Il faut clarifier le wording exact pour tester correctement.
   - **Réponse** : [À compléter par le PM]

2. **Processus de vérification** : Comment Agathe (Solution Engineer) vérifie-t-elle qu'un module est MCP Compliant ? Y a-t-il des critères précis ou une procédure documentée ?
   - **Contexte** : Le contexte mentionne que l'équipe Solution Engineer vérifie la présence de code "MCP Compliant" dans le zip. Il faut comprendre les critères exacts pour tester la fonctionnalité.
   - **Réponse** : [À compléter par le PM]

3. **Valeur par défaut pour les ZIPs existants** : Le CA2 mentionne que par défaut, tous les ZIPs sont en "NO". Cela s'applique-t-il aussi aux ZIPs existants qui n'ont jamais été flagués, ou uniquement aux nouveaux ZIPs ?
   - **Contexte** : Cette information est importante pour tester la migration des données existantes.
   - **Réponse** : [À compléter par le PM]

4. **Mise à jour permanente** : Le CA mentionne que "le produit sera enregistré en YES" après coche. Y a-t-il un mécanisme de validation ou la coche est-elle directement enregistrée ?
   - **Contexte** : Il faut comprendre si Agathe peut cocher directement ou s'il y a un processus de validation.
   - **Réponse** : [À compléter par le PM]

5. **Utilisation future du flag** : Le contexte mentionne que dans le futur, on aimerait mettre en avant les produits MCP Compliant (filtre, tag, category). Y a-t-il déjà des plans concrets pour cette utilisation ?
   - **Contexte** : Cette information peut influencer les tests et la stratégie de test.
   - **Réponse** : [À compléter par le PM]

6. **Règles de vérification du code** : Quels sont les critères exacts pour qu'un module soit considéré comme "MCP Compliant" ? Y a-t-il un pattern de code spécifique à rechercher dans le zip ?
   - **Contexte** : Pour tester, il faut comprendre comment identifier un module MCP Compliant.
   - **Réponse** : [À compléter par le PM]

7. **Gestion des versions multiples** : Si un produit a plusieurs versions de ZIP, chaque ZIP doit-il être flagué individuellement ou le flag s'applique-t-il au produit entier ?
   - **Contexte** : Le CA mentionne "chaque ligne de ZIP" mais il faut clarifier si c'est par ZIP ou par produit.
   - **Réponse** : [À compléter par le PM]

### Cas limites et comportements edge cases

8. **ZIPs sans code MCP** : Que se passe-t-il si un ZIP ne contient pas de code MCP mais qu'Agathe coche quand même la case par erreur ? Y a-t-il une validation automatique ?
   - **Contexte** : Il faut comprendre si la vérification est manuelle uniquement ou s'il y a une validation automatique.
   - **Réponse** : [À compléter par le PM]

9. **Décochage après enregistrement** : Si Agathe décoche une case après l'avoir cochée et enregistrée, le flag passe-t-il à "NO" en base de données ?
   - **Contexte** : Le CA3.b mentionne le décochage mais il faut clarifier le comportement exact.
   - **Réponse** : [À compléter par le PM]

10. **ZIPs migrés** : Le contexte mentionne "Ne pas oublier de vérifier comment on gère le nombre max de bénéfices pour migrer les informations". Y a-t-il une migration de données prévue pour les produits existants ?
    - **Contexte** : Il peut y avoir une migration de données à tester.
    - **Réponse** : [À compléter par le PM]

11. **Permissions** : Seule Agathe peut cocher la case ou d'autres utilisateurs ont-ils aussi accès ? Y a-t-il des rôles spécifiques requis ?
    - **Contexte** : Pour tester les permissions, il faut connaître les rôles autorisés.
    - **Réponse** : [À compléter par le PM]

### Messages et notifications utilisateur

12. **Feedback visuel** : Y a-t-il un feedback visuel lorsque la case est cochée/décochée ? (Animation, message de confirmation, etc.)
    - **Contexte** : Pour tester l'UX, il faut connaître les retours visuels.
    - **Réponse** : [À compléter par le PM]

13. **Message d'erreur** : Si l'enregistrement échoue, quel message d'erreur doit être affiché à Agathe ?
    - **Contexte** : Il faut tester la gestion d'erreur.
    - **Réponse** : [À compléter par le PM]

---

## 💻 Pour les Développeur(se)s

### Architecture et implémentation technique

1. **Structure de la base de données** : Quelle est la structure exacte de la nouvelle propriété "MCP Complaint" en base de données ? (Type de champ, table, contraintes, etc.)
   - **Contexte** : Pour tester la persistance, il faut connaître la structure exacte de la base de données.
   - **Réponse** : [À compléter par le développeur]

2. **Format de la propriété** : La propriété est stockée comme "YES/NO", "TRUE/FALSE", ou un autre format ? Quel est le type de données exact ?
   - **Contexte** : Le CA mentionne "YES/NO" mais la spécification mentionne aussi "TRUE/FALSE". Il faut clarifier.
   - **Réponse** : [À compléter par le développeur]

3. **Table cible** : Dans quelle table exacte est stockée la propriété "MCP Complaint" ? Est-ce dans la table des produits, des ZIPs, ou une table dédiée ?
   - **Contexte** : Pour tester la persistance, il faut connaître la table exacte.
   - **Réponse** : [À compléter par le développeur]

4. **API d'enregistrement** : Y a-t-il un endpoint API pour enregistrer le changement d'état de la case à cocher ? Quel est cet endpoint et sa structure ?
   - **Contexte** : Pour tester l'intégration, il faut connaître l'API utilisée.
   - **Réponse** : [À compléter par le développeur]

### Contrats d'API et intégrations

5. **Gestion des erreurs API** : Que se passe-t-il si l'appel API d'enregistrement échoue ? Y a-t-il un mécanisme de retry ?
   - **Contexte** : Il faut tester la robustesse de l'interface.
   - **Réponse** : [À compléter par le développeur]

6. **Synchronisation** : Y a-t-il un délai entre le clic sur la case et l'enregistrement en base de données ? Y a-t-il un cache impliqué ?
   - **Contexte** : Pour tester la persistance, il faut comprendre le mécanisme de synchronisation.
   - **Réponse** : [À compléter par le développeur]

7. **Performance** : Y a-t-il des optimisations prévues pour éviter de surcharger la base de données lors de multiples clics rapides ?
   - **Contexte** : Il faut tester les performances avec des actions rapides.
   - **Réponse** : [À compléter par le développeur]

### Données et base de données

8. **Données de test** : Y a-t-il des produits de test avec des ZIPs MCP Compliant et non-Compliant disponibles ?
   - **Contexte** : Pour tester, il faut des données représentatives.
   - **Réponse** : [À compléter par le développeur]

9. **Migration des données existantes** : Y a-t-il un script de migration pour initialiser la propriété "MCP Complaint" pour les ZIPs existants ?
   - **Contexte** : Il peut y avoir une migration à tester.
   - **Réponse** : [À compléter par le développeur]

10. **Requêtes base de données** : Quelles sont les requêtes SQL exactes utilisées pour lire et écrire la propriété "MCP Complaint" ?
    - **Contexte** : Pour tester la persistance, il faut comprendre les requêtes.
    - **Réponse** : [À compléter par le développeur]

### Sécurité et authentification

11. **Permissions backend** : Quels sont les rôles/permissions nécessaires pour modifier la case à cocher ? Y a-t-il une validation côté backend ?
    - **Contexte** : Pour tester la sécurité, il faut connaître les permissions.
    - **Réponse** : [À compléter par le développeur]

12. **Validation des données** : Y a-t-il une validation côté backend pour s'assurer que seuls les valeurs "YES/NO" ou "TRUE/FALSE" sont acceptées ?
    - **Contexte** : Il faut tester la validation des données.
    - **Réponse** : [À compléter par le développeur]

13. **Logs et audit** : Les changements d'état de la case à cocher sont-ils loggés ? Y a-t-il un système d'audit en place ?
    - **Contexte** : Les logs sont importants pour tracer les modifications.
    - **Réponse** : [À compléter par le développeur]

---

## 🎨 Pour le/la Product Designer

### Comportement de l'interface utilisateur

1. **Position de la colonne** : Où exactement la colonne "MCP Server" doit-elle être positionnée dans le tableau des ZIPs ? Y a-t-il une maquette disponible ?
   - **Contexte** : Pour tester l'affichage, il faut connaître la position exacte.
   - **Réponse** : [À compléter par le designer]

2. **Style de la case à cocher** : Quel est le style exact de la case à cocher ? (Taille, couleur, icône, etc.) Y a-t-il des variantes selon l'état (cochée, décochée, disabled) ?
   - **Contexte** : Pour tester l'affichage, il faut connaître tous les états visuels.
   - **Réponse** : [À compléter par le designer]

3. **États visuels** : Y a-t-il des états visuels différents pendant l'enregistrement (loading, success, error) ?
   - **Contexte** : Il peut y avoir des états de chargement à tester.
   - **Réponse** : [À compléter par le designer]

### Gestion des erreurs dans l'interface

4. **Affichage des erreurs** : Si l'enregistrement échoue, comment l'erreur doit-elle être affichée ? (Banner, toast, inline, etc.)
   - **Contexte** : Il faut comprendre comment gérer visuellement les erreurs.
   - **Réponse** : [À compléter par le designer]

5. **Feedback utilisateur** : Y a-t-il un feedback visuel lorsque la case est cochée/décochée ? (Animation, message de confirmation, etc.)
   - **Contexte** : Le feedback utilisateur est important pour l'UX.
   - **Réponse** : [À compléter par le designer]

### Responsive et accessibilité

6. **Responsive design** : Comment la colonne s'adapte-t-elle sur mobile et tablette ? Y a-t-il des ajustements de largeur ou d'affichage ?
   - **Contexte** : Il faut tester la responsivité du tableau.
   - **Réponse** : [À compléter par le designer]

7. **Accessibilité** : La case à cocher est-elle accessible au clavier ? Y a-t-il des attributs ARIA appropriés ? Le label est-il lisible par les lecteurs d'écran ?
   - **Contexte** : L'accessibilité est importante pour tous les utilisateurs.
   - **Réponse** : [À compléter par le designer]

### Interactions utilisateur

8. **Comportement du clic** : Que se passe-t-il exactement lorsque l'utilisateur clique sur la case à cocher ? Y a-t-il un enregistrement immédiat ou un bouton "Enregistrer" séparé ?
   - **Contexte** : Le CA5 et CA6 mentionnent "enregistrement" mais il faut clarifier le mécanisme exact.
   - **Réponse** : [À compléter par le designer]

9. **Intégration dans le tableau** : La colonne s'intègre-t-elle harmonieusement dans le tableau existant ? Y a-t-il des ajustements de largeur nécessaires ?
   - **Contexte** : Il faut comprendre comment la colonne s'intègre visuellement.
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

---

## 🔗 Documents associés

- **Stratégie de test** : [02-strategie-test.md]
- **Cas de test** : [03-cas-test.md]
- **User Story** : https://forge.prestashop.com/browse/MME-1436

