# 🔧 Correction du serveur MCP Xray pour GraphQL

## ✅ Modifications effectuées

Le serveur MCP Xray a été mis à jour pour utiliser **GraphQL** au lieu de REST pour récupérer les test steps.

### Changements apportés

1. **Nouvelle fonction `makeGraphQLRequest()`**
   - Gère les requêtes GraphQL vers Xray Cloud
   - Utilise le même token d'authentification que REST
   - Gère les erreurs GraphQL spécifiques

2. **Mise à jour de `get_test_steps`**
   - Utilise maintenant GraphQL avec la query `GetTestSteps`
   - Récupère : id, action, data, result, attachments

3. **Mise à jour de `get_test_info`**
   - Utilise GraphQL avec la query `GetTestInfo`
   - Récupère : id, key, summary, testType, steps, project

### Code GraphQL utilisé

**Query pour les test steps** :
```graphql
query GetTestSteps($issueId: String!) {
  getTest(issueId: $issueId) {
    testType {
      name
    }
    steps {
      id
      action
      data
      result
      attachments {
        filename
        downloadLink
      }
    }
  }
}
```

**Query pour les infos du test** :
```graphql
query GetTestInfo($issueId: String!) {
  getTest(issueId: $issueId) {
    id
    key
    summary
    testType {
      name
    }
    steps {
      id
      action
      data
      result
    }
    project {
      key
      name
    }
  }
}
```

---

## ⚠️ Problème d'authentification GraphQL

### Problème identifié

Le token obtenu via l'endpoint REST `/authenticate` ne fonctionne **pas** avec l'API GraphQL.

**Erreur rencontrée** :
```json
{
  "error": "Could not find authentication data on request"
}
```

### Causes possibles

1. **GraphQL nécessite un token différent**
   - Peut-être un "API Access Token" au lieu du token REST
   - Format d'authentification différent

2. **Format d'en-tête différent**
   - Peut nécessiter un header différent (X-Authorization, etc.)
   - Ou un format de token différent

3. **Configuration spécifique requise**
   - GraphQL peut nécessiter une configuration supplémentaire
   - Ou des permissions spécifiques sur les clés API

---

## 🔍 Solutions à explorer

### Solution 1 : Vérifier la documentation Xray GraphQL

Consulter la documentation officielle :
- [Xray Cloud GraphQL API](https://docs.getxray.app/display/XRAYCLOUD/GraphQL+API)
- Vérifier le format d'authentification exact

### Solution 2 : Utiliser un API Access Token

Si GraphQL nécessite un token différent :
1. Générer un "API Access Token" dans Xray Settings
2. Utiliser ce token pour GraphQL
3. Peut-être utiliser la mutation `getToken` pour obtenir un token GraphQL

### Solution 3 : Vérifier les permissions

Vérifier que les clés API ont les permissions pour :
- Accéder à GraphQL
- Lire les test steps
- Accéder aux tests

### Solution 4 : Alternative - Utiliser l'API Jira

Si GraphQL ne fonctionne pas, une alternative serait :
- Utiliser l'API Jira pour récupérer les informations du ticket
- Les test steps peuvent être dans les champs personnalisés Jira
- Ou dans la description du ticket

---

## 📊 État actuel

- ✅ **Serveur modifié** : Code GraphQL ajouté
- ✅ **Syntaxe correcte** : Le serveur compile sans erreur
- ❌ **Authentification GraphQL** : Ne fonctionne pas avec le token REST
- ⚠️ **À résoudre** : Format d'authentification GraphQL

---

## 🎯 Prochaines étapes

1. **Vérifier la documentation Xray GraphQL** pour le format d'authentification exact
2. **Tester avec un API Access Token** si nécessaire
3. **Vérifier les permissions** des clés API
4. **Alternative** : Utiliser l'API Jira si GraphQL n'est pas accessible

---

## 📝 Note

Le serveur est maintenant prêt à utiliser GraphQL une fois le problème d'authentification résolu. Le code est en place et fonctionnel, il ne reste qu'à corriger l'authentification.

---

**Dernière mise à jour** : 2025-01-19
