# SPIKE / PREPA: Interface de gestion pour autonomie du support - Stratégie de Test

## 📋 Informations générales

- **Feature** : SPIKE / PREPA: Interface de gestion pour autonomie du support
- **User Story** : ACCOUNT-3182 : SPIKE / PREPA: Interface de gestion pour autonomie du support
- **Sprint/Version** : [ex: Sprint 24, v2.3.0]
- **Date de création** : 2025-11-18
- **Auteur** : [Nom du QA]
- **Statut** : Draft
- **Lien Jira/Ticket** : https://forge.prestashop.com/browse/ACCOUNT-3182

---

## 🎯 Objectif de la fonctionnalité

**Description** : 

Permet aux vendeurs de modules de télécharger un guide PDF pour leur produit afin que les clients puissent comprendre comment l'utiliser.

**User Stories couvertes** :

- ACCOUNT-3182 : 

---

## ✅ Prérequis

### Environnement

- **OS** : Windows/Mac/Linux
- **Navigateurs** : Chrome 120+, Firefox 115+, Safari 17+
- **Résolution min** : 1920x1080 (desktop), responsive pour mobile/tablette

### Données nécessaires

- [ ] Compte vendeur avec accès à la marketing sheet
- [ ] Produit de type Module, Theme ou Pack existant dans la base de test
- [ ] Fichiers PDF de test avec différentes caractéristiques :
  - [ ] Fichier valide (readme_fr.pdf, < 10MB)
  - [ ] Fichier trop volumineux (> 10MB)
  - [ ] Fichier avec mauvais format (ex: .docx)
  - [ ] Fichier avec mauvais nommage (ex: mydocument.pdf)

### Dépendances

- Accès à la page de marketing sheet
- Section 'How to install your product?' disponible
- Système d'upload de fichiers fonctionnel

---

## 🎯 Objectif principal

Valider de bout en bout la fonctionnalité **SPIKE / PREPA: Interface de gestion pour autonomie du support** en s'assurant qu'elle répond aux critères d'acceptation et ne provoque pas de régression sur les fonctionnalités existantes de la marketing sheet.

---

## 📊 Axes de test et points de vigilance

### 1. Scénarios nominaux

**Objectif** : Vérification du parcours utilisateur standard et des cas d'usage principaux de l'upload de documentation.

**Approche** :
- Tester le flux principal de bout en bout : affichage de la section → upload d'un document → visualisation → suppression → soumission
- Valider l'upload via drag-and-drop et via clic sur la zone d'upload
- Vérifier l'affichage correct du fichier uploadé avec son nom et l'icône de suppression
- Tester la persistance des données après soumission de la marketing sheet

**Points de vigilance** :
- S'assurer que la zone d'upload est visible uniquement pour les produits de type Module, Theme ou Pack
- Vérifier que le message informatif sur la convention de nommage 'readme_iso.pdf' est correctement affiché
- Valider que le fichier uploadé apparaît immédiatement dans l'interface avec son nom et l'icône 'X' de suppression
- Vérifier qu'on ne peut pas uploader un deuxième fichier pour la même langue
- Confirmer que la documentation est correctement sauvegardée et accessible après soumission

---

### 2. Cas limites et robustesse

**Objectif** : Tester la solidité de l'implémentation face aux valeurs extrêmes et cas limites.

**Approche** :
- Tester avec des fichiers vides ou corrompus
- Vérifier le comportement lors de l'upload de plusieurs fichiers pour différentes langues simultanément

**Points de vigilance** :
- Vérifier que les limites (taille, format, nommage) sont correctement appliquées sans casser l'interface
- S'assurer que les messages d'erreur apparaissent immédiatement sans attendre la fin de l'upload
- Valider que les fichiers invalides ne sont pas stockés côté serveur
- Tester le cas où l'utilisateur tente d'uploader plusieurs fichiers pour la même langue

---

### 3. Gestion des erreurs

**Objectif** : Validation de la clarté et de la pertinence des messages d'erreur affichés à l'utilisateur.

