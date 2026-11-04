#!/usr/bin/env bash
source "$(dirname "$0")/_lib.sh"
cd "$ROOT"
find . -type f \( -name '*.gradle.kts' -o -name 'gradle.properties' -o -name 'libs.versions.toml' \
  -o -name 'BUILD' -o -name 'BUILD.bazel' -o -name 'MODULE.bazel' -o -name '*.bzl' -o -name '.bazelrc' \
  -o -name 'Package.swift' \) -not -path './bazel-*' -not -path './build/*' -print0 \
  | xargs -0 cat 2>/dev/null | wc -l | tr -d ' '
