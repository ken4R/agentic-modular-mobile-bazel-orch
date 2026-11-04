---
name: run-benchmarks
description: Exécute la grille de mesure comparative des POC (build à froid, incrémental, cache hit, lignes de config, timings d'ajout de feature) et produit le JSON de résultats et un tableau Markdown. Utiliser quand l'utilisateur veut mesurer, benchmarker, chronométrer, comparer les temps de build, remplir la grille du plan d'action, ou à la fin de chaque semaine de POC.
---

# run-benchmarks

Les scripts sont dans `scripts/bench/`. **Ne pas les modifier** dans ce repo : ils doivent rester identiques dans les trois POC.

## Procédure

1. S'assurer que l'arbre git est propre et noter le SHA : `git rev-parse --short HEAD`.
2. Fermer Android Studio et Xcode (ils polluent les mesures).
3. Lancer `./scripts/bench/run-all.sh` — il appelle dans l'ordre :
   - `cold-android.sh`, `cold-ios.sh` (cache vidé, 3 runs, médiane)
   - `incremental.sh` (modifie une ligne dans `shared/features/cart`, rebuild, 3 runs, restaure)
   - `cache-hit.sh` (2e build sur la même révision, ratio de hits lu dans les logs Gradle/Bazel)
   - `config-lines.sh` (`wc -l` sur Gradle + Starlark + Package.swift)
   - lecture de `bench/feature-timings.log` pour le temps d'ajout de feature
4. Résultat : `bench/results-<date>-<sha>.json`.
5. Lancer `./scripts/bench/to-markdown.sh bench/results-<date>-<sha>.json` et coller le tableau dans `docs/plan-action.md`, section 5, colonne de l'approche courante.
6. Noter dans `docs/frictions.md` tout ce qui a perturbé la mesure.
7. Commit : `chore(bench): results <date>`.

## Métriques manuelles (à demander à l'utilisateur)

- Durée du pipeline PR en CI (lire l'UI CI, médiane de 3).
- Note d'expérience IDE /5 (autocomplétion, debug KMP depuis Xcode).
