#!/usr/bin/env bash
# Installe les outils iOS requis par l'approche sur un runner macOS. Idempotent.
# Chaque POC ajoute ses outils (xcodegen, bazelisk, swiftlint...). Rien si natif pur.
set -euo pipefail
need() { command -v "$1" >/dev/null 2>&1 || brew install "$1"; }
need swiftlint
# need xcodegen      # approche C si XcodeGen est utilisé
# need bazelisk      # approches A et B
