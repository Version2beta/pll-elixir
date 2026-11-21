#!/usr/bin/env bash
# Explicitly authorized offline producer; source repository is read-only.
set -euo pipefail
source_dir=${1:?usage: generate.sh /absolute/path/to/pinned/pll}
expected=971282632129110794c9d6edd22026e9de2359be
[ "$(git -C "$source_dir" rev-parse HEAD)" = "$expected" ]
[ -z "$(git -C "$source_dir" status --porcelain)" ]
root=$(cd "$(dirname "$0")" && pwd)
tmp=$(mktemp -d "${TMPDIR:-/tmp}/pll-corpus.XXXXXX")
trap 'rm -rf "$tmp"' EXIT
cp "$root/main.go" "$tmp/main.go"
printf 'module pllfixture\n\ngo 1.23\n\nrequire github.com/version2beta/pll v0.0.0\nreplace github.com/version2beta/pll => %s\n' "$source_dir" > "$tmp/go.mod"
(cd "$tmp"; GOPROXY=off GOSUMDB=off GOTOOLCHAIN=local GOWORK=off go run -mod=readonly .)
