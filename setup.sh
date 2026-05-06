#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
OS="$(uname -s)"

info() {
  printf '\033[1;34m==>\033[0m %s\n' "$1"
}

warn() {
  printf '\033[1;33mwarn:\033[0m %s\n' "$1"
}

backup_path() {
  local path="$1"

  if [ -L "$path" ]; then
    rm "$path"
    return
  fi

  if [ -e "$path" ]; then
    mkdir -p "$BACKUP_DIR$(dirname "$path")"
    mv "$path" "$BACKUP_DIR$path"
    warn "Moved existing $path to $BACKUP_DIR$path"
  fi
}

link_path() {
  local source="$1"
  local target="$2"

  if [ ! -e "$source" ]; then
    warn "Missing source: $source"
    return 1
  fi

  mkdir -p "$(dirname "$target")"

  if [ "$(readlink "$target" 2>/dev/null || true)" = "$source" ]; then
    info "$target already linked"
    return
  fi

  backup_path "$target"
  ln -s "$source" "$target"
  info "Linked $target -> $source"
}

detect_package_manager() {
  if command -v brew >/dev/null 2>&1; then
    printf 'brew'
  elif command -v apt-get >/dev/null 2>&1; then
    printf 'apt'
  elif command -v dnf >/dev/null 2>&1; then
    printf 'dnf'
  elif command -v pacman >/dev/null 2>&1; then
    printf 'pacman'
  elif command -v zypper >/dev/null 2>&1; then
    printf 'zypper'
  else
    printf 'none'
  fi
}

install_package() {
  local package_name="$1"
  local package_manager
  package_manager="$(detect_package_manager)"

  case "$package_manager" in
    brew)
      brew install "$package_name"
      ;;
    apt)
      sudo apt-get update
      sudo apt-get install -y "$package_name"
      ;;
    dnf)
      sudo dnf install -y "$package_name"
      ;;
    pacman)
      sudo pacman -S --needed "$package_name"
      ;;
    zypper)
      sudo zypper install -y "$package_name"
      ;;
    *)
      return 1
      ;;
  esac
}

package_for_command() {
  local command_name="$1"
  local package_manager
  package_manager="$(detect_package_manager)"

  case "$command_name:$package_manager" in
    nvim:*) printf 'neovim' ;;
    git:*) printf 'git' ;;
    tmux:*) printf 'tmux' ;;
    fzf:*) printf 'fzf' ;;
    zoxide:*) printf 'zoxide' ;;
    rg:*) printf 'ripgrep' ;;
    fd:apt) printf 'fd-find' ;;
    fd:*) printf 'fd' ;;
    lazygit:*) printf 'lazygit' ;;
    delta:*) printf 'git-delta' ;;
    wl-copy:*) printf 'wl-clipboard' ;;
    xclip:*) printf 'xclip' ;;
    *) printf '%s' "$command_name" ;;
  esac
}

install_if_missing() {
  local command_name="$1"
  local package_name
  package_name="$(package_for_command "$command_name")"

  if command -v "$command_name" >/dev/null 2>&1; then
    info "$command_name already installed"
    return
  fi

  if [ "$(detect_package_manager)" != "none" ]; then
    info "Installing $package_name"
    install_package "$package_name" || warn "Failed to install $package_name. Install it manually."
  else
    warn "$command_name is not installed. Install $package_name manually."
  fi
}

install_clipboard_tool_if_needed() {
  case "$OS" in
    Darwin)
      info "macOS detected; tmux clipboard will use pbcopy"
      ;;
    Linux)
      if command -v wl-copy >/dev/null 2>&1 || command -v xclip >/dev/null 2>&1 || command -v xsel >/dev/null 2>&1; then
        info "Linux clipboard tool already installed"
      elif [ -n "${WAYLAND_DISPLAY:-}" ]; then
        install_if_missing wl-copy
      else
        install_if_missing xclip
      fi
      ;;
    *)
      warn "Unknown OS: $OS. Clipboard copy from tmux may need manual setup."
      ;;
  esac
}

info "Using dotfiles from $DOTFILES_DIR"
info "Detected OS: $OS"

install_if_missing git
install_if_missing nvim
install_if_missing tmux
install_if_missing fzf
install_if_missing zoxide
install_if_missing rg
install_if_missing fd
install_if_missing lazygit
install_if_missing delta
install_clipboard_tool_if_needed

link_path "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
link_path "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

if command -v git >/dev/null 2>&1; then
  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    info "Installing tmux plugin manager"
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  else
    info "tmux plugin manager already installed"
  fi
else
  warn "git is missing, so tmux plugin manager was not installed"
fi

if command -v tmux >/dev/null 2>&1; then
  info "Validating tmux config"
  tmux -f "$HOME/.tmux.conf" start-server \; source-file "$HOME/.tmux.conf" \; kill-server || warn "tmux config validation failed"
fi

if command -v nvim >/dev/null 2>&1; then
  info "Bootstrapping Neovim plugins"
  nvim --headless '+Lazy! sync' +qa || warn "Neovim plugin bootstrap failed; open nvim once and run :Lazy sync"
fi

info "Done"
info "If tmux is already running, reload with: tmux source-file ~/.tmux.conf"
info "Inside tmux, install/update plugins with: prefix + I"
