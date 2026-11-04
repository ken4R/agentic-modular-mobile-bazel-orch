#!/usr/bin/env bash
source "$(dirname "$0")/_lib.sh"
cold() { clear_caches; "$ROOT/scripts/build-ios.sh"; }
time_cmd cold-ios cold
