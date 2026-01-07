# Guide d'extraction depuis XML Jira

## 📋 Introduction

Si vous exportez les tickets Jira au format XML, ce guide vous aide à extraire les informations nécessaires pour générer la documentation QA.

---

## 🔍 Structure XML typique d'un ticket Jira

Un ticket Jira exporté en XML contient généralement :

```xml
<item>
  <title>[Clé du ticket] - [Titre]</title>
  <link>[URL du ticket]</link>
  <description>
    <![CDATA[
      [Description HTML avec toutes les informations]
    ]]>
  </description>
  <key>[CLÉ-DU-TICKET]</key>
  <summary>[Titre résumé]</summary>
  <type>[Story/Bug/Task]</type>
  <priority>[Priority]</priority>
  <status>[Status]</status>
  <resolution>[Resolution]</resolution>
  <assignee>[Assignee]</assignee>
  <reporter>[Reporter]</reporter>
  <created>[Date de création]</created>
  <updated>[Date de mise à jour]</updated>
  <comment>[Commentaires]</comment>
</item>
```

---

## 📝 Extraction des informations depuis XML

### Option 1 : Extraction manuelle (Recommandé)

1. **Ouvrir le fichier XML** dans un éditeur de texte
2. **Identifier les sections** clés :
   - `<title>` : Clé et titre du ticket
   - `<link>` : URL du ticket
   - `<key>` : Clé du ticket (ex: MME-931)
   - `<summary>` : Titre du ticket
   - `<description>` : Description complète (souvent en HTML dans CDATA)
   - `<comment>` : Commentaires de l'équipe

3. **Utiliser le template `extraction-jira-template.md`** pour structurer les informations extraites

### Option 2 : Parser avec un script (Avancé)

Si vous avez de nombreux tickets, vous pouvez créer un script pour parser le XML automatiquement.

---

## 🎯 Informations à extraire depuis XML

### 1. Informations générales

Depuis les balises XML :
```xml
<key>MME-931</key>
<summary>Sélection des pays de vente</summary>
<link>https://jira.prestashop.com/browse/MME-931</link>
<type>Story</type>
<status>In Progress</status>
```

**À extraire** :
- Clé du ticket : `<key>`
- Titre : `<summary>`
- Type : `<type>`
- Statut : `<status>`
- Lien : `<link>`

---

### 2. Description et critères d'acceptation

La description est généralement dans `<description>` et peut contenir du HTML :

```xml
<description>
  <![CDATA[
    <h1>User Story</h1>
    <p>As a module seller, I want to...</p>
    <h1>Acceptance Criteria</h1>
    <ul>
      <li>Given... When... Then...</li>
    </ul>
  ]]>
  </description>
```

**À extraire** :
- Description complète : contenu de `<description>`
- User Story : rechercher les sections `<h1>User Story</h1>` ou similaires
- Critères d'acceptation : rechercher "Acceptance Criteria", "Given/When/Then"

**Astuce** : Copier le contenu de `<description>` dans un éditeur HTML pour mieux lire le formatage

---

### 3. Commentaires de l'équipe

Les commentaires sont dans `<comment>` :

```xml
<comment>
  <author>[Nom]</author>
  <created>[Date]</created>
  <body>
    <![CDATA[
      [Contenu du commentaire en HTML]
    ]]>
  </body>
</comment>
```

**À extraire** :
- Commentaires du PM : rechercher par auteur ou par contenu métier
- Commentaires techniques : rechercher par auteur dev ou mots-clés techniques
- Commentaires du Designer : rechercher par auteur designer ou mots-clés UI/UX

---

### 4. Informations techniques

Rechercher dans :
- Le contenu de `<description>` : sections "Technical Notes", "Implementation"
- Les `<comment>` : commentaires contenant "API", "database", "endpoint"
- Les balises personnalisées si configurées dans votre Jira

**Mots-clés à rechercher** :
- "API", "endpoint", "database", "table"
- "Module", "Service", "Component"
- "Integration", "Dependency"

---

### 5. Liens et dépendances

Rechercher dans `<description>` et `<comment>` :
- Liens Figma : `figma.com` ou `design`
- Liens Confluence : `confluence` ou liens de documentation
- Tickets liés : références `MME-XXX`, `[MME-XXX]`
- Blocages : "blocks", "blocked by", "depends on"

---

