Lis `AGENTS.md` avant toute action.

## Approche B — Bazel "full" Android/Swift, Gradle isolé pour Kotlin/Native

- **Bazel est la source de vérité** : `kt_jvm_library` / `kt_android_library` (`rules_kotlin` 2.x) pour
  `commonMain` + `androidMain`, `android_binary` pour l'app, `swift_library` + `ios_application` pour iOS.
- Dépendances externes via `rules_jvm_external` avec le résolveur Gradle, alimenté par `gradle/libs.versions.toml`.
- **Gradle n'existe que dans `tools/knative/`** : projet minimal réduit aux cibles `iosArm64` et `iosSimulatorArm64`,
  qui lit les mêmes dossiers sources via `srcDirs`. Il est appelé par la règle Starlark `kmp_xcframework`
  (`tools/knative/defs.bzl`) avec entrées/sorties déclarées pour le cache.
- Les `Package.swift` sont **générés** par Bazel (`write_file`) pour l'ouverture dans Xcode ; ne jamais les éditer à la main.

### Commandes
- Tout : `bazel build //...`
- Android : `bazel build //android/app`
- iOS : `bazel build //ios/App`
- Tests impactés : `./scripts/affected-tests.sh` (wrapper de `bazel query rdeps`)
- Projet Xcode : `bazel run //ios:xcodeproj`

### Interdits
- Ne jamais ajouter de `build.gradle.kts` en dehors de `tools/knative/`.
- Ne jamais dupliquer une liste de sources : si `srcDirs` et `srcs` divergent, générer l'un depuis l'autre.
- Ne jamais éditer un `Package.swift` généré.
