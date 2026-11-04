# Approche B — fichiers de build à générer

- `shared/features/<name>/BUILD.bazel` : `kt_jvm_library(name = "<name>", srcs = glob(["src/commonMain/**/*.kt", "src/androidMain/**/*.kt"]), deps = ["//shared/core", "//shared/features/<name>-api"] + deps externes via `@maven//:...`)`.
  Même chose pour `<name>-api`. Test : `kt_jvm_test` sur `src/commonTest`.
- `android/features/<name>/BUILD.bazel` : `kt_android_library`.
- **Ne pas créer de `build.gradle.kts`.** Ajouter le dossier source dans `tools/knative/build.gradle.kts` (bloc `srcDirs`) et dans la liste `exported` de la règle `kmp_xcframework` dans `tools/knative/BUILD.bazel`.
- `ios/Features/<Name>/BUILD.bazel` : `swift_library` + règle `write_file` qui génère `Package.swift`. Lancer `bazel run //ios:gen_packages` après.
- Ajouter la cible dans `deps` de `//ios/App`.
