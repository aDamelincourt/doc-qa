# Extraction Jira - MME-1436

## 📋 Informations générales

**Clé du ticket** : MME-1436
**Titre/Summary** : Produit MCP Server Compliant - ajouter une coche sur les pages produits dans DS 
**Type** : Story
**Statut** : [À extraire manuellement]
**Lien Jira** : https://forge.prestashop.com/browse/MME-1436

## 📝 Description / User Story

```
    This file is an XML representation of an issue
                    &lt;h1&gt;&lt;a name=&quot;Contexte&quot;&gt;&lt;/a&gt;&lt;b&gt;Contexte&lt;/b&gt;&lt;/h1&gt;

&lt;p&gt;Avec la sortie du module PS MCP Server, certains seller vont commencer &#224; sousmettre des nouvelle version de leur module qui utilisent le MCP Server. Dans le futur, nous aimerions pouvoir mettre en avant les produits qui utilisent le MCP PrestaShop ( filtre, tag, category, ... ). Afin de pouvoir les mettre en avant il faut &#234;tre capable de reconnaitre quels modules sont &quot;MCP Compliant&quot;.&#160;&lt;/p&gt;
&lt;h1&gt;&lt;a name=&quot;ObjectifetSolution&quot;&gt;&lt;/a&gt;&lt;b&gt;Objectif et Solution&lt;/b&gt;&lt;/h1&gt;

&lt;p&gt;La seule fa&#231;on de reconnaitre si un module est MCP Compliant ou non est de v&#233;rifier le zip et la pr&#233;sence d&apos;une partie de code &quot;MCP Compliant&quot;. L&apos;&#233;quipe Solution Engineer sera donc charg&#233;e de v&#233;rifier pendant leur autres check des nouveaux zip soumis, si le module est MCP Compliant et le flagguer comme tel.&#160;&lt;/p&gt;

&lt;p&gt;Nous envisageons d&apos;ajouter une coche &quot;MCP Compliant&quot; (wording &#224; confirmer) dans la page produit sur DS, pour que Agathe puisse cocher au moment de sa v&#233;rification du zip.&#160;&lt;/p&gt;
&lt;h1&gt;&lt;a name=&quot;Specificationtechnique&quot;&gt;&lt;/a&gt;&lt;b&gt;Specification technique&lt;/b&gt;&lt;/h1&gt;

&lt;p&gt;Un produit coch&#233;, sera enregistr&#233; en base avec une nouvelle propri&#233;t&#233; &quot;MCP Complaint YES/NO.&#160;&lt;/p&gt;

&lt;p&gt;Par defaut, tout les zips sont en &quot;NO&quot; jusqu&apos;&#224; ce que la coche soit coch&#233;e par Agathe&#160; et le produit sera enregistr&#233; en YES.&#160;&#160;&lt;/p&gt;

&lt;p&gt;Colonne &quot;MCP Server&quot; &#224; ajouter dans le table de l&apos;onglet ZIP dans la page produit DisneyStore.&#160;&lt;/p&gt;
&lt;h1&gt;&lt;a name=&quot;Crit%C3%A8resd%27Acceptation&quot;&gt;&lt;/a&gt;&lt;b&gt;Crit&#232;res d&apos;Acceptation&lt;/b&gt;&lt;/h1&gt;

&lt;p&gt;&#160;&lt;b&gt;CA1 -&lt;/b&gt;&#160;Une nouvelle colonne nomm&#233;e &lt;tt&gt;MCP Server&lt;/tt&gt;&#160;est ajout&#233;e dans le tableau des ZIPs soumis sur la page produit de DisneyStore (DS).&#160;Chaque ligne de ZIP dans ce tableau doit contenir une &lt;b&gt;case &#224; cocher&lt;/b&gt; (checkbox) dans la nouvelle colonne &lt;tt&gt;MCP Compliant&lt;/tt&gt;.&lt;/p&gt;
```

> **Note** : Description complète disponible dans le fichier XML : `../Jira/MME/MME-1436.xml`

## ✅ Critères d'acceptation

[À extraire manuellement depuis le XML - section Acceptance Criteria]

## 💻 Informations techniques

[À extraire manuellement depuis les commentaires du XML]

## 🎨 Designs

[À extraire manuellement depuis le XML - liens Figma]

## 📝 Commentaires de l'équipe

[À extraire manuellement depuis le XML - balise <comment>]

---

**Date d'extraction** : 2025-11-18
**Fichier source** : Jira/MME/MME-1436.xml