**Approche** :
- Tester tous les cas d'erreur possibles identifiés dans les critères d'acceptation
- Vérifier que les messages d'erreur sont exactement ceux spécifiés dans les critères d'acceptation
- Valider que les erreurs n'apparaissent qu'au bon moment (immédiatement pour l'upload, à la soumission pour le manque de documentation)
- Tester que les erreurs ne provoquent pas de crash ou d'état incohérent de l'application

**Points de vigilance** :
- S'assurer que les messages d'erreur sont cohérents avec le design system (banner en haut de page, message dans la section documentation)
- Vérifier que le message d'erreur 'Oops, it seems there are a few mistakes!' apparaît bien en haut de la page lors de la soumission sans documentation
- Valider que le message spécifique 'You must add a documentation file to sell your product on the marketplace.' apparaît dans la section documentation
- Confirmer que l'upload est rejeté immédiatement pour les fichiers invalides (pas d'envoi côté serveur)

---

### 4. Sécurité et autorisations

**Objectif** : Vérifier que les contrôles d'accès et les validations de sécurité sont correctement implémentés.

**Approche** :
- Tester l'accès à la fonctionnalité avec différents rôles utilisateurs (vendeur, admin, etc.)
- Vérifier que seuls les produits de type Module, Theme ou Pack peuvent avoir une documentation uploadée
- Tester que les fichiers uploadés sont correctement associés au bon produit et vendeur
- Valider que les utilisateurs ne peuvent pas accéder ou modifier les fichiers d'autres vendeurs

**Points de vigilance** :
- Vérifier que la validation du format de fichier se fait aussi côté serveur (pas seulement côté client)
- S'assurer que les fichiers malveillants (scripts, exécutables) ne peuvent pas être uploadés même avec l'extension .pdf
- Valider que les limites de taille sont aussi appliquées côté serveur pour éviter les contournements

---

### 5. Performance

**Objectif** : S'assurer que la fonctionnalité reste performante même avec des fichiers volumineux.

**Approche** :
- Tester l'upload avec des fichiers de taille maximale (10MB)
- Mesurer les temps de réponse lors de l'upload
- Vérifier que le spinner/loader est visible pendant l'upload
- Tester le comportement lors de plusieurs uploads simultanés (si plusieurs langues)

**Points de vigilance** :
- Temps de chargement acceptable (< 30 secondes pour un fichier de 10MB)
- L'interface reste responsive pendant l'upload (pas de freeze)
- Le bouton Submit est correctement désactivé pendant l'upload pour éviter les soumissions multiples
- L'upload peut être annulé si nécessaire

---

### 6. Intégration

**Objectif** : Valider les interactions avec les services backend et la persistance des données.

**Approche** :
- Tester que les fichiers sont correctement sauvegardés dans la base de données après upload
- Vérifier que lors du remplacement d'un document, l'ancien fichier est bien supprimé du stockage
- Tester que la documentation est correctement propagée sur la marketplace après soumission
- Valider que les données sont persistées même si l'utilisateur quitte la page puis revient

**Points de vigilance** :
- Vérifier que le scénario 'Back rule for deleting an old document on new submission' fonctionne correctement
- S'assurer qu'aucun fichier orphelin n'est laissé dans le stockage si l'upload échoue
- Confirmer que les informations sur les documents uploadés sont bien liées au produit dans la base de données

---

### 7. Compatibilité

**Objectif** : S'assurer que la fonctionnalité fonctionne sur différents navigateurs et résolutions.

**Approche** :
- Tester sur les principaux navigateurs (Chrome, Firefox, Safari, Edge)
- Tester sur différentes résolutions (Desktop 1920x1080, Tablet 768x1024, Mobile 375x667)
- Vérifier que le drag-and-drop fonctionne sur tous les navigateurs supportés
- Valider la cohérence visuelle entre les différents environnements

**Points de vigilance** :
- Le drag-and-drop peut avoir des comportements différents selon les navigateurs
- L'affichage de la zone d'upload doit s'adapter correctement sur mobile/tablette
- Les messages d'erreur doivent être lisibles et accessibles sur toutes les tailles d'écran
- Aucune régression visuelle par rapport aux maquettes Figma

---

### 8. Accessibilité

**Objectif** : Valider que la fonctionnalité est accessible à tous les utilisateurs.

**Approche** :
- Tester la navigation au clavier dans la zone d'upload
- Vérifier que les éléments sont correctement labellés pour les lecteurs d'écran
- Valider les contrastes et les tailles de police des messages
- Tester que les messages d'erreur sont annoncés par les lecteurs d'écran

**Points de vigilance** :
- La zone d'upload doit être accessible au clavier (Tab, Enter)
- Les messages d'erreur doivent avoir des attributs ARIA appropriés
- L'icône de suppression doit avoir un label accessible
- Les états de chargement doivent être annoncés aux utilisateurs de lecteurs d'écran

