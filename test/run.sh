#!/usr/bin/env bash
# Renders each fixture offline and diffs against test/expected.txt. Needs jq (dev only).
# Regenerate after intentional output changes: test/run.sh --update
cd "$(dirname "$0")/.." || exit 1
export PRLINE_NO_COLOR=1
render() {
  for f in test/fixtures/*.json; do
    n=$(basename "$f" .json)
    case $n in run-*) m=--format-run ;; mine-*) m=--format-mine ;; *) m=--format-pr ;; esac
    printf '%s\t%s\n' "$n" "$(bin/prline $m < "$f")"
  done
}
if [ "${1:-}" = --update ]; then render > test/expected.txt; echo updated; exit; fi
if diff -u test/expected.txt <(render); then echo "ok: $(wc -l < test/expected.txt | tr -d ' ') fixtures"; else exit 1; fi
