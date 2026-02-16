# 🔧 Correction - Accès aux Test Steps Xray Natifs

## 📋 Problème identifié

**Situation actuelle** : Le serveur MCP Xray récupère les test steps depuis la **description** du ticket Jira, alors que les test steps Xray natifs sont stockés dans des **champs personnalisés Xray** dans Jira.

**Problème** : Les test steps dans la description sont une représentation textuelle, pas les vrais test steps Xray qui sont gérés par l'application Xray.

---

## ✅ Solution implémentée

### Nouvelle approche : Priorité aux test steps natifs

Le serveur a été modifié pour :

1. **Essayer d'abord de récupérer les test steps Xray natifs**
   - Recherche dans les champs personnalisés Jira
   - Identification des champs contenant des test steps (tableaux avec action/data/result)
   - Extraction des test steps natifs

2. **Fallback sur la description si aucun step natif**
   - Si aucun test step natif n'est trouvé
   - Utilise les test steps parsés depuis la description (comme avant)
   - Indique la source : `description`

### Fonctions créées

1. **`getNativeXrayTestSteps(testKey)`**
   - Récupère tous les champs du ticket
   - Cherche les champs personnalisés contenant des test steps
   - Retourne les test steps natifs si trouvés

2. **`getTestStepsFromDescription(testKey)`**
   - Récupère les test steps depuis la description (fallback)
   - Parse le format markdown
   - Indique la source comme `description`

3. **`getTestStepsFromJira(testKey)`** (fonction principale)
   - Essaie d'abord les test steps natifs
   - Utilise la description en fallback
   - Retourne toujours un résultat avec indication de la source

---

## 📊 Format de réponse

### Test steps natifs (priorité)

```json
{
  "key": "XSP-1",
  "summary": "PaymentTest_1_MC",
  "issueType": "Test",
  "stepsCount": 8,
  "steps": [
    {
      "id": "1",
      "action": "Set the initial investment amount",
      "data": "- Initial Amount: 100",
      "result": "- Initial amount field accepts the value 100",
      "source": "native_xray"
    }
  ],
  "source": "native_xray_fields"
}
```

### Test steps depuis description (fallback)

```json
{
  "key": "XSP-1",
  "summary": "PaymentTest_1_MC",
  "issueType": "Test",
  "stepsCount": 8,
  "steps": [
    {
      "id": "1",
      "title": "Configure Initial Investment Parameters",
      "action": "Set the initial investment amount",
      "data": "- Initial Amount: 100",
      "result": "- Initial amount field accepts the value 100",
      "source": "description"
    }
  ],
  "source": "description"
}
```

---

## 🔍 Comment identifier les test steps natifs

### Méthode 1 : Recherche dans les champs personnalisés

Le serveur recherche automatiquement dans tous les champs personnalisés (`customfield_*`) :
- Tableaux non vides
- Objets contenant `action`, `data`, `result`, ou `step`
- Structure typique des test steps Xray

### Méthode 2 : Via l'API Xray GraphQL (si disponible)

Si l'authentification GraphQL fonctionne, utiliser :
```graphql
{
  getTest(issueId: "XSP-1") {
    steps {
      id
      action
      data
      result
    }
  }
}
```

---

## 🎯 Avantages de cette approche

1. **Priorité aux données natives** : Utilise les vrais test steps Xray si disponibles
2. **Fallback intelligent** : Utilise la description si pas de steps natifs
3. **Source claire** : Indique toujours d'où viennent les test steps
4. **Compatibilité** : Fonctionne même si les steps sont seulement dans la description

---

## 📝 Notes importantes

### Pour XSP-1 actuellement

- Les test steps sont **uniquement dans la description**
- Aucun test step natif Xray n'a été trouvé dans les champs personnalisés
- Le serveur utilisera donc la description (comme avant)
- Mais il cherchera d'abord les steps natifs pour d'autres tickets

### Pour les futurs tickets

- Si des test steps Xray natifs sont configurés, ils seront utilisés en priorité
- La description reste disponible en fallback
- La source est toujours indiquée dans la réponse

---

## 🔧 Prochaines améliorations possibles

1. **Identifier le champ personnalisé exact** pour les test steps Xray
   - Peut nécessiter une configuration spécifique
   - Ou une recherche plus approfondie dans la structure

2. **Utiliser l'API Xray GraphQL** si l'authentification fonctionne
   - Meilleure méthode pour récupérer les steps natifs
   - Nécessite de résoudre le problème d'authentification GraphQL

3. **Cache des champs personnalisés** pour améliorer les performances

---

**Dernière mise à jour** : 2025-01-19
