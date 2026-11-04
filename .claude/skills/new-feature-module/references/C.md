# Approche C — fichiers de build à générer

- `shared/features/<name>/build.gradle.kts` et `<name>-api/build.gradle.kts` : convention plugins `kmp-feature` / `kmp-api`.
- `android/features/<name>/build.gradle.kts` : convention plugin `android-feature`.
- Ajouter les trois modules dans `settings.gradle.kts`.
- Ajouter `<name>` à `exportedModules` du module `shared/umbrella`.
- `ios/Features/<Name>/Package.swift` : écrit à la main, dépend de `Core` et du `binaryTarget` `Shared`.
- Ajouter le package en dépendance locale dans `ios/App/Package.swift` (ou dans le `.xcodeproj` via "Add Local Package").
- **Aucun fichier Bazel.**
