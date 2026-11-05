#!/usr/bin/env bash
# Tests unitaires KMP (commonTest). À adapter par approche (Gradle en A/C, bazel test en B).
set -euo pipefail
cd "$(dirname "$0")/.."
"${TEST_SHARED_CMD:-./gradlew :shared:allTests -q}" 2>&1 | tail -60
