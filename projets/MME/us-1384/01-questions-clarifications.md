# [Compte Addons] Ajouter bouton "leave a review" - Order Detail Page - Questions et Clarifications

## 📋 Informations générales

- **Feature** : Bouton "leave a review" sur la page de détail de commande
- **User Story** : MME-1384 : [Compte Addons] Ajouter bouton "leave a review" - Order Detail Page
- **Sprint/Version** : [À compléter]
- **Date de création** : 2025-11-18
- **Auteur** : [Nom du QA]
- **Statut** : À valider

---

## 🗣️ Pour le Product Manager (PM)

### Règles métier et critères d'acceptation

1. **Délai pour laisser un avis** : Y a-t-il un délai limité pour laisser un avis après la commande ? Si oui, quel est ce délai et comment est-il géré dans l'interface ?
   - **Contexte** : Le contexte mentionne que les clients ignorent souvent le délai limité pour laisser un avis. Il faut clarifier ce délai pour tester correctement le comportement du bouton.
   - **Réponse** : [À compléter par le PM]

2. **Conditions d'affichage du bouton** : Le CA1 mentionne que le bouton doit s'afficher si "le lien avis vérifié est déjà généré et que l'avis n'est pas encore déposé". Quelles sont exactement les conditions pour qu'un lien soit considéré comme "généré" ?
   - **Contexte** : Cette condition est cruciale pour tester l'affichage du bouton. Il faut comprendre précisément quand le lien est généré.
   - **Réponse** : [À compléter par le PM]

3. **Page de destination du bouton** : Le bouton renvoie vers "la page review du compte filtrée sur la bonne commande". Quelle est l'URL exacte de cette page ? Y a-t-il des paramètres spécifiques à passer ?
   - **Contexte** : Pour tester la redirection, il faut connaître l'URL exacte et les paramètres attendus.
   - **Réponse** : [À compléter par le PM]

4. **Disparition du bouton après avis** : Le CA2 indique que le bouton ne doit plus s'afficher après avoir laissé un avis. Y a-t-il un délai de rafraîchissement ou le bouton disparaît-il immédiatement après la soumission de l'avis ?
   - **Contexte** : Cette information est importante pour tester la mise à jour de l'interface après la soumission d'un avis.
   - **Réponse** : [À compléter par le PM]

5. **Gestion des avis multiples** : Un utilisateur peut-il laisser plusieurs avis pour la même commande ? Si oui, comment cela impacte-t-il l'affichage du bouton ?
   - **Contexte** : Il faut comprendre si un utilisateur peut modifier son avis ou en laisser plusieurs pour tester tous les cas.
   - **Réponse** : [À compléter par le PM]

6. **Types de commandes concernées** : Le bouton s'affiche-t-il pour tous les types de commandes ou uniquement pour certains types de produits (modules, thèmes, packs) ?
   - **Contexte** : La spécification mentionne "Order Detail Page" mais ne précise pas si toutes les commandes sont concernées.
   - **Réponse** : [À compléter par le PM]

7. **Règles de génération du lien** : Quelles sont les règles exactes pour qu'un lien avis vérifié soit généré ? Y a-t-il des conditions spécifiques (montant minimum, type de produit, etc.) ?
   - **Contexte** : Pour tester l'affichage du bouton, il faut comprendre toutes les conditions de génération du lien.
   - **Réponse** : [À compléter par le PM]

### Cas limites et comportements edge cases

8. **Commande avec plusieurs produits** : Si une commande contient plusieurs produits, le bouton renvoie-t-il vers un formulaire d'avis pour tous les produits ou pour un produit spécifique ?
   - **Contexte** : Cette situation est courante et doit être testée pour s'assurer que l'expérience utilisateur est claire.
   - **Réponse** : [À compléter par le PM]

9. **Commande annulée ou remboursée** : Le bouton doit-il s'afficher pour les commandes annulées ou remboursées ? Si oui, l'avis peut-il toujours être laissé ?
   - **Contexte** : Il faut clarifier le comportement pour les commandes qui ne sont plus actives.
   - **Réponse** : [À compléter par le PM]

10. **Expiration du lien** : Le lien avis vérifié a-t-il une date d'expiration ? Si oui, que se passe-t-il si l'utilisateur clique sur le bouton après expiration ?
    - **Contexte** : Les liens peuvent expirer, il faut comprendre comment cela est géré.
    - **Réponse** : [À compléter par le PM]

