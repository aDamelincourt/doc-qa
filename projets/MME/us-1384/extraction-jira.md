# Extraction Jira - MME-1384

## 📋 Informations générales

**Clé du ticket** : MME-1384
**Titre/Summary** : [Compte Addons] Ajouter bouton &quot;leave a review&quot; - Order Detail Page
**Type** : Story
**Statut** : [À extraire manuellement]
**Lien Jira** : https://forge.prestashop.com/browse/MME-1384

## 📝 Description / User Story

```
    This file is an XML representation of an issue
                    &lt;h1&gt;&lt;a name=&quot;Contexte&quot;&gt;&lt;/a&gt;&lt;b&gt;Contexte&lt;/b&gt;&lt;/h1&gt;

&lt;p&gt;Les marchands pr&#233;sents sur la marketplace PrestaShop Addons ont du mal &#224; trouver suffisamment de &quot;social proof&quot;, telles que les avis des autres clients, pour les rassurer et pousser &#224; la conversion. Cela s&apos;explique par un processus de soumission d&apos;avis confus et mal communiqu&#233; aux clients, qui ignorent souvent les r&#232;gles ou le d&#233;lai limit&#233; pour laisser un avis. En cons&#233;quence, des avis et commentaires pr&#233;cieux sont perdus ou moins cr&#233;dibles.&lt;/p&gt;
&lt;h1&gt;&lt;a name=&quot;ObjectifetSolution&quot;&gt;&lt;/a&gt;&lt;b&gt;Objectif et Solution&lt;/b&gt;&lt;/h1&gt;

&lt;p&gt;Sur le d&#233;tails de chaque Order, ajouter un petit bouton &quot;laisser un avis&quot; qui renvoie vers la page review du compte filtr&#233;e sur la bonne commande&lt;/p&gt;
&lt;h1&gt;&lt;a name=&quot;Specificationtechnique&quot;&gt;&lt;/a&gt;&lt;b&gt;Specification technique&lt;/b&gt;&lt;/h1&gt;

&lt;p&gt;C&#244;t&#233; Back, r&#233;cup&#233;rer l&apos;information de l&apos;avis d&#233;pos&#233; sur la commande :&#160;&lt;/p&gt;
&lt;ul&gt;
	&lt;li&gt;Travailler sur le call GET /request3/clientaccount/orders/{id_order}&lt;/li&gt;
	&lt;li&gt;V&#233;rifier dans la table ps_avis_verifie_product_review qu&apos;un avis n&apos;est pas d&#233;j&#224; d&#233;pos&#233; pour la commande concern&#233;e&lt;/li&gt;
	&lt;li&gt;V&#233;rifier dans la table ps_avis_verifie_order_url qu&apos;un lien est d&#233;j&#224; g&#233;n&#233;r&#233; pour la commande concern&#233;e&#160;&#160;&lt;/li&gt;
	&lt;li&gt;Ajouter un champ &quot;review_link&quot; dans la r&#233;ponse avec le lien r&#233;cup&#233;r&#233; de&#160;&lt;tt&gt;ps_avis_verifie_order_url&lt;/tt&gt;&lt;/li&gt;
&lt;/ul&gt;


&lt;p&gt;C&#244;t&#233; Front, afficher le CTA si le champ &quot;review_link&quot; n&apos;est pas vide&#160;&lt;/p&gt;
&lt;h1&gt;&lt;a name=&quot;Maquettes&quot;&gt;&lt;/a&gt;&lt;b&gt;Maquettes&lt;/b&gt;&lt;/h1&gt;
```

> **Note** : Description complète disponible dans le fichier XML : `../Jira/MME/MME-1384.xml`

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
**Fichier source** : Jira/MME/MME-1384.xml
