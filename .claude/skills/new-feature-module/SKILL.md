---
name: new-feature-module
description: Crée une nouvelle feature complète du monorepo mobile — module KMP (domaine + Store MVI), module -api, écran Compose, package SPM SwiftUI, tests, et câblage dans les deux apps. Utiliser dès que l'utilisateur veut ajouter, créer ou scaffolder une feature, un module, un écran ou un domaine fonctionnel (ex. "ajoute la feature cart", "crée un module profile"), même s'il ne dit pas "module".
---

# new-feature-module

Produit une feature `<name>` conforme à `AGENTS.md`, identique en structure aux features existantes.
La génération des fichiers de build dépend de l'approche : lire la section **Approche** de `CLAUDE.md`
puis le fichier `references/<approche>.md` correspondant (A, B ou C) avant d'écrire quoi que ce soit.

## Étapes

1. **Vérifier** que `shared/features/<name>` n'existe pas et que `<name>` est en kebab-case.
2. **Chronométrer** : noter l'heure de début dans `bench/feature-timings.log` (format `<name>,start,<ISO8601>`).
3. **Modules KMP** (identiques quelle que soit l'approche) :
   - `shared/features/<name>-api/src/commonMain/kotlin/.../<Name>Api.kt` : interface publique minimale + route de navigation.
   - `shared/features/<name>/src/commonMain/kotlin/...` : `<Name>Store.kt` (MVI), `<Name>UiState.kt`, `<Name>Intent.kt`, `<Name>Repository.kt`, `di/<Name>Module.kt` (Koin).
   - `shared/features/<name>/src/commonTest/kotlin/...` : `<Name>StoreTest.kt` avec au moins un cas par Intent.
4. **Fichiers de build** selon `references/<approche>.md`.
5. **Android** : `android/features/<name>/.../<Name>Screen.kt` (Compose, consomme le Store), test UI `<Name>ScreenTest.kt`.
6. **iOS** : package `ios/Features/<Name>/` avec `Package.swift` (ou généré, approche B), `<Name>View.swift`, `<Name>ViewModel.swift` (wrapper `@Observable` autour du Store via SKIE), test UI `<Name>ViewTests.swift`.
7. **Câblage** : enregistrer `<Name>Module` dans le DI de `android/app` et `ios/App`, ajouter la route dans la navigation des deux apps.
8. **Vérifier** : `./scripts/build-android.sh`, `./scripts/build-ios.sh`, `./scripts/check-architecture.sh`.
9. **Chronométrer** : `<name>,end,<ISO8601>` dans `bench/feature-timings.log`.
10. **Commit** : `feat(<name>): scaffold feature module`.

## Garde-fous

- La feature ne dépend d'aucune autre feature : uniquement de `core` et des modules `*-api`.
- Pas de logique dans les écrans : tout passe par le Store.
- Si une étape échoue, ne pas désactiver de test ni de règle : corriger ou documenter dans `docs/frictions.md`.
