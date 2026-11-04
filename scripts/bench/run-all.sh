#!/usr/bin/env bash
source "$(dirname "$0")/_lib.sh"
cd "$ROOT"
[ -n "$(git status --porcelain)" ] && { echo "Arbre git non propre, abandon." >&2; exit 1; }
SHA=$(git rev-parse --short HEAD); DATE=$(date +%Y-%m-%d)
APPROACH=$(grep -oE 'Approche [ABC]' CLAUDE.md | head -1 | cut -d' ' -f2)
mkdir -p bench
echo "== Bench approche $APPROACH @ $SHA ==" >&2
CA=$(scripts/bench/cold-android.sh)
CI_=$(scripts/bench/cold-ios.sh)
INC=$(scripts/bench/incremental.sh)
HIT=$(scripts/bench/cache-hit.sh)
LINES=$(scripts/bench/config-lines.sh)
FEAT=$(python3 - <<'PY'
import os,datetime as d
p='bench/feature-timings.log'
if not os.path.exists(p): print('null'); raise SystemExit
t={}
for l in open(p):
    n,k,ts=l.strip().split(','); t.setdefault(n,{})[k]=d.datetime.fromisoformat(ts)
v=[(x['end']-x['start']).total_seconds()/60 for x in t.values() if 'start' in x and 'end' in x]
print(round(sum(v)/len(v),1) if v else 'null')
PY
)
OUT="bench/results-$DATE-$SHA.json"
cat > "$OUT" <<JSON
{
  "approach": "$APPROACH", "sha": "$SHA", "date": "$DATE", "runs": $RUNS,
  "cold_android_ms": $CA, "cold_ios_ms": $CI_, "incremental_ms": $INC,
  "cache_hit_pct": $HIT, "config_lines": $LINES, "feature_add_min_avg": $FEAT,
  "ci_pr_min": null, "ide_score_5": null, "kotlin_upgrade_min": null
}
JSON
echo "Résultats : $OUT" >&2; cat "$OUT"
