#!/usr/bin/env bash
# Crée les trois repos POC sur GitHub à partir du template, et prépare chaque clone.
# Compatible bash 3.2 (macOS). Prérequis : gh CLI authentifié (gh auth login), git.
# Usage : ./bootstrap.sh <org-ou-user> [--public]
set -euo pipefail
ORG="${1:?Usage: ./bootstrap.sh <org-ou-user> [--public]}"
VIS="${2:---private}"
HERE="$(cd "$(dirname "$0")" && pwd)"
PARENT="$(dirname "$HERE")"
TEMPLATE="mobile-poc-template"

repo_for() {
  case "$1" in
    A) echo "agentic-modular-mobile-bazel-orch" ;;
    B) echo "agentic-modular-mobile-bazel-full" ;;
    C) echo "agentic-modular-mobile-grade-spm" ;;
  esac
}

echo "== Vérification gh"
gh auth status >/dev/null 2>&1 || { echo "gh non authentifié : lancez 'gh auth login'" >&2; exit 1; }

echo "== 1. Template $ORG/$TEMPLATE"
if ! gh repo view "$ORG/$TEMPLATE" >/dev/null 2>&1; then
  echo "Le repo $ORG/$TEMPLATE n'existe pas. Poussez d'abord ce dossier dessus." >&2; exit 1
fi
gh repo edit "$ORG/$TEMPLATE" --template >/dev/null 2>&1 || true

for K in A B C; do
  R="$(repo_for "$K")"
  echo "== 2. POC $K → $ORG/$R"
  cd "$PARENT"
  if [ ! -d "$R" ]; then
    if gh repo view "$ORG/$R" >/dev/null 2>&1; then
      gh repo clone "$ORG/$R"
    else
      gh repo create "$ORG/$R" "$VIS" --template "$ORG/$TEMPLATE" --clone
      sleep 5  # GitHub met quelques secondes à matérialiser le template
    fi
  fi
  cd "$R"
  # Si le template n'était pas encore matérialisé au clone, le dépôt peut être vide : on retente.
  if [ ! -f AGENTS.md ]; then
    git pull -q origin main 2>/dev/null || git pull -q origin master 2>/dev/null || true
  fi
  [ -f AGENTS.md ] || { echo "Clone $R vide : attendez quelques secondes et relancez le script." >&2; exit 1; }

  if [ -d approaches ]; then
    cp "approaches/$K/CLAUDE.md" CLAUDE.md
    rm -rf approaches bootstrap.sh
    mkdir -p bench docs/adr
    touch docs/frictions.md
    [ -f docs/adr/0000-template.md ] && cp docs/adr/0000-template.md "docs/adr/0001-choix-approche-$K.md"
    chmod +x scripts/*.sh scripts/bench/*.sh
    git add -A
    git commit -qm "chore: init POC approche $K"
    git push -q
  fi
  echo "   prêt : $PARENT/$R  (ouvrir un terminal ici et lancer 'claude')"
done

echo
echo "Première tâche à donner à chaque agent (identique dans les 3 repos) :"
echo "  Lis AGENTS.md et docs/plan-action.md. Réalise la semaine 1 du POC de ce repo."
echo "  Ne t'arrête qu'avec une app Android et une app iOS qui compilent, et un commit par étape."
