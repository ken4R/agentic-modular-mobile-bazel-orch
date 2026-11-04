#!/usr/bin/env bash
# Crée le repo template puis les trois repos POC sur GitHub, et prépare chaque clone.
# Prérequis : gh CLI authentifié (gh auth login), git, jq.
# Usage : ./bootstrap.sh <org-ou-user> [--public]
set -euo pipefail
ORG="${1:?Usage: ./bootstrap.sh <org-ou-user> [--public]}"
VIS="${2:---private}"
HERE="$(cd "$(dirname "$0")" && pwd)"
PARENT="$(dirname "$HERE")"
TEMPLATE="mobile-poc-template"

declare -A REPOS=(
  [A]="agentic-modular-mobile-bazel-orch"
  [B]="agentic-modular-mobile-bazel-full"
  [C]="agentic-modular-mobile-grade-spm"
)

echo "== 1. Template $ORG/$TEMPLATE"
cd "$HERE"
[ -d .git ] || git init -q -b main
git add -A && git commit -qm "chore: socle commun des POC" || true
gh repo view "$ORG/$TEMPLATE" >/dev/null 2>&1 || gh repo create "$ORG/$TEMPLATE" "$VIS" --source=. --push
gh repo edit "$ORG/$TEMPLATE" --template >/dev/null

for K in A B C; do
  R="${REPOS[$K]}"
  echo "== 2. POC $K → $ORG/$R"
  cd "$PARENT"
  if [ ! -d "$R" ]; then
    gh repo create "$ORG/$R" "$VIS" --template "$ORG/$TEMPLATE" --clone
    sleep 3  # GitHub met quelques secondes à matérialiser le template
  fi
  cd "$R"
  git pull -q || true
  cp "approaches/$K/CLAUDE.md" CLAUDE.md
  rm -rf approaches bootstrap.sh
  mkdir -p bench docs/adr
  touch docs/frictions.md
  cp docs/adr/0000-template.md "docs/adr/0001-choix-approche-$K.md" 2>/dev/null || true
  chmod +x scripts/*.sh scripts/bench/*.sh
  git add -A && git commit -qm "chore: init POC approche $K" && git push -q
  echo "   prêt : $PARENT/$R  (ouvrir un terminal ici et lancer 'claude')"
done

echo
echo "Première tâche à donner à chaque agent (identique dans les 3 repos) :"
echo "  Lis AGENTS.md et docs/plan-action.md. Réalise la semaine 1 du POC de ce repo."
echo "  Ne t'arrête qu'avec une app Android et une app iOS qui compilent, et un commit par étape."
