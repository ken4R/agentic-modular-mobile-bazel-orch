# mobile-poc-template

Socle commun des trois POC d'architecture mobile modulaire (KMP + UI native).
Ne contient aucun code applicatif : uniquement les conventions, la couche agentique,
les scripts de mesure et le plan d'action.

## Utilisation

1. Pousser ce repo sur GitHub et le marquer *Template repository*.
2. Lancer `./bootstrap.sh <org>` pour créer les trois repos A, B, C à partir du template.
3. Dans chaque repo, `approaches/<X>/CLAUDE.md` a été copié à la racine par le script :
   c'est ce qui distingue le projet Claude Code de chaque approche.
4. Ouvrir chaque clone dans un terminal, lancer `claude`, donner la première tâche (voir `docs/plan-action.md`).

## Règle d'or

Toute modification du socle (`.claude/`, `scripts/bench/`, `AGENTS.md`, `libs.versions.toml`)
se fait **ici** puis se propage via `./scripts/sync-socle.sh` dans les trois POC.
Jamais l'inverse, sinon la comparaison est biaisée.