---

## ⚠️ Impacts et non-régression

**Zones à risque identifiées** :

Une attention particulière sera portée sur les éléments suivants pour s'assurer qu'ils ne sont pas affectés :

1. **La soumission globale de la marketing sheet**
   - **Pourquoi** : Le scénario 'Disable submission while a document is being uploaded' désactive le bouton Submit pendant l'upload. Il faut vérifier que cela n'impacte pas les autres validations ou la soumission des autres sections de la marketing sheet.
   - **Tests de régression** : Vérifier que les autres champs obligatoires de la marketing sheet continuent d'être validés correctement et que la soumission fonctionne normalement une fois l'upload terminé.

2. **L'affichage et la persistance des autres sections de la marketing sheet**
   - **Pourquoi** : L'ajout de la section documentation dans 'How to install your product?' ne doit pas impacter l'affichage ou le fonctionnement des autres blocs de cette section (main steps, prerequisites, anything to add).
   - **Tests de régression** : Valider que les 3 autres blocs de la section restent fonctionnels et que leurs données sont correctement sauvegardées.

**Fonctionnalités connexes à vérifier** :

- [ ] La section 'How to install your product?' reste fonctionnelle dans son ensemble
- [ ] Les autres sections de la marketing sheet ne sont pas impactées
- [ ] La soumission de la marketing sheet fonctionne correctement avec ou sans documentation
- [ ] Performance acceptable (< 30 secondes pour upload de 10MB)
- [ ] Aucune régression visuelle par rapport aux maquettes Figma

---

## 📈 Métriques et critères de succès

### Critères de validation

- ✅ Tous les scénarios nominaux passent (upload, affichage, suppression, soumission)
- ✅ Tous les cas limites sont gérés correctement (taille, format, nommage)
- ✅ Tous les messages d'erreur sont clairs, pertinents et apparaissent au bon moment
- ✅ Aucune régression identifiée sur les fonctionnalités existantes de la marketing sheet
- ✅ Performance acceptable (upload de 10MB < 30 secondes)
- ✅ Fonctionnalité accessible au clavier et compatible lecteurs d'écran
- ✅ Compatible avec les principaux navigateurs (Chrome, Firefox, Safari, Edge)

### Métriques de test

- **Nombre total de scénarios** : ~0 (identifiés dans les critères d'acceptation)
- **Nombre de scénarios critiques** : 5 (upload valide, validation erreurs, soumission, persistance, remplacement)
- **Temps estimé de test** : 4-6 heures
- **Environnements de test** : Staging, Preprod

---

## 🔍 Tests de régression

**Stratégie** : 

Tester les fonctionnalités critiques de la marketing sheet qui pourraient être impactées par l'ajout de la section documentation :

**Checklist de régression** :

- [ ] Affichage de la section 'How to install your product?' (blocs main steps, prerequisites, anything to add)
- [ ] Soumission complète de la marketing sheet avec tous les champs obligatoires
- [ ] Affichage et édition des autres sections de la marketing sheet
- [ ] Persistance des données après soumission et rechargement de la page
- [ ] Navigation entre les différentes sections de la marketing sheet

---

## 📝 Notes & Observations

> 📌 **Note importante** : Cette stratégie a été générée automatiquement en analysant le contenu du ticket Jira. Certains points peuvent nécessiter des ajustements en fonction du contexte spécifique du projet et des décisions d'implémentation.

- Les maquettes Figma sont disponibles dans le ticket Jira (section Designs)
- Certains scénarios marqués en rouge dans le ticket sont désactivés (pas d'actualité) et ne doivent pas être testés pour cette version
- La limite de taille de fichier mentionnée dans les critères d'acceptation est 2MB, mais les commentaires indiquent 10MB (à clarifier avec l'équipe)

---

## 🔗 Documents associés

- **Questions et Clarifications** : 01-questions-clarifications.md
- **Cas de test** : 03-cas-test.md
- **User Story** : https://forge.prestashop.com/browse/ACCOUNT-3182
- **Extraction Jira** : extraction-jira.md

---

## ✍️ Validation

- **Rédigé par** : [Nom]
- **Date de rédaction** : 2025-11-18
- **Validé par** : [Nom du responsable QA]
- **Date de validation** : [AAAA-MM-JJ]

