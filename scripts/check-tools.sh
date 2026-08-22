#!/bin/sh

tools="git nvim tmux fzf zoxide rg fd lazygit delta node npm unzip cc"
missing=0

tool_available() {
  case "$1" in
    fd) command -v fd >/dev/null 2>&1 || command -v fdfind >/dev/null 2>&1 ;;
    *) command -v "$1" >/dev/null 2>&1 ;;
  esac
}

for tool in $tools; do
  if tool_available "$tool"; then
    printf 'ok      %s\n' "$tool"
  else
    printf 'missing %s\n' "$tool"
    missing=1
  fi
done

exit "$missing"
