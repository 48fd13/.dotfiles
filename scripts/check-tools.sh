#!/bin/sh

tools="git nvim tmux fzf zoxide rg fd lazygit delta bat tree jq yq starship node npm unzip cc curl"
missing=0

tool_available() {
  case "$1" in
    fd) command -v fd >/dev/null 2>&1 || command -v fdfind >/dev/null 2>&1 ;;
    bat) command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1 ;;
    *) command -v "$1" >/dev/null 2>&1 ;;
  esac
}

for tool in $tools; do
  if tool_available "$tool"; then
    if [ "$tool" = "nvim" ]; then
      version=$(nvim --version | awk 'NR == 1 { sub(/^v/, "", $2); print $2; exit }')
      printf 'ok      %s (%s)\n' "$tool" "$version"
    else
      printf 'ok      %s\n' "$tool"
    fi
  else
    printf 'missing %s\n' "$tool"
    missing=1
  fi
done

exit "$missing"
