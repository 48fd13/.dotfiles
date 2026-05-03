#!/bin/sh
set -eu

dry_run=0

usage() {
  printf 'Usage: %s [--dry-run|--preview|-n]\n' "$0"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run|--preview|-n)
      dry_run=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  shift
done

detect_package_manager() {
  if command -v apt-get >/dev/null 2>&1; then
    printf 'apt'
  elif command -v dnf >/dev/null 2>&1; then
    printf 'dnf'
  elif command -v pacman >/dev/null 2>&1; then
    printf 'pacman'
  elif command -v zypper >/dev/null 2>&1; then
    printf 'zypper'
  elif command -v brew >/dev/null 2>&1; then
    printf 'brew'
  else
    printf 'none'
  fi
}

package_for_tool() {
  tool="$1"
  manager="$2"

  case "$tool:$manager" in
    git:*) printf 'git' ;;
    nvim:*) printf 'neovim' ;;
    tmux:*) printf 'tmux' ;;
    fzf:*) printf 'fzf' ;;
    zoxide:*) printf 'zoxide' ;;
    rg:*) printf 'ripgrep' ;;
    fd:apt) printf 'fd-find' ;;
    fd:*) printf 'fd' ;;
    lazygit:*) printf 'lazygit' ;;
    delta:brew) printf 'git-delta' ;;
    delta:*) printf 'git-delta' ;;
    *) printf '%s' "$tool" ;;
  esac
}

unique_append() {
  item="$1"
  list="$2"

  for existing in $list; do
    if [ "$existing" = "$item" ]; then
      printf '%s' "$list"
      return
    fi
  done

  if [ -n "$list" ]; then
    printf '%s %s' "$list" "$item"
  else
    printf '%s' "$item"
  fi
}

manager="$(detect_package_manager)"
tools="git nvim tmux fzf zoxide rg fd lazygit delta"
packages=""

if [ "$manager" = "none" ]; then
  printf 'No supported package manager detected. Supported: apt, dnf, pacman, zypper, brew.\n' >&2
  exit 1
fi

for tool in $tools; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf 'ok      %s\n' "$tool"
  else
    package="$(package_for_tool "$tool" "$manager")"
    packages="$(unique_append "$package" "$packages")"
    printf 'missing %s -> %s\n' "$tool" "$package"
  fi
done

if [ -z "$packages" ]; then
  printf 'All checked tools are already available.\n'
  exit 0
fi

case "$manager" in
  apt)
    command_text="sudo apt-get update && sudo apt-get install -y $packages"
    ;;
  dnf)
    command_text="sudo dnf install -y $packages"
    ;;
  pacman)
    command_text="sudo pacman -S --needed $packages"
    ;;
  zypper)
    command_text="sudo zypper install -y $packages"
    ;;
  brew)
    command_text="brew install $packages"
    ;;
esac

printf '\nDetected package manager: %s\n' "$manager"
printf 'Planned command:\n%s\n' "$command_text"

if [ "$dry_run" -eq 1 ]; then
  printf 'Dry run only; no packages installed.\n'
  exit 0
fi

printf 'Run this install command? [y/N] '
read answer
case "$answer" in
  y|Y|yes|YES)
    sh -c "$command_text"
    ;;
  *)
    printf 'Aborted; no packages installed.\n'
    ;;
esac
