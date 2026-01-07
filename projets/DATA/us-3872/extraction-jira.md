# Extraction Jira - DATA-3872

## 📋 Informations générales

**Clé du ticket** : DATA-3872
**Titre/Summary** : Map Warehouse to Data Graph for Linked Audiences (Beta)
**Type** : Story
**Statut** : [À extraire manuellement]
**Lien Jira** : https://forge.prestashop.com/browse/DATA-3872

## 📝 Description / User Story

```
    This file is an XML representation of an issue
                    &lt;h1&gt;&lt;a name=&quot;&quot;&gt;&lt;/a&gt;&lt;font color=&quot;#4c9aff&quot;&gt;Story&lt;/font&gt;&lt;/h1&gt;

&lt;p&gt;Afin d&apos;&#233;viter l&apos;utilisation syst&#233;matique de Reverse ETL pour enrichir les donn&#233;es Segment, En tant que Data Engineer, Je veux mapper les Explore GMV et PS Checkout Orders du data warehouse au data graph.&lt;/p&gt;

&lt;h2&gt;&lt;a name=&quot;&quot;&gt;&lt;/a&gt;&lt;font color=&quot;#4c9aff&quot;&gt;Acceptance Criteria&lt;/font&gt;&lt;/h2&gt;

&lt;p&gt;AC.1 - Mapping de l&apos;Explore GMV Etant donn&#233; que l&apos;Explore GMV existe dans le data warehouse Lorsque le mapping est effectu&#233; vers le data graph Alors les donn&#233;es GMV sont disponibles et consommables dans le data graph sans n&#233;cessiter de Reverse ETL.&lt;/p&gt;

&lt;p&gt;AC.2 - Mapping de l&apos;Explore PS Checkout Orders Etant donn&#233; que l&apos;Explore PS Checkout Orders existe dans le data warehouse Lorsque le mapping est effectu&#233; vers le data graph Alors les donn&#233;es PS Checkout Orders sont disponibles et consommables dans le data graph sans n&#233;cessiter de Reverse ETL.&lt;/p&gt;

&lt;p&gt;AC.3 - Validation de la synchronisation des donn&#233;es Etant donn&#233; que les deux mappings (GMV et PS Checkout Orders) sont compl&#233;t&#233;s Lorsque des donn&#233;es sont mises &#224; jour ou ins&#233;r&#233;es dans le data warehouse pour ces Explore Alors ces donn&#233;es sont automatiquement refl&#233;t&#233;es dans le data graph dans un d&#233;lai d&#233;fini (par exemple, moins de 5 minutes).&lt;/p&gt;

&lt;p&gt;AC.4 - Monitoring et Alerting Etant donn&#233; que les mappings sont en production Lorsque le flux de synchronisation rencontre une erreur ou une latence anormale Alors une alerte est d&#233;clench&#233;e pour l&apos;&#233;quipe Data Engineering.&lt;/p&gt;
```

> **Note** : Description complète disponible dans le fichier XML : `../Jira/DATA/DATA-3872.xml`

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
**Fichier source** : Jira/DATA/DATA-3872.xml
