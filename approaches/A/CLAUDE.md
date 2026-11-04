Lis `AGENTS.md` avant toute action.

## Approche A — Gradle KMP + SPM + Bazel orchestrateur

- **Gradle est la source de vérité** pour tout le code Kotlin (KMP, Android).
- **Bazel ne compile pas de Kotlin.** Il orchestre uniquement la partie iOS :
  règle `genrule`/Starlark dans `ios/BUILD.bazel` qui appelle `./gradlew :shared:assembleXCFramework`,
  puis `swift_library` / `ios_application` via `rules_apple`, `rules_swift`, `rules_xcodeproj`.
- Les `Package.swift` restent présents et fonctionnels pour le développement local dans Xcode.

### Commandes
- Android : `./gradlew :android:app:assembleDebug`
- Tests KMP : `./gradlew :shared:allTests`
- XCFramework : `./gradlew :shared:assembleXCFramework`
- iOS : `bazel build //ios/App`
- Projet Xcode : `bazel run //ios:xcodeproj`

### Interdits
- Ne jamais déclarer de `kt_jvm_library` ou `kt_android_library` : le Kotlin reste sous Gradle.
- Ne jamais supprimer un `Package.swift` au profit d'un `BUILD` seul.