11. **Avis déjà déposé mais non visible** : Si un avis a été déposé mais n'est pas encore approuvé/modéré, le bouton doit-il toujours s'afficher ou disparaître immédiatement ?
    - **Contexte** : Il faut comprendre le comportement pendant la période de modération.
    - **Réponse** : [À compléter par le PM]

### Messages et notifications utilisateur

12. **Texte exact du bouton** : Quel est le texte exact du bouton ? "Leave a review", "Laisser un avis", ou une autre formulation ? Y a-t-il des variantes selon la langue ?
    - **Contexte** : Pour tester l'affichage, il faut connaître le texte exact du bouton.
    - **Réponse** : [À compléter par le PM]

13. **Message si lien non disponible** : Si le lien avis vérifié n'est pas encore généré, y a-t-il un message ou une indication pour l'utilisateur ?
    - **Contexte** : Il faut comprendre comment l'interface gère le cas où le lien n'est pas encore disponible.
    - **Réponse** : [À compléter par le PM]

---

## 💻 Pour les Développeur(se)s

### Architecture et implémentation technique

1. **Endpoint API modifié** : Le call GET /request3/clientaccount/orders/{id_order} a-t-il été modifié pour inclure le champ "review_link" ? Quelle est la structure exacte de la réponse ?
   - **Contexte** : Pour tester l'intégration, il faut connaître la structure exacte de la réponse API.
   - **Réponse** : [À compléter par le développeur]

2. **Tables de base de données** : Les tables `ps_avis_verifie_product_review` et `ps_avis_verifie_order_url` sont-elles accessibles depuis l'environnement de test ? Y a-t-il des données de test disponibles ?
   - **Contexte** : Pour tester les vérifications, il faut pouvoir interroger ces tables ou avoir des données de test.
   - **Réponse** : [À compléter par le développeur]

3. **Logique de vérification** : La vérification dans les tables se fait-elle côté backend lors de l'appel API ou côté frontend ? Y a-t-il un cache impliqué ?
   - **Contexte** : Cette information est importante pour comprendre où et comment tester la logique.
   - **Réponse** : [À compléter par le développeur]

4. **Format du review_link** : Quel est le format exact du champ "review_link" dans la réponse API ? Est-ce une URL complète, un chemin relatif, ou un identifiant ?
   - **Contexte** : Pour tester la redirection, il faut connaître le format exact du lien.
   - **Réponse** : [À compléter par le développeur]

### Contrats d'API et intégrations

5. **Gestion des erreurs API** : Que se passe-t-il si l'appel API GET /request3/clientaccount/orders/{id_order} échoue ? Le bouton doit-il s'afficher ou être masqué ?
   - **Contexte** : Il faut tester la robustesse de l'interface en cas d'erreur API.
   - **Réponse** : [À compléter par le développeur]

6. **Performance de l'API** : Quel est le temps de réponse attendu pour l'appel API ? Y a-t-il un timeout configuré ?
   - **Contexte** : Pour tester les performances, il faut connaître les attentes de temps de réponse.
   - **Réponse** : [À compléter par le développeur]

7. **Cache et rafraîchissement** : Y a-t-il un mécanisme de cache pour les données de commande ? Si oui, comment est géré le rafraîchissement après qu'un avis ait été déposé ?
   - **Contexte** : Le cache peut impacter l'affichage du bouton après la soumission d'un avis.
   - **Réponse** : [À compléter par le développeur]

### Données et base de données

8. **Données de test** : Y a-t-il des commandes de test avec des liens avis vérifiés générés ? Y a-t-il des commandes avec des avis déjà déposés ?
   - **Contexte** : Pour tester tous les scénarios, il faut des données de test représentatives.
   - **Réponse** : [À compléter par le développeur]

9. **Structure des tables** : Quelle est la structure exacte des tables `ps_avis_verifie_product_review` et `ps_avis_verifie_order_url` ? Quels sont les champs clés à vérifier ?
   - **Contexte** : Pour comprendre la logique de vérification, il faut connaître la structure des tables.
   - **Réponse** : [À compléter par le développeur]

