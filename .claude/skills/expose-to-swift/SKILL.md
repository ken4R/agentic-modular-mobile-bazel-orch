---
name: expose-to-swift
description: Rend une API Kotlin (classe, fonction, Flow, sealed class, enum, suspend fun) consommable proprement depuis Swift via SKIE, et vérifie l'API générée par un test de contrat. Utiliser dès qu'il est question d'exposer, partager ou utiliser du code KMP depuis iOS/Swift/SwiftUI, de problèmes d'interop Kotlin↔Swift, ou de types qui "n'apparaissent pas" ou sont "moches" côté Swift.
---

# expose-to-swift

## Checklist pour chaque API exposée

1. **Visibilité** : `public` explicite. Tout ce qui ne doit pas sortir est `internal`.
2. **Types** :
   - `sealed class/interface` → vérifier qu'elle devient un `enum` Swift exhaustif (SKIE). Éviter les sealed classes génériques.
   - `enum class` → OK natif. Ne pas exposer d'`Int`/`Long` non typés quand un enum est possible.
   - Collections : préférer `List<T>` à `Array`, éviter `Map` avec clés non-`String`.
   - `Result<T>` n'est pas exporté : utiliser une sealed class `Outcome<T>` de `core`.
3. **Asynchrone** :
   - `suspend fun` → `async` Swift (SKIE). Toujours annuler proprement : vérifier qu'une `CancellationException` ne remonte pas en crash.
   - `Flow<T>` / `StateFlow<T>` → `AsyncSequence`. Le Store expose `val state: StateFlow<UiState>` et `fun accept(intent)`.
4. **Nommage** : pas d'overloads qui ne diffèrent que par le type (Swift les mange mal). Pas de paramètres `default` sur les API publiques.
5. **Génériques** : limiter la profondeur ; pas de `T : Comparable<T>`.
6. **Exceptions** : annoter `@Throws(...)` toute fonction qui peut lever, sinon crash côté Swift.

## Test de contrat (obligatoire)

Ajouter dans `ios/Core/Tests/ContractTests/<Name>ContractTests.swift` un test qui :
- instancie le type exposé,
- `switch` exhaustif sur chaque sealed class/enum (le test ne compile plus si un cas est ajouté côté Kotlin),
- consomme le `StateFlow` via `for await` et vérifie au moins une émission.

## Vérification

Régénérer le XCFramework (commande dans `CLAUDE.md`), builder `ios/App`, lancer les ContractTests.
