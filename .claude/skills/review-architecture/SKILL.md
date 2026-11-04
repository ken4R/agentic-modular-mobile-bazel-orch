---
name: review-architecture
description: Revue d'architecture d'un changement ou d'un module par rapport aux règles d'AGENTS.md — dépendances entre modules, séparation UI/logique, conventions de build de l'approche, exposition Swift, tests. Utiliser avant tout commit important, quand l'utilisateur demande une review, un audit, une vérification de conformité, ou dit "est-ce que c'est propre / conforme / bien architecturé".
---

# review-architecture

Produire un rapport court (≤ 30 lignes) : **Bloquant / À corriger / Suggestion**, puis un verdict GO / NO-GO.

## Vérifications automatiques (lancer d'abord)

```
./scripts/check-architecture.sh
```
Konsist, detekt, SwiftLint. Un échec = Bloquant.

## Vérifications manuelles

1. **Graphe** : aucune dépendance `feature → feature`. `core` ne connaît aucune feature. Les `*-api` ne contiennent que des contrats.
2. **UI** : aucun appel réseau, DB ou logique de branchement métier dans Compose/SwiftUI. Tout passe par `Intent` → Store → `UiState`.
3. **Approche de build** : lire la section **Interdits** de `CLAUDE.md` et vérifier qu'aucun n'est violé (ex. fichier Bazel en C, `build.gradle.kts` hors `tools/knative` en B).
4. **Versions** : aucune version en dur hors `libs.versions.toml`.
5. **Swift** : toute nouvelle API publique Kotlin a son ContractTest (voir skill `expose-to-swift`).
6. **Tests** : Store testé, un test UI par plateforme.
7. **ADR** : décision structurante sans ADR dans `docs/adr/` = À corriger.
8. **Agentique** : si le module a un `AGENTS.md`, est-il à jour (API publique, pièges) ?

## Format de sortie

```
## Review — <module ou PR>
Bloquant : ...
À corriger : ...
Suggestion : ...
Verdict : GO | NO-GO
```
