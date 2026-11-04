# Approche A — fichiers de build à générer

- `shared/features/<name>/build.gradle.kts` et `<name>-api/build.gradle.kts` : appliquer le convention plugin `kmp-feature` (resp. `kmp-api`) depuis `build-logic`. Aucune version en dur.
- `android/features/<name>/build.gradle.kts` : convention plugin `android-feature`.
- Ajouter les trois modules dans `settings.gradle.kts` (`include(...)`).
- Ajouter `<name>` à la liste `exportedModules` du module `shared/umbrella` pour qu'il entre dans `Shared.xcframework`.
- `ios/Features/<Name>/Package.swift` : écrit à la main, dépend de `Core` et du `binaryTarget` `Shared`.
- `ios/Features/<Name>/BUILD.bazel` : `swift_library(name = "<Name>", srcs = glob(["Sources/**/*.swift"]), deps = ["//ios/Core", "//ios:Shared"])`.
- Ajouter la cible dans `deps` de `//ios/App`.
