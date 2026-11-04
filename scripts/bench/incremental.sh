#!/usr/bin/env bash
# Modifie une ligne dans la feature cart, rebuild les deux plateformes, restaure.
source "$(dirname "$0")/_lib.sh"
TARGET="$(find "$ROOT/shared/features/cart" -name 'CartStore.kt' | head -1)"
[ -z "$TARGET" ] && { echo "CartStore.kt introuvable" >&2; exit 1; }
"$ROOT/scripts/build-android.sh" >/dev/null 2>&1; "$ROOT/scripts/build-ios.sh" >/dev/null 2>&1  # warm
incr() {
  echo "// bench $(date +%s%N)" >> "$TARGET"
  "$ROOT/scripts/build-android.sh" && "$ROOT/scripts/build-ios.sh"
}
trap 'cd "$ROOT" && git checkout -- "$TARGET"' EXIT
time_cmd incremental incr
