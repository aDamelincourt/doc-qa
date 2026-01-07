# D&#233;p&#244;t du cookie Segment ajs_anonymous_id en frontoffice sur v8 - Questions et Clarifications

## 📋 Informations générales

- **Feature** : D&#233;p&#244;t du cookie Segment ajs_anonymous_id en frontoffice sur v8
- **User Story** : ACCOUNT-3280 : D&#233;p&#244;t du cookie Segment ajs_anonymous_id en frontoffice sur v8
- **Sprint/Version** : [ex: Sprint 24, v2.3.0]
- **Date de création** : 2025-11-18
- **Auteur** : [Nom du QA]
- **Statut** : À valider

---

> 📌 **Note** : Ces questions ont été générées automatiquement en analysant le contenu du ticket Jira. Certaines peuvent nécessiter des ajustements en fonction du contexte du projet.

---

## 🗣️ Pour le Product Manager (PM)

### Règles métier et critères d'acceptation

1. **Comportement lors de la suppression pendant upload** : Si un utilisateur supprime un document pendant qu'un autre document est en cours d'upload, que doit-il se passer ? Le bouton Submit doit-il rester désactivé jusqu'à la fin de l'upload ?
   - **Contexte** : Le scénario 'Disable submission while a document is being uploaded' désactive le Submit pendant l'upload, mais le comportement lors d'une suppression simultanée n'est pas défini.
   - **Réponse** : [À compléter par le PM]

### Cas limites et comportements edge cases

2. **Nombre maximum de fichiers** : Y a-t-il une limite au nombre de documents (par langue) qu'un utilisateur peut uploader ? Par exemple, peut-on avoir readme_fr.pdf, readme_en.pdf, readme_es.pdf, etc. sans limite ?
   - **Contexte** : Les critères d'acceptation mentionnent '1 document par langue' mais ne précisent pas s'il y a une limite globale du nombre de langues supportées.
   - **Réponse** : [À compléter par le PM]

3. **Remplacement d'un fichier existant** : Si un utilisateur upload un nouveau fichier pour une langue qui a déjà un document (ex: remplacer readme_fr.pdf), le fichier précédent est-il automatiquement supprimé lors de l'upload ou uniquement lors du submit final ?
   - **Contexte** : Le scénario 'Back rule for deleting an old document' mentionne la suppression à la soumission, mais le comportement lors de l'upload immédiat n'est pas clair.
   - **Réponse** : [À compléter par le PM]

### Messages et notifications utilisateur

4. **Messages de confirmation** : Y a-t-il un message de confirmation à afficher lorsque l'upload d'un document réussit ? Si oui, quel est le format et le texte exact ?
   - **Contexte** : Les critères d'acceptation détaillent les messages d'erreur mais ne mentionnent pas de message de succès pour confirmer l'upload réussi.
   - **Réponse** : [À compléter par le PM]


---

## 💻 Pour les Développeur(se)s

### Architecture et implémentation technique

1. **Validation de fichier** : La validation du format (PDF), de la taille (2MB/10MB) et du nommage (readme_iso.pdf) est-elle effectuée côté client (avant upload), côté serveur (après upload), ou les deux ?
   - **Contexte** : Pour les tests, il est important de savoir où ces validations ont lieu, car cela impacte les cas de test à mettre en place.
   - **Réponse** : [À compléter par le développeur]

2. **Upload progressif et retry** : L'upload est-il progressif (avec progression en %) ? Y a-t-il un mécanisme de retry automatique en cas d'échec réseau ?
   - **Contexte** : Le ticket mentionne un spinner/loader pendant l'upload mais ne précise pas le comportement en cas d'échec partiel ou complet.
   - **Réponse** : [À compléter par le développeur]

3. **Stockage des fichiers** : Où sont stockés les fichiers uploadés ? (S3, système de fichiers local, CDN) Quel est le chemin de stockage et la structure de nommage en backend ?
   - **Contexte** : Pour tester la suppression et le remplacement de fichiers, il faut comprendre comment les fichiers sont gérés en backend.
   - **Réponse** : [À compléter par le développeur]

