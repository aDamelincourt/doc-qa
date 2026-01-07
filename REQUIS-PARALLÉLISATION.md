# Prérequis pour l'Implémentation de la Parallélisation (#9)

## 📋 Vue d'ensemble

Ce document détaille ce qui serait nécessaire pour implémenter l'optimisation #9 (parallélisation) dans `regenerate-all-docs.sh`.

**Gain estimé** : 2-4x plus rapide selon le nombre de CPU disponibles

---

## 🔍 Analyse de l'État Actuel

### Structure actuelle de `regenerate-all-docs.sh`

Le script traite actuellement les fichiers XML de manière **séquentielle** dans une boucle `for` :

```bash
for xml_file in "${xml_files[@]}"; do
    # 1. Parser le XML
    parse_xml_file "$xml_file"
    
    # 2. Déterminer le dossier US
    us_dir="${US_DIRS_CACHE[${project}-${ticket_number}]:-}"
    
    # 3. Vérifier si l'US existe
    if [ -d "$us_dir" ] && [ "$FORCE" = false ]; then
        skipped_count=$((skipped_count + 1))
        continue
    fi
    
    # 4. Créer/régénérer la structure
    # 5. Générer les documents (questions, stratégie, cas de test)
    # 6. Mettre à jour le README
    
    processed_count=$((processed_count + 1))
done
```

### Problèmes pour la parallélisation

1. **Variables globales partagées** : `processed_count`, `skipped_count`, `error_count`
2. **Logs mélangés** : Les logs de plusieurs processus seraient intercalés
3. **Gestion d'erreurs** : `set -euo pipefail` peut causer des problèmes avec les sous-processus
4. **Dépendances** : Les scripts de génération peuvent avoir des dépendances partagées

---

## ✅ Ce qui serait nécessaire

### 1. Extraire la logique de traitement dans une fonction

**Nécessité** : Créer une fonction `process_single_xml_file()` qui traite un seul fichier XML.

**Avantages** :
- Code réutilisable
- Facilite les tests
- Peut être appelée en parallèle

**Structure proposée** :
```bash
process_single_xml_file() {
    local xml_file="$1"
    local force="${2:-false}"
    local result_file="$3"  # Fichier pour stocker le résultat
    
    # Traitement complet d'un fichier XML
    # Retourne : "success|skipped|error|ticket_key"
    # Écrit dans result_file : "status|ticket_key|message"
}
```

---

### 2. Système de gestion des processus parallèles

**Nécessité** : Gérer un pool de processus avec limitation du nombre de processus simultanés.

**Composants nécessaires** :
- Limite du nombre de processus parallèles (ex: nombre de CPU)
- File d'attente des processus
- Détection de la fin des processus
- Nettoyage des processus zombies

**Code proposé** :
```bash
# Détecter le nombre de CPU disponibles
detect_cpu_count() {
    if command -v sysctl &> /dev/null; then
        # macOS
        sysctl -n hw.ncpu
    elif command -v nproc &> /dev/null; then
        # Linux
        nproc
    else
        # Fallback
        echo "4"
    fi
}

MAX_PARALLEL="${MAX_PARALLEL:-$(detect_cpu_count)}"
```

---

### 3. Système de logs thread-safe

**Nécessité** : Éviter que les logs de plusieurs processus se mélangent.

**Solutions possibles** :

#### Option A : Fichiers de log temporaires (recommandé)
```bash
process_single_xml_file() {
    local xml_file="$1"
    local log_file="${TMPDIR:-/tmp}/qa_regen_$(basename "$xml_file" .xml).log"
    
    # Rediriger tous les logs vers le fichier
    exec > >(tee "$log_file") 2>&1
    
    # Traitement...
    
    # À la fin, afficher le contenu du log
    cat "$log_file"
    rm -f "$log_file"
}
```

#### Option B : Verrous de fichiers (plus complexe)
```bash
log_parallel() {
    local message="$1"
    local lock_file="${TMPDIR:-/tmp}/qa_log.lock"
    
    (
        flock -n 9 || exit 1
        echo "$message" >&2
    ) 9>"$lock_file"
}
```

**Recommandation** : Option A (fichiers temporaires) - plus simple et plus fiable

---

### 4. Collecte des résultats

**Nécessité** : Collecter les résultats de chaque processus pour le résumé final.

**Structure proposée** :
```bash
# Fichier de résultats temporaire
RESULTS_FILE="${TMPDIR:-/tmp}/qa_regen_results.txt"

# Dans chaque processus
process_single_xml_file() {
    # ...
    echo "success|$KEY|Traité avec succès" >> "$RESULTS_FILE"
    # ou
    echo "error|$KEY|Erreur: ..." >> "$RESULTS_FILE"
    # ou
    echo "skipped|$KEY|Déjà existant" >> "$RESULTS_FILE"
}

# À la fin, lire tous les résultats
while IFS='|' read -r status ticket_key message; do
    case "$status" in
        success) processed_count=$((processed_count + 1)) ;;
        skipped) skipped_count=$((skipped_count + 1)) ;;
        error) error_count=$((error_count + 1)) ;;
    esac
done < "$RESULTS_FILE"
rm -f "$RESULTS_FILE"
```

