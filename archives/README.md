# Archives des traitements

Ce dossier contient les archives des traitements de documentation QA.

## Structure

Les archives sont organisées de la même manière que les projets actifs :

```
archives/
├── ACCOUNT/
│   └── us-XXXX/          # Archives des US ACCOUNT
└── SPEX/
    └── us-XXXX/          # Archives des US SPEX
```

## Utilisation

### Archiver un ticket spécifique

```bash
./scripts/archive-treatments.sh --ticket SPEX-2990
```

### Archiver tous les tickets d'un projet

```bash
./scripts/archive-treatments.sh --project SPEX
```

### Archiver les traitements anciens (> 90 jours)

```bash
./scripts/archive-treatments.sh --older-than 90
```

### Voir ce qui serait archivé (sans le faire)

```bash
./scripts/archive-treatments.sh --older-than 90 --dry-run
```

### Lister tous les traitements

```bash
./scripts/archive-treatments.sh --list
```

## Historique d'archivage

L'historique des archives est conservé dans `archive-history.json` avec :
- La clé du ticket
- Le chemin original
- Le chemin d'archivage
- La date de traitement
- La date d'archivage

## Notes

- Les archives sont des **copies** des dossiers originaux (les originaux ne sont pas supprimés par défaut)
- Pour supprimer les originaux après archivage, décommenter la ligne dans le script
- Les archives conservent toute la structure et les fichiers de documentation