## 🛠️ Outils utiles pour parser XML

### En ligne (Rapide)

1. **XML Viewer Online** : 
   - https://codebeautify.org/xmlviewer
   - Collez votre XML pour voir la structure formatée

2. **XML Parser** :
   - Facilite la navigation dans la structure XML

### En local (Script)

**Python** (exemple simple) :
```python
import xml.etree.ElementTree as ET

tree = ET.parse('jira-export.xml')
root = tree.getroot()

for item in root.findall('item'):
    key = item.find('key').text
    title = item.find('summary').text
    description = item.find('description').text
    # ... extraire autres champs
```

**JavaScript/Node.js** :
```javascript
const fs = require('fs');
const xml2js = require('xml2js');

const parser = new xml2js.Parser();
const xml = fs.readFileSync('jira-export.xml', 'utf8');

parser.parseString(xml, (err, result) => {
  // Traiter le résultat
});
```

---

## 📋 Checklist d'extraction depuis XML

Avant d'utiliser le prompt de génération, vérifier :

- [ ] Clé du ticket extraite (`<key>`)
- [ ] Titre extrait (`<summary>`)
- [ ] Description complète extraite (`<description>`)
- [ ] User Story identifiée dans la description
- [ ] Critères d'acceptation identifiés
- [ ] Commentaires pertinents extraits (`<comment>`)
- [ ] Liens Figma/Design identifiés
- [ ] Informations techniques identifiées
- [ ] Tickets liés identifiés
- [ ] Lien Jira (`<link>`)

---

## 🔄 Workflow recommandé

### Étape 1 : Exporter depuis Jira

1. Dans Jira, exporter le ticket au format XML
2. Sauvegarder le fichier XML dans `../Jira/[NOM_PROJET]/[TICKET-ID].xml`
   - Exemple : `Jira/SPEX/SPEX-2990.xml`
   - Si le dossier projet n'existe pas, le créer

### Étape 2 : Parser le XML

1. Ouvrir le fichier XML : `Jira/[NOM_PROJET]/[TICKET-ID].xml`
2. Utiliser un éditeur de texte ou viewer XML pour identifier les sections
3. Identifier les balises principales (`<key>`, `<summary>`, `<description>`, `<comment>`)

### Étape 3 : Extraire les informations

1. Utiliser le template `extraction-jira-template.md`
2. Copier-coller les informations depuis le XML dans le template
3. Structurer les informations selon le template

### Étape 4 : Utiliser dans le prompt

1. Ouvrir `prompt-generation-qa.md`
2. Remplir les sections avec les informations extraites du XML
3. Générer la documentation avec l'IA

### Étape 5 : Sauvegarder la documentation

1. Générer les 3 fichiers QA dans `../projets/[NOM_PROJET]/us-[NUMBER]/`
2. Le fichier XML reste dans `Jira/[NOM_PROJET]/` pour référence

---

## 💡 Astuces

### Extraction rapide (Minimum vital)

Si vous êtes pressé, extraire au minimum :
- `<key>` : Clé du ticket
- `<summary>` : Titre
- `<description>` : Description complète (avec critères d'acceptation)
- `<link>` : URL du ticket

### Extraction complète (Recommandé)

Pour une documentation complète :
- Toutes les sections ci-dessus
- `<comment>` : Commentaires pertinents de l'équipe
- Recherche de liens Figma/Confluence dans la description
- Tickets liés dans les commentaires

### Gérer le HTML dans `<description>`

La description est souvent en HTML. Options :
1. **Copier tel quel** : Le parser HTML peut extraire le texte
2. **Voir le rendu** : Ouvrir le HTML dans un navigateur pour lire le formatage
3. **Extraire le texte** : Utiliser un outil pour extraire uniquement le texte

---

## 🔗 Voir aussi

- `../Jira/README.md` : Guide de la structure du dossier Jira avec les exports XML
- `extraction-jira-template.md` : Template pour structurer les informations extraites
- `prompt-generation-qa.md` : Prompt pour générer la documentation
- `../README.md` : Guide général de la documentation QA

---

## 📧 Besoin d'aide ?

Si vous avez un fichier XML complexe ou des questions sur l'extraction, vous pouvez :
1. Partager un extrait du XML (sans données sensibles)
2. Me demander de créer un script de parsing personnalisé
3. Me demander d'améliorer ce guide selon vos besoins

