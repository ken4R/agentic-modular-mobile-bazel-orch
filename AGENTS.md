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
