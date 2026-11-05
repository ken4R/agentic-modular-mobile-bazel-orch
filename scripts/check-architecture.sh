#!/usr/bin/env bash
# Konsist + detekt + SwiftLint. Échoue au premier outil en erreur : aucun fallback silencieux.
# Chaque POC adapte uniquement les variables ci-dessous (les commandes dépendent de l'approche).
set -euo pipefail
cd "$(dirname "$0")/.."

DETEKT_CMD="${DETEKT_CMD:-./gradlew detekt -q}"
KONSIST_CMD="${KONSIST_CMD:-./gradlew :shared:konsist:allTests -q}"
SWIFTLINT_DIR="${SWIFTLINT_DIR:-ios}"

echo "== detekt";   $DETEKT_CMD   2>&1 | grep -vE '^$' | tail -40
echo "== konsist";  $KONSIST_CMD  2>&1 | grep -vE '^$' | tail -40

echo "== swiftlint"
if command -v swiftlint >/dev/null 2>&1; then
  swiftlint lint --strict "$SWIFTLINT_DIR" 2>&1 | tail -40
elif [ "${CI:-false}" = "true" ]; then
  echo "swiftlint absent en CI : échec" >&2; exit 1
else
  echo "swiftlint absent en local : ignoré (brew install swiftlint)"
fi
echo "== OK"
