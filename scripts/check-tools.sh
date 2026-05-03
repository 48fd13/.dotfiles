#!/bin/sh

tools="git nvim tmux fzf zoxide rg fd lazygit delta"
missing=0

for tool in $tools; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf 'ok      %s (%s)\n' "$tool" "$(command -v "$tool")"
  else
    printf 'missing %s\n' "$tool"
    missing=1
  fi
done

exit "$missing"
