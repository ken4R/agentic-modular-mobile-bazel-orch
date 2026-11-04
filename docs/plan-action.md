# Plan d'action — POC d'architecture mobile modulaire (KMP + UI native)

## Résumé exécutif

Objectif : comparer trois approches de build pour un monorepo mobile modulaire (logique KMP partagée, UI SwiftUI et Compose, modules iOS en SPM, Bazel envisagé) en construisant un POC par approche sur un périmètre fonctionnel identique.

| Approche | Résumé | Durée estimée | Risque |
|---|---|---|---|
| **A** | Gradle pour KMP, SPM natif, Bazel orchestrateur iOS | 3 sem. | Faible |
| **B** | Bazel "full" Android/Swift, Gradle isolé pour Kotlin/Native | 5 sem. | Élevé |
| **C** | Gradle + SPM optimisés, sans Bazel (baseline) | 2 sem. | Très faible |

Ordre conseillé : **C → A → B**. Budget total ≈ 10–11 semaines pour une personne, 6–7 à deux.

Critère de décision : B n'est retenu que s'il bat A d'au moins 30 % sur le build incrémental et la durée CI.

Contrainte structurante : Bazel ne compile pas Kotlin/Native aujourd'hui (`rules_kotlin` couvre JVM, Android, JS). Toute approche doit donc conserver Gradle pour la cible iOS du code KMP.

---

## 1. Socle commun (semaine 0)

À réaliser une fois, réutilisé par les trois POC pour garantir une comparaison équitable.

### 1.1 Périmètre fonctionnel identique
- `core` KMP : Ktor (réseau), SQLDelight (persistance), Koin (DI), MVI (présentation), logging.
- 3 features KMP : `auth`, `catalog`, `cart`.
- Par feature : un écran Compose, un écran SwiftUI, tests unitaires KMP, un test UI par plateforme.
- Export Swift via SKIE, configuration identique dans les trois POC.

### 1.2 Règles d'architecture (vérifiées par tests)
- Dépendances autorisées : `feature → feature-api → core`. Jamais `feature → feature`.
- Un module = un dossier autonome, sans `allprojects {}` ni héritage implicite de plugins.
- Catalogue de versions unique `libs.versions.toml`.
- Konsist (Kotlin), detekt, SwiftLint, Danger en CI.

### 1.3 Couche agentique
- `AGENTS.md` racine (+ `CLAUDE.md` qui le référence) : conventions, commandes, définition de "done".
- `AGENTS.md` par module : API publique, pièges connus.
- `.claude/skills/` : `new-feature-module`, `expose-to-swift`, `write-ui-tests`, `review-architecture`.
- MCP : exécution Gradle/Bazel, `xcodebuild`.

### 1.4 Scripts de mesure
Scripts shell reproductibles pour chaque métrique de la grille (section 5), exécutables en CI et en local.

Livrable S0 : repo template `mobile-poc-template` avec tout ce qui précède.

---

## 2. POC C — Gradle + SPM, sans Bazel (baseline, 2 semaines)

### Semaine 1 — Squelette
- [ ] Monorepo Gradle, `build-logic` avec convention plugins (`kmp-feature`, `kmp-core`, `android-feature`).
- [ ] Modules `core`, `auth`, `catalog`, `cart` en KMP.
- [ ] App Android Compose branchée sur les trois features.
- [ ] Génération `Shared.xcframework` via `assembleXCFramework`.
- [ ] Packages SPM : `Core`, `AuthUI`, `CatalogUI`, `CartUI`, `App` avec `binaryTarget` vers le XCFramework.
- [ ] App SwiftUI, SKIE actif.

### Semaine 2 — Optimisation Gradle/Xcode
- [ ] Configuration cache Gradle activé et validé sur tous les modules.
- [ ] Build cache distant (Develocity ou bucket HTTP simple).
- [ ] Build par impact : `gradle-dependency-graph` → tests ciblés en CI.
- [ ] Cache des DerivedData Xcode en CI.
- [ ] Exécution complète de la grille de mesure.

Livrable : baseline chiffrée + journal des frictions.

---

## 3. POC A — Gradle KMP + SPM + Bazel orchestrateur (3 semaines)

Fork de POC C à la fin de la semaine 1 (80 % de réutilisation).

### Semaine 1 — Squelette
Identique à POC C semaine 1.

### Semaine 2 — SPM et intégration iOS
- [ ] Finalisation des packages SPM et de l'app SwiftUI.
- [ ] Tests de contrat sur l'API Swift générée par SKIE (enums, Flows → AsyncSequence).
- [ ] CI Android + iOS fonctionnelle sans Bazel (point de contrôle).