10. **Synchronisation des données** : Y a-t-il un délai entre le dépôt d'un avis et la mise à jour dans la table `ps_avis_verifie_product_review` ? Comment cela impacte-t-il l'affichage du bouton ?
    - **Contexte** : Il peut y avoir un délai de synchronisation qui impacte l'affichage du bouton.
    - **Réponse** : [À compléter par le développeur]

### Sécurité et authentification

11. **Permissions d'accès** : Tous les utilisateurs peuvent-ils voir le bouton ou y a-t-il des restrictions basées sur les rôles/permissions ?
    - **Contexte** : Il faut tester l'accès selon les différents rôles utilisateurs.
    - **Réponse** : [À compléter par le développeur]

12. **Validation du lien** : Le lien généré dans `ps_avis_verifie_order_url` est-il sécurisé ? Y a-t-il des tokens ou des validations pour éviter les accès non autorisés ?
    - **Contexte** : La sécurité des liens est importante pour éviter les abus.
    - **Réponse** : [À compléter par le développeur]

13. **Logs et monitoring** : Où sont loggés les clics sur le bouton "leave a review" ? Y a-t-il un système de tracking en place ?
    - **Contexte** : Les logs sont importants pour analyser l'utilisation de la fonctionnalité.
    - **Réponse** : [À compléter par le développeur]

---

## 🎨 Pour le/la Product Designer

### Comportement de l'interface utilisateur

1. **Position du bouton** : Où exactement le bouton doit-il être positionné dans la modale de commande ? Y a-t-il une maquette Figma disponible ?
   - **Contexte** : La maquette Figma est mentionnée dans le ticket. Il faut vérifier la position exacte du bouton.
   - **Réponse** : [À compléter par le designer]

2. **Style et apparence** : Quel est le style exact du bouton ? (Couleur, taille, icône, etc.) Y a-t-il des variantes selon l'état (hover, active, disabled) ?
   - **Contexte** : Pour tester l'affichage, il faut connaître tous les états visuels du bouton.
   - **Réponse** : [À compléter par le designer]

3. **États visuels** : Y a-t-il des états visuels différents pour le bouton selon les conditions (lien disponible, lien en cours de génération, etc.) ?
   - **Contexte** : Il peut y avoir différents états visuels à tester.
   - **Réponse** : [À compléter par le designer]

### Gestion des erreurs dans l'interface

4. **Affichage des erreurs** : Si le lien n'est pas disponible ou si une erreur survient, comment cela doit-il être affiché à l'utilisateur ?
   - **Contexte** : Il faut comprendre comment gérer visuellement les cas d'erreur.
   - **Réponse** : [À compléter par le designer]

5. **Feedback utilisateur** : Y a-t-il un feedback visuel lorsque l'utilisateur clique sur le bouton (loader, animation, etc.) ?
   - **Contexte** : Le feedback utilisateur est important pour l'UX.
   - **Réponse** : [À compléter par le designer]

### Responsive et accessibilité

6. **Responsive design** : Comment le bouton s'adapte-t-il sur mobile et tablette ? Y a-t-il des ajustements de taille ou de position ?
   - **Contexte** : Il faut tester la responsivité du bouton sur différents appareils.
   - **Réponse** : [À compléter par le designer]

7. **Accessibilité** : Le bouton est-il accessible au clavier ? Y a-t-il des attributs ARIA appropriés ? Le texte est-il lisible par les lecteurs d'écran ?
   - **Contexte** : L'accessibilité est importante pour tous les utilisateurs.
   - **Réponse** : [À compléter par le designer]

### Interactions utilisateur

8. **Comportement du clic** : Que se passe-t-il exactement lorsque l'utilisateur clique sur le bouton ? Y a-t-il une ouverture dans un nouvel onglet, une redirection dans le même onglet, ou une modale ?
   - **Contexte** : Pour tester la redirection, il faut connaître le comportement exact du clic.
   - **Réponse** : [À compléter par le designer]

9. **Intégration dans la modale** : Le bouton est-il toujours visible dans la modale ou apparaît-il conditionnellement ? Y a-t-il une animation d'apparition ?
   - **Contexte** : Il faut comprendre comment le bouton s'intègre visuellement dans la modale.
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
- **User Story** : https://forge.prestashop.com/browse/MME-1384

