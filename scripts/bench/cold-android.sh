#!/usr/bin/env bash
source "$(dirname "$0")/_lib.sh"
cold() { clear_caches; "$ROOT/scripts/build-android.sh"; }
time_cmd cold-android cold