### Semaine 3 — Bazel orchestrateur
- [ ] `MODULE.bazel` (bzlmod) : `rules_apple`, `rules_swift`, `rules_xcodeproj`.
- [ ] Règle `genrule` (ou règle Starlark) appelant Gradle pour produire le XCFramework, entrées/sorties déclarées.
- [ ] `swift_library` par package SPM, `Package.swift` conservés pour le dev local dans Xcode.
- [ ] Cache distant (BuildBuddy plan gratuit ou EngFlow).
- [ ] Génération du `.xcodeproj` par `rules_xcodeproj`.
- [ ] CI iOS via `bazel build //ios/App`, Android inchangé (Gradle).
- [ ] Exécution complète de la grille de mesure.

Livrable : mesures + analyse du coût du double build system et du debug du XCFramework.

---

## 4. POC B — Bazel "full" Android/Swift, Gradle isolé Kotlin/Native (5 semaines)

### Semaine 1 — Bazel Android
- [ ] `MODULE.bazel` : `rules_kotlin` 2.x, `rules_android`, `rules_jvm_external` (résolveur Gradle pour artefacts KMP).
- [ ] `kt_jvm_library` sur `commonMain` + `androidMain` pour `core` et les 3 features.
- [ ] App Android en `android_binary`, Compose fonctionnel.

### Semaine 2 — Kotlin/Native encapsulé
- [ ] Projet Gradle minimal réduit aux cibles `iosArm64`, `iosSimulatorArm64`, lisant les **mêmes dossiers sources** via `srcDirs`.
- [ ] Règle Starlark `kmp_xcframework` wrappant Gradle, entrées/sorties déclarées pour le cache.
- [ ] Validation : un changement dans `commonMain` invalide bien la règle.

### Semaine 3 — Swift sous Bazel
- [ ] `swift_library` par feature, dépendances vers le XCFramework produit.
- [ ] `Package.swift` générés par Bazel (`write_file`) pour l'ouverture directe dans Xcode.
- [ ] `rules_xcodeproj`, app iOS buildée par Bazel.

### Semaine 4 — CI par impact
- [ ] `bazel query 'rdeps(//..., set(fichiers modifiés))'` → cibles de test.
- [ ] Cache distant, exécution distante si disponible.
- [ ] Pipeline PR complet.

### Semaine 5 — Stabilisation
- [ ] IDE : Android Studio + plugin Bazel, Xcode via `rules_xcodeproj`, debug Kotlin/Native.
- [ ] Montée de version Kotlin de bout en bout (Gradle + Bazel) chronométrée.
- [ ] Exécution complète de la grille de mesure.

Livrable : mesures + estimation du coût annuel de maintien de la règle Kotlin/Native custom. C'est le point décisif.

---

## 5. Grille de mesure (identique pour les trois POC)

| Métrique | Protocole | C | A | B |
|---|---|---|---|---|
| Build à froid Android | cache vidé, `time` sur la commande CI, médiane de 3 | | | |
| Build à froid iOS | idem | | | |
| Build incrémental | modifier 1 ligne dans `cart`, rebuild, médiane de 3 | | | |
| Cache hit ratio CI | 2e run sur la même révision | | | |
| Durée pipeline PR | pipeline complet, médiane de 3 | | | |
| Ajout d'une feature (humain) | chrono via skill `new-feature-module` | | | |
| Ajout d'une feature (agent) | même tâche via Claude Code, succès sans correction (oui/non), durée | | | |
| Montée de version Kotlin | temps vers la version suivante | | | |
| Expérience IDE | autocomplétion, debug KMP depuis Xcode, note /5 | | | |
| Lignes de configuration | `wc -l` Gradle + Starlark + `Package.swift` | | | |
| Tokens consommés (semaine 1) | `/cost` en fin de session, somme notée dans `docs/frictions.md` | | | |
| Interventions humaines (semaine 1) | nombre de corrections manuelles, journal | | | |
| Frictions rencontrées | journal qualitatif | | | |

---

## 6. Décision finale

1. Comparer A et B sur les métriques build incrémental et durée CI.
2. Si B < A − 30 % : B justifié, planifier la migration par étapes.
3. Sinon : retenir A, conserver les conventions "Bazel-ready" (section 1.2) et réévaluer quand :
   - le nombre de modules KMP dépasse 40–50, ou
   - la CI incrémentale dépasse 15 min, ou
   - des règles Kotlin/Native matures apparaissent côté Bazel.

Rédiger une ADR par décision (format : contexte, options, décision, conséquences).

---

*Document de travail interne. Les estimations de durée supposent un développeur senior maîtrisant KMP ; ajuster selon l'équipe.*
