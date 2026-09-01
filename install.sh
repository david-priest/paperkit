#!/usr/bin/env bash
# Symlink the tools into ~/bin. Idempotent; safe to re-run after a git pull.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$HOME/bin"
for t in paperfind paperget papergap; do
  ln -sfn "$HERE/bin/$t" "$HOME/bin/$t"
  echo "  ~/bin/$t -> $HERE/bin/$t"
done
echo
echo "Add ~/bin to PATH if it is not there, then configure your library:"
echo "  mkdir -p ~/.config/paperkit && \$EDITOR ~/.config/paperkit/stores"
