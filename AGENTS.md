# AGENTS.md — Conventions du projet

Ce fichier est la source de vérité pour tout agent (Claude Code, Copilot, humain) qui travaille sur ce repo.
Lire aussi `docs/plan-action.md` et, si présent, le `AGENTS.md` du module concerné.

## Architecture

- Logique métier partagée en **Kotlin Multiplatform** (`shared/`). UI **Compose** côté Android (`android/`), **SwiftUI** côté iOS (`ios/`).
- Un module par feature. Arborescence :
  - `shared/core` — réseau (Ktor), persistance (SQLDelight), DI (Koin), MVI, logging.
  - `shared/features/<feature>` — domaine, use cases, Store MVI, `UiState`/`Intent`.
  - `shared/features/<feature>-api` — contrats publics (navigation, événements) consommés par les autres features.
  - `android/features/<feature>` — écrans Compose.
  - `ios/Features/<Feature>` — package SPM SwiftUI.
  - `android/app`, `ios/App` — composition root, aucune logique.
- Export Swift via **SKIE**. Un seul `Shared.xcframework` au départ.

## Règles de dépendances (vérifiées par Konsist, non négociables)

- `feature → feature-api → core`. **Jamais** `feature → feature`.
- `core` ne dépend d'aucune feature.
- Les modules UI ne contiennent ni appel réseau ni accès base de données.
- Pas d'`allprojects {}`, pas de plugin appliqué par héritage implicite : chaque module déclare ce qu'il utilise.
- Toutes les versions viennent de `gradle/libs.versions.toml`.

## Conventions de code

- Kotlin : detekt, config `config/detekt.yml`. Swift : SwiftLint, config `.swiftlint.yml`.
- Nommage : `AuthStore`, `AuthUiState`, `AuthIntent`, `AuthScreen` (Compose), `AuthView` (SwiftUI).
- Tests : un test unitaire par use case et par Store. Un test UI par écran et par plateforme.
- Commits : Conventional Commits (`feat(cart): ...`). Un commit par étape du plan.

## Commandes

Les commandes de build varient selon l'approche : voir la section **Approche** de `CLAUDE.md`.
Commandes communes :

- `./scripts/bench/run-all.sh` — exécute la grille de mesure, écrit `bench/results-<date>.json`.
- `./scripts/check-architecture.sh` — Konsist + detekt + SwiftLint.

## Définition de "done"

Une tâche est terminée quand :
1. Les deux apps compilent (`./scripts/build-android.sh` et `./scripts/build-ios.sh`).
2. `./scripts/check-architecture.sh` passe.
3. Les tests du module modifié passent.
4. Un commit Conventional Commits est fait.
5. Si une décision structurante a été prise, une ADR est ajoutée dans `docs/adr/`.

## Ce qu'un agent ne doit jamais faire

- Introduire une dépendance `feature → feature`.
- Modifier `scripts/bench/` ou `.claude/skills/` dans ce repo (ils appartiennent au template).
- Désactiver un test ou une règle Konsist pour faire passer un build.
- Changer d'approche de build (voir interdits spécifiques dans `CLAUDE.md`).

## Économie de contexte et fiabilité

Objectif : minimiser les tokens consommés sans sacrifier la fiabilité.

### Lecture
- Ne lire un fichier que si la tâche l'exige. Jamais `cat` d'un dossier entier ni de fichiers générés (`build/`, `bazel-*`, `*.xcodeproj`, lockfiles).
- Pour les gros fichiers, lire par plage de lignes ou via `grep -n` d'abord.
- Les skills chargent leurs `references/` à la demande : ne lire que celle de l'approche courante.
- Ne pas relire un fichier déjà lu dans la session sauf s'il a été modifié.

### Commandes
- Toujours rediriger les sorties volumineuses : `./gradlew ... -q 2>&1 | tail -40`, `bazel build ... 2>&1 | grep -E "ERROR|error:|FAILED" | head -30`, `xcodebuild ... 2>&1 | grep -E "error:|warning: .*deprecated|BUILD" | head -30`.
- Jamais de `--info`, `--debug`, `--stacktrace` ou `-s` sauf pour diagnostiquer une erreur précise, et alors filtrer avec `grep`.
- Une seule tentative de build après une correction. Si ça échoue deux fois de suite sur la même erreur, s'arrêter, résumer le problème en 5 lignes et demander.

### Travail par étapes
- Une étape du plan = un commit. Terminer et commiter avant de passer à la suivante.
- Avant chaque étape, annoncer en 2 lignes ce qui va être fait. Pas de récapitulatif long en fin d'étape : le commit fait foi.
- Pas de réécriture complète d'un fichier pour une modification locale : éditer la zone concernée.

### Fiabilité
- Ne jamais deviner une API ou une version : lire `libs.versions.toml`, ou la doc officielle si un outil de recherche est disponible, sinon demander.
- Ne jamais désactiver un test, une règle Konsist ou un warning pour faire passer un build.
- Si une commande ou un outil est absent (bazel, xcodebuild, simulateur), le dire immédiatement plutôt que de contourner.
- Vérifier la définition de "done" avant de déclarer une tâche terminée.

### Mesure
- À la fin de chaque session, relever `/cost` et noter dans `docs/frictions.md` : date, étape du plan, tokens, nombre d'interventions humaines.