4. **API endpoints** : Quels sont les endpoints API utilisés pour l'upload, la suppression et la récupération de la liste des documents ? Y a-t-il une documentation Swagger/OpenAPI disponible ?
   - **Contexte** : Pour les tests d'intégration et les tests automatisés, il est nécessaire de connaître les contrats API.
   - **Réponse** : [À compléter par le développeur]

5. **Gestion des erreurs backend** : Quels codes d'erreur HTTP sont retournés par l'API en cas d'échec d'upload (400, 413, 500, etc.) ? Y a-t-il des messages d'erreur spécifiques retournés par le backend ?
   - **Contexte** : Les tests doivent couvrir les différents cas d'erreur côté serveur, pas seulement la validation côté client.
   - **Réponse** : [À compléter par le développeur]

6. **Logs et monitoring** : Où sont stockés les logs d'upload ? Y a-t-il des métriques spécifiques à surveiller (taux d'échec, temps d'upload moyen, etc.) ?
   - **Contexte** : Pour débugger les problèmes en environnement de test/staging, il faut savoir où consulter les logs.
   - **Réponse** : [À compléter par le développeur]

### Données et base de données

6. **Données de test** : Y a-t-il des fichiers de test (PDF) de différentes tailles disponibles dans l'environnement de staging ? (fichier < 2MB, fichier > 2MB, fichier exactement 2MB, etc.)
   - **Contexte** : Pour tester efficacement, il est utile d'avoir des fichiers de test prédéfinis avec des caractéristiques connues.
   - **Réponse** : [À compléter par le développeur]

7. **Persistance des données** : Les informations sur les documents uploadés sont-elles stockées en base de données immédiatement après l'upload, ou uniquement lors du submit final de la marketing sheet ?
   - **Contexte** : Cela impacte le comportement si l'utilisateur quitte la page sans soumettre, ou s'il y a une erreur lors du submit final.
   - **Réponse** : [À compléter par le développeur]


---

## 🎨 Pour le/la Product Designer

### Comportement de l'interface utilisateur

1. **Feedback visuel pendant l'upload** : Pendant l'upload, quel est le comportement visuel exact attendu ? Y a-t-il un spinner, une barre de progression, ou les deux ? Où sont-ils positionnés exactement ?
   - **Contexte** : Les commentaires mentionnent 'Loader sur le téléchargement' mais les maquettes Figma doivent préciser l'emplacement et le style exact.
   - **Réponse** : [À compléter par le designer]

2. **Positionnement des messages d'erreur** : Les messages d'erreur (format invalide, taille excessive, nom incorrect) doivent-ils apparaître comme un banner en haut de la zone d'upload, en dessous, ou ailleurs ? Le banner reste-t-il visible jusqu'à ce que l'utilisateur corrige l'erreur ?
   - **Contexte** : Les critères d'acceptation mentionnent 'error message banner immediately appears' mais ne précisent pas l'emplacement exact et la durée d'affichage.
   - **Réponse** : [À compléter par le designer]

3. **Zone drag-and-drop** : La zone de drag-and-drop a-t-elle un état visuel différent quand on survole avec un fichier (hover state) ? Y a-t-il une animation de transition lors du drop ?
   - **Contexte** : Pour tester l'UX complète, il faut connaître tous les états visuels de la zone d'upload.
   - **Réponse** : [À compléter par le designer]

### Responsive et accessibilité

4. **Adaptation mobile/tablette** : La zone d'upload et l'affichage des documents sont-ils adaptés pour mobile et tablette ? Y a-t-il des changements de layout ou d'interaction sur petits écrans ?
   - **Contexte** : Le ticket mentionne le label 'ALL_SCREENS', ce qui suggère que la fonctionnalité doit être responsive.
   - **Réponse** : [À compléter par le designer]

5. **Accessibilité** : Y a-t-il des considérations d'accessibilité spécifiques pour la zone d'upload ? (Navigation au clavier, labels ARIA, support lecteur d'écran, etc.)
   - **Contexte** : Pour des tests d'accessibilité complets, il faut connaître les requirements spécifiques.
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

- **Stratégie de test** : [Lien vers le document de stratégie]
- **Cas de test** : [Lien vers le document de cas de test]
- **User Story** : https://forge.prestashop.com/browse/ACCOUNT-3280
- **Extraction Jira** : extraction-jira.md
