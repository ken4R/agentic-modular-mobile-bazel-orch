---
name: write-ui-tests
description: Écrit les tests UI d'un écran sur les deux plateformes — Compose UI test côté Android, XCUITest ou test de vue SwiftUI côté iOS — en injectant un Store KMP factice. Utiliser dès que l'utilisateur demande des tests UI, des tests d'écran, des tests d'interface, des tests Compose ou XCTest, ou pour compléter la définition de "done" d'une feature.
---

# write-ui-tests

Un test UI par écran et par plateforme. Même scénario sur les deux : rendu de l'état initial, interaction principale, état d'erreur.

## Principe

L'écran reçoit son `Store` par injection. Les tests fournissent un `Fake<Name>Store` (dans `shared/features/<name>/src/commonMain/.../test/`, exporté) qui expose un `MutableStateFlow<UiState>` pilotable et enregistre les `Intent` reçus. Le même fake sert aux deux plateformes.

## Android — `android/features/<name>/src/androidTest/.../<Name>ScreenTest.kt`

- `createComposeRule()`, `setContent { <Name>Screen(store = fake) }`.
- Test 1 : état `Loading` → `onNodeWithTag("loading").assertIsDisplayed()`.
- Test 2 : état `Content` → clic sur l'action principale → `fake.received` contient l'Intent attendu.
- Test 3 : état `Error` → message visible + bouton "Réessayer".
- Utiliser des `testTag` stables, jamais de texte localisé comme sélecteur.

## iOS — `ios/Features/<Name>/Tests/<Name>ViewTests.swift`

- Même trois cas, via `ViewInspector` si présent, sinon XCUITest avec `accessibilityIdentifier` identiques aux `testTag` Android.
- Pour piloter l'état : `fake.state.value = .error(...)` puis `await` du prochain rendu.

## Vérification

Lancer les commandes de test de `CLAUDE.md`. Les deux suites doivent passer en CI sur simulateur/émulateur.
