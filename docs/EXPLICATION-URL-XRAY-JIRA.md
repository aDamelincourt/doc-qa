# 🌐 Pourquoi l'URL Xray est différente de l'URL Jira ?

## 📋 Les deux URLs

### URL Jira (votre instance)
```
https://prestashop-jira.atlassian.net/
```
- C'est votre instance Jira Cloud
- Où vous accédez à l'interface web Jira
- Où se trouvent vos tickets, projets, etc.

### URL Xray Cloud API
```
https://xray.cloud.getxray.app/api/v2
```
- C'est l'API cloud de Xray
- Service hébergé séparément par Xray
- Point d'entrée pour l'API REST de Xray

---

## 🔍 Pourquoi cette différence ?

### 1. Architecture Xray Cloud

Xray est une **application tierce** (add-on) pour Jira qui fonctionne en mode **Cloud** :

- **Jira Cloud** : Votre instance Jira hébergée par Atlassian
- **Xray Cloud** : Service cloud séparé hébergé par Xray (Xpand IT)

### 2. Modèle de service

Xray Cloud utilise un **modèle SaaS (Software as a Service)** :

```
┌─────────────────────────────────────┐
│   Votre instance Jira Cloud         │
│   https://prestashop-jira.           │
│   atlassian.net                      │
│                                      │
│   - Tickets                          │
│   - Projets                          │
│   - Interface utilisateur           │
└──────────────┬──────────────────────┘
               │
               │ Synchronisation
               │ (via API Jira)
               │
┌──────────────▼──────────────────────┐
│   Xray Cloud Service                │
│   https://xray.cloud.getxray.app   │
│                                      │
│   - API REST Xray                    │
│   - Gestion des tests                │
│   - Test steps                       │
│   - Exécutions de tests              │
└─────────────────────────────────────┘
```

### 3. Avantages de cette architecture

✅ **Performance** : Service dédié optimisé pour l'API
✅ **Scalabilité** : Peut gérer plusieurs instances Jira
✅ **Disponibilité** : Service indépendant de votre instance Jira
✅ **Sécurité** : Authentification centralisée via API keys
✅ **Mises à jour** : Xray peut mettre à jour son service sans impacter Jira

---

## 🔐 Authentification

### Comment ça fonctionne ?

1. **Vous vous authentifiez auprès de Xray Cloud** avec vos clés API
   ```
   POST https://xray.cloud.getxray.app/api/v2/authenticate
   ```

2. **Xray Cloud se connecte à votre Jira** en arrière-plan
   - Utilise les informations de votre compte Jira
   - Accède aux données via l'API Jira
   - Synchronise les données entre les deux services

3. **Vous obtenez un token** pour accéder à l'API Xray
   - Token valide 30 minutes
   - Permet d'accéder aux tests de votre instance Jira

---

## 📊 Comparaison

| Aspect | Jira Cloud | Xray Cloud API |
|--------|------------|----------------|
| **URL** | `prestashop-jira.atlassian.net` | `xray.cloud.getxray.app` |
| **Type** | Instance Jira | Service API cloud |
| **Accès** | Interface web + API Jira | API REST uniquement |
| **Authentification** | Compte Jira | API Keys Xray |
| **Données** | Tous les tickets, projets | Tests Xray uniquement |
| **Hébergement** | Atlassian | Xpand IT (Xray) |

---

## 🔗 Comment les deux sont liés

### Dans la configuration MCP

Vous avez **deux serveurs MCP** configurés :

1. **Jira MCP** (`@mcp-devtools/jira`)
   - Accède directement à votre instance Jira
   - URL : `https://prestashop-jira.atlassian.net/`
   - Authentification : API Key Jira
   - Permet d'accéder aux tickets, projets, etc.

2. **Xray MCP** (notre serveur personnalisé)
   - Accède à l'API Xray Cloud
   - URL : `https://xray.cloud.getxray.app/api/v2`
   - Authentification : Client ID + Secret Xray
   - Permet d'accéder aux tests, test steps, etc.

### Synchronisation

Xray Cloud se synchronise automatiquement avec votre instance Jira :
- Les tests Xray sont liés aux tickets Jira
- Les test steps sont stockés dans Xray mais référencent les tickets Jira
- Les exécutions de tests sont synchronisées entre les deux

---

## 💡 Exemple concret

### Pour accéder au test XSP-1

1. **Via Jira** (interface web) :
   ```
   https://prestashop-jira.atlassian.net/browse/XSP-1
   ```
   - Vous voyez le ticket dans Jira
   - Vous voyez les informations de base

2. **Via Xray Cloud API** :
   ```
   GET https://xray.cloud.getxray.app/api/v2/test/XSP-1/step
   ```
   - Vous récupérez les test steps détaillés
   - Données spécifiques à Xray (actions, données, résultats attendus)

### Les deux sont complémentaires

- **Jira** : Gestion du ticket, description, statut, etc.
- **Xray** : Détails des tests, étapes de test, exécutions, etc.

---

## 🎯 Résumé

**Pourquoi deux URLs différentes ?**

1. **Xray est un service cloud séparé** de votre instance Jira
2. **Architecture SaaS** : Service hébergé indépendamment
3. **API dédiée** : Optimisée pour les opérations de test
4. **Synchronisation automatique** : Les deux services communiquent en arrière-plan

C'est comme avoir :
- **Votre magasin** (Jira) : où vous gérez vos produits
- **Un entrepôt spécialisé** (Xray) : où sont stockés les détails techniques des tests

Les deux sont connectés et synchronisés, mais servent des objectifs différents !

---

## 📚 Ressources

- [Documentation Xray Cloud](https://docs.getxray.app/display/XRAYCLOUD)
- [Xray Cloud API](https://docs.getxray.app/display/XRAYCLOUD/REST+API)
- [Architecture Xray](https://docs.getxray.app/display/XRAYCLOUD/Architecture)
