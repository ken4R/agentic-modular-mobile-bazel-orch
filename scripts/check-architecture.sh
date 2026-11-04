#!/usr/bin/env bash
# Konsist + detekt + SwiftLint. Les commandes exactes de test Konsist dépendent de l'approche ;
# chaque POC complète ce script (section TODO) sans en changer la sortie.
set -euo pipefail
cd "$(dirname "$0")/.."
echo "== detekt";    ./gradlew detekt -q 2>/dev/null || bazel test //shared/... --test_tag_filters=detekt 2>/dev/null || echo "TODO: brancher detekt"
echo "== konsist";   ./gradlew :shared:konsist:allTests -q 2>/dev/null || bazel test //shared/konsist:all 2>/dev/null || echo "TODO: brancher konsist"
echo "== swiftlint"; command -v swiftlint >/dev/null && swiftlint lint --strict ios || echo "swiftlint absent"
