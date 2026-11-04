#!/usr/bin/env bash
# À lancer depuis mobile-poc-template : propage le socle vers les trois POC clonés à côté.
# Usage : ./scripts/sync-socle.sh ../mobile-poc-a-gradle-bazel-orchestrator ../mobile-poc-b-bazel-full ../mobile-poc-c-gradle-spm
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
for T in "$@"; do
  echo "→ $T"
  rsync -a --delete "$HERE/.claude/skills/" "$T/.claude/skills/"
  rsync -a --delete "$HERE/scripts/bench/" "$T/scripts/bench/"
  cp "$HERE/AGENTS.md" "$T/AGENTS.md"; cp "$HERE/gradle/libs.versions.toml" "$T/gradle/libs.versions.toml"
  cp "$HERE/scripts/check-architecture.sh" "$T/scripts/check-architecture.sh"
  cp "$HERE/docs/plan-action.md" "$T/docs/plan-action.md"
  (cd "$T" && git add -A && git commit -qm "chore(socle): sync from template" || echo "  rien à synchroniser")
done
