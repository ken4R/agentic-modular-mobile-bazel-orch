#!/usr/bin/env bash
# Fonctions communes. Les scripts de build par approche sont dans scripts/build-*.sh (fournis par chaque POC).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RUNS="${BENCH_RUNS:-3}"

now_ms() { python3 -c 'import time;print(int(time.time()*1000))'; }

# time_cmd <label> <cmd...> : exécute RUNS fois, imprime la médiane en ms
time_cmd() {
  local label="$1"; shift
  local times=()
  for i in $(seq 1 "$RUNS"); do
    local s; s=$(now_ms)
    "$@" >/dev/null 2>&1
    local e; e=$(now_ms)
    times+=($((e - s)))
    echo "  [$label] run $i: $((e - s)) ms" >&2
  done
  printf '%s\n' "${times[@]}" | sort -n | sed -n "$(((RUNS + 1) / 2))p"
}

clear_caches() {
  rm -rf "$HOME/.gradle/caches/build-cache-1" "$ROOT/.gradle" "$ROOT/build" 2>/dev/null || true
  find "$ROOT" -type d -name build -path '*/shared/*' -prune -exec rm -rf {} + 2>/dev/null || true
  rm -rf "$HOME/Library/Developer/Xcode/DerivedData" 2>/dev/null || true
  command -v bazel >/dev/null 2>&1 && (cd "$ROOT" && bazel clean --expunge >/dev/null 2>&1 || true)
  (cd "$ROOT" && ./gradlew --stop >/dev/null 2>&1 || true)
}