---

### 5. Gestion d'erreurs adaptée

**Nécessité** : Adapter `set -euo pipefail` pour les sous-processus.

**Problème** : `set -euo pipefail` dans le script principal peut causer des problèmes avec les processus en arrière-plan.

**Solution** :
```bash
# Dans la fonction de traitement
process_single_xml_file() {
    # Désactiver set -e dans le sous-processus
    set +e
    # Traitement...
    local exit_code=$?
    set -e
    return $exit_code
}

# Dans le script principal
set +e  # Désactiver temporairement pour la gestion des processus
# ... gestion des processus parallèles ...
set -e  # Réactiver
```

---

### 6. Gestion des variables d'environnement

**Nécessité** : S'assurer que les variables nécessaires sont disponibles dans chaque sous-processus.

**Variables à transmettre** :
- `FORCE`
- `DRY_RUN`
- `DEBUG`
- `US_DIRS_CACHE` (tableau associatif - problème !)
- Chemins des scripts (`GENERATE_QUESTIONS_SCRIPT`, etc.)

**Problème** : Les tableaux associatifs Bash ne sont pas hérités par les sous-processus.

**Solution** : Convertir le cache en format exportable ou le recréer dans chaque processus.

```bash
# Option A : Exporter le cache comme fichier
export_us_dirs_cache() {
    local cache_file="${TMPDIR:-/tmp}/qa_us_dirs_cache.txt"
    for key in "${!US_DIRS_CACHE[@]}"; do
        echo "${key}|${US_DIRS_CACHE[$key]}" >> "$cache_file"
    done
    echo "$cache_file"
}

# Dans chaque processus
load_us_dirs_cache() {
    local cache_file="$1"
    declare -A US_DIRS_CACHE
    while IFS='|' read -r key value; do
        US_DIRS_CACHE["$key"]="$value"
    done < "$cache_file"
}
```

---

### 7. Barre de progression (optionnel mais recommandé)

**Nécessité** : Afficher la progression du traitement parallèle.

**Solution proposée** :
```bash
show_progress() {
    local total="$1"
    local current="$2"
    local percent=$((current * 100 / total))
    printf "\r📊 Progression : [%-50s] %d%% (%d/%d)" \
        "$(printf '#%.0s' $(seq 1 $((percent / 2))))" \
        "$percent" "$current" "$total"
}
```

---

## 📝 Structure Complète Proposée

```bash
#!/bin/bash

# Configuration
MAX_PARALLEL="${MAX_PARALLEL:-$(detect_cpu_count)}"
RESULTS_FILE="${TMPDIR:-/tmp}/qa_regen_results_$$.txt"
LOG_DIR="${TMPDIR:-/tmp}/qa_regen_logs_$$"

# Fonction pour traiter un seul fichier XML
process_single_xml_file() {
    local xml_file="$1"
    local force="${2:-false}"
    local ticket_key=""
    local status="error"
    local message=""
    
    # Logs vers un fichier temporaire
    local log_file="$LOG_DIR/$(basename "$xml_file" .xml).log"
    mkdir -p "$LOG_DIR"
    
    {
        # Parser le XML
        if ! parse_xml_file "$xml_file" 2>/dev/null; then
            status="error"
            message="Impossible d'extraire les informations"
            echo "$status|$ticket_key|$message" >> "$RESULTS_FILE"
            return 1
        fi
        
        ticket_key="$KEY"
        project=$(basename "$(dirname "$xml_file")")
        ticket_number=$(get_ticket_number "$KEY")
        
        # Charger le cache US_DIRS
        load_us_dirs_cache
        
        us_dir="${US_DIRS_CACHE[${project}-${ticket_number}]:-}"
        if [ -z "$us_dir" ]; then
            us_dir="$PROJETS_DIR/$project/us-$ticket_number"
        fi
        
        # Vérifier si l'US existe
        if [ -d "$us_dir" ] && [ "$force" = false ]; then
            status="skipped"
            message="US existe déjà"
            echo "$status|$ticket_key|$message" >> "$RESULTS_FILE"
            return 0
        fi
        
        # Traitement complet...
        # (génération des documents)
        
        status="success"
        message="Traitement réussi"
        echo "$status|$ticket_key|$message" >> "$RESULTS_FILE"
        
    } > "$log_file" 2>&1
    
    # Afficher le log à la fin
    cat "$log_file"
    rm -f "$log_file"
}

# Gestion du pool de processus
pids=()
for xml_file in "${xml_files[@]}"; do
    # Attendre si on a atteint le maximum
    while [ ${#pids[@]} -ge $MAX_PARALLEL ]; do
        for i in "${!pids[@]}"; do
            if ! kill -0 "${pids[$i]}" 2>/dev/null; then
                wait "${pids[$i]}"
                unset pids[$i]
            fi
        done
        # Réindexer le tableau
        pids=("${pids[@]}")
        sleep 0.1
    done
    
    # Lancer le traitement en arrière-plan
    process_single_xml_file "$xml_file" "$FORCE" &
    pids+=($!)
done

# Attendre la fin de tous les processus
for pid in "${pids[@]}"; do
    wait "$pid"
done

# Collecter les résultats
# ...
```

