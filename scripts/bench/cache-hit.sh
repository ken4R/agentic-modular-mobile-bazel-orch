#!/usr/bin/env bash
# Deuxième build sur la même révision, caches locaux vidés, cache distant actif. Imprime le ratio de hits (0-100).
source "$(dirname "$0")/_lib.sh"
clear_caches
LOG="$(mktemp)"
BENCH_CAPTURE_LOG="$LOG" "$ROOT/scripts/build-android.sh" >"$LOG" 2>&1 || true
BENCH_CAPTURE_LOG="$LOG" "$ROOT/scripts/build-ios.sh" >>"$LOG" 2>&1 || true
# Gradle : "N tasks ... M from cache" ; Bazel : "N processes: X remote cache hit"
G=$(grep -oE '[0-9]+ actionable tasks: .*' "$LOG" | tail -1 || true)
B=$(grep -oE '[0-9]+ processes: .*' "$LOG" | tail -1 || true)
python3 - "$G" "$B" <<'PY'
import re,sys
g,b=sys.argv[1],sys.argv[2]; hit=tot=0
if g:
    tot+=int(re.match(r'(\d+)',g).group(1)); m=re.search(r'(\d+) from cache',g); hit+=int(m.group(1)) if m else 0
if b:
    tot+=int(re.match(r'(\d+)',b).group(1)); m=re.search(r'(\d+) remote cache hit',b); hit+=int(m.group(1)) if m else 0
print(round(100*hit/tot) if tot else 0)
PY
