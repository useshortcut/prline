#!/usr/bin/env bash
# Symlinks prline into ~/.local/bin (or $1).
set -euo pipefail
dest="${1:-$HOME/.local/bin}"
src="$(cd "$(dirname "$0")" && pwd)/bin/prline"
command -v gh >/dev/null || { echo "prline needs the GitHub CLI: https://cli.github.com" >&2; exit 1; }
gh auth status >/dev/null 2>&1 || echo "warning: gh is not authenticated; run 'gh auth login'" >&2
mkdir -p "$dest" && ln -sf "$src" "$dest/prline"
echo "installed $dest/prline"
case ":$PATH:" in *":$dest:"*) ;; *) echo "note: $dest is not on your PATH" ;; esac