---

## ⚠️ Défis et Limitations

### 1. Compatibilité Bash 3.x
- Les tableaux associatifs (`declare -A`) ne sont pas disponibles dans Bash 3.x (macOS par défaut)
- **Solution** : Utiliser des fichiers temporaires pour stocker les caches

### 2. Gestion des erreurs
- `set -euo pipefail` peut causer des problèmes avec les processus en arrière-plan
- **Solution** : Désactiver temporairement dans les sous-processus

### 3. Logs mélangés
- Les logs de plusieurs processus peuvent s'intercaler
- **Solution** : Utiliser des fichiers de log temporaires par processus

### 4. Performance
- Le surcoût de gestion des processus peut annuler les gains si peu de fichiers
- **Recommandation** : Activer la parallélisation seulement si > 5 fichiers

### 5. Dépendances partagées
- Les scripts de génération peuvent avoir des dépendances (fichiers, caches)
- **Solution** : S'assurer que les caches sont thread-safe (déjà fait avec les optimisations précédentes)

---

## 🎯 Recommandations d'Implémentation

### Phase 1 : Préparation (1-2 heures)
1. ✅ Extraire la logique de traitement dans `process_single_xml_file()`
2. ✅ Créer un système de logs thread-safe
3. ✅ Créer un système de collecte de résultats

### Phase 2 : Parallélisation de base (2-3 heures)
1. ✅ Implémenter la gestion du pool de processus
2. ✅ Gérer les variables d'environnement
3. ✅ Adapter la gestion d'erreurs

### Phase 3 : Améliorations (1-2 heures)
1. ✅ Ajouter une barre de progression
2. ✅ Optimiser la détection du nombre de CPU
3. ✅ Ajouter des tests

### Phase 4 : Tests et validation (1-2 heures)
1. ✅ Tester avec différents nombres de fichiers
2. ✅ Vérifier la gestion des erreurs
3. ✅ Valider les performances

**Temps total estimé** : 5-9 heures

---

## 🔧 Configuration Proposée

### Option de ligne de commande
```bash
./scripts/regenerate-all-docs.sh [--force] [--parallel N] [--no-parallel]
```

- `--parallel N` : Forcer N processus parallèles (défaut: nombre de CPU)
- `--no-parallel` : Désactiver la parallélisation (mode séquentiel)

### Variables d'environnement
```bash
MAX_PARALLEL=4  # Nombre de processus parallèles
PARALLEL_MIN_FILES=5  # Activer la parallélisation seulement si >= 5 fichiers
```

---

## 📊 Estimation des Gains

### Scénario 1 : 5 fichiers XML
- **Séquentiel** : ~30 secondes
- **Parallèle (4 CPU)** : ~12-15 secondes
- **Gain** : 50-60%

### Scénario 2 : 20 fichiers XML
- **Séquentiel** : ~120 secondes
- **Parallèle (4 CPU)** : ~35-40 secondes
- **Gain** : 65-70%

### Scénario 3 : 50 fichiers XML
- **Séquentiel** : ~300 secondes
- **Parallèle (4 CPU)** : ~80-90 secondes
- **Gain** : 70-75%

**Note** : Les gains réels dépendent de la charge CPU, I/O, et de la complexité des fichiers XML.

---

## ✅ Checklist d'Implémentation

- [ ] Extraire `process_single_xml_file()` fonction
- [ ] Implémenter la détection du nombre de CPU
- [ ] Créer le système de logs thread-safe
- [ ] Créer le système de collecte de résultats
- [ ] Implémenter la gestion du pool de processus
- [ ] Gérer l'export/import du cache US_DIRS_CACHE
- [ ] Adapter la gestion d'erreurs
- [ ] Ajouter les options `--parallel` et `--no-parallel`
- [ ] Ajouter une barre de progression
- [ ] Tester avec différents scénarios
- [ ] Documenter l'utilisation
- [ ] Mettre à jour `OPTIMISATIONS-IMPLÉMENTÉES.md`

---

## 🚀 Conclusion

L'implémentation de la parallélisation est **faisable** mais nécessite :

1. **Refactorisation** : Extraire la logique de traitement dans une fonction
2. **Gestion des processus** : Pool de processus avec limitation
3. **Thread-safety** : Logs et résultats via fichiers temporaires
4. **Compatibilité** : Gérer Bash 3.x (pas de tableaux associatifs dans sous-processus)
5. **Tests** : Valider avec différents scénarios

**Recommandation** : Implémenter seulement si vous avez régulièrement > 10 fichiers XML à traiter, sinon le surcoût de gestion peut annuler les gains.

---

**Date de création** : $(date +"%Y-%m-%d")

