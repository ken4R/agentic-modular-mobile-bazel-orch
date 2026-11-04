#!/usr/bin/env bash
# Usage : to-markdown.sh results-*.json [results-*.json ...]  → tableau Markdown comparatif
python3 - "$@" <<'PY'
import json,sys
rows=[json.load(open(f)) for f in sys.argv[1:]]
keys=[("cold_android_ms","Build à froid Android (ms)"),("cold_ios_ms","Build à froid iOS (ms)"),
("incremental_ms","Build incrémental (ms)"),("cache_hit_pct","Cache hit ratio (%)"),
("ci_pr_min","Durée pipeline PR (min)"),("feature_add_min_avg","Ajout feature (min, moy.)"),
("kotlin_upgrade_min","Montée de version Kotlin (min)"),("ide_score_5","Expérience IDE (/5)"),
("config_lines","Lignes de configuration")]
print("| Métrique | "+" | ".join(f"{r['approach']} ({r['sha']})" for r in rows)+" |")
print("|---|"+"---|"*len(rows))
for k,l in keys: print(f"| {l} | "+" | ".join(str(r.get(k,'')) if r.get(k) is not None else '—' for r in rows)+" |")
PY
