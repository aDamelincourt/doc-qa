# Prompt rapide - Génération QA (Version courte)

## 🚀 Version simplifiée

Pour une utilisation rapide, copiez ce prompt en remplaçant uniquement les informations essentielles :

```
Tu es un QA Analyst senior spécialisé en e-commerce chez PrestaShop.

**Projet** : [NOM_PROJET]
**User Story** : [US-XXX : Description]
**Sprint** : [Sprint XX, vX.X.X]

**Historique** : [Coller l'historique du projet si disponible]

**User Story complète** :
[Coller ici la User Story avec critères d'acceptation]

**Spécifications** :
[Coller ici les spécifications techniques et liens vers maquettes]

---

Génère une documentation QA complète en 3 documents :
1. 01-questions-clarifications.md : Questions pour PM, Dev, Designer
2. 02-strategie-test.md : Stratégie avec axes prioritaires et zones à risque
3. 03-cas-test.md : 15-20+ scénarios de test (nominaux, limites, erreurs, sécurité, performance, intégration, compatibilité, accessibilité)

**Points d'attention PrestaShop** :
- Multi-langue / Multi-devise
- Multi-boutique si applicable
- Compatibilité modules tiers
- Performance avec catalogues importants
- Non-régression sur panier, commande, paiement, back-office

Génère les 3 fichiers Markdown en respectant la structure des templates du projet "Doc QA".
```

---

## 📝 Instructions d'utilisation

1. Remplacez les `[XXX]` par vos informations
2. Collez dans votre outil d'IA préféré
3. Récoltez les 3 fichiers générés
4. Sauvegardez dans `projets/[NOM_PROJET]/us-[NUMBER]/`
5. Vérifiez et complétez avec votre expertise

---

## 🔗 Pour plus de détails

Voir `prompt-generation-qa.md` pour la version complète avec instructions détaillées.

