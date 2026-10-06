#!/usr/bin/env bash
# Full workstation setup: editor, git UI, prompt, shell and tmux.
# For a lightweight remote/headless setup use setup-remote.sh.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib.sh
. "$DOTFILES_DIR/scripts/lib.sh"

version_at_least() {
  local current="$1"
  local required="$2"

  awk -v current="$current" -v required="$required" 'BEGIN {
    split(current, c, "\\.")
    split(required, r, "\\.")
    for (i = 1; i <= 3; i++) {
      if ((c[i] + 0) > (r[i] + 0)) exit 0
      if ((c[i] + 0) < (r[i] + 0)) exit 1
    }
    exit 0
  }'
}

nvim_version() {
  nvim --version | awk 'NR == 1 { sub(/^v/, "", $2); print $2; exit }'
}

install_latest_neovim() {
  local archive="$HOME/.cache/neovim.tar.gz"
  local install_dir="$HOME/.local/share/neovim/nvim-linux-x86_64"

  if [ "$OS" = "Darwin" ]; then
    if command -v brew >/dev/null 2>&1; then
      brew upgrade neovim || brew install neovim
      return
    fi
    warn "Neovim is too old and Homebrew is unavailable; update Neovim manually."
    return 1
  fi

  if [ "$OS" != "Linux" ] || ! command -v curl >/dev/null 2>&1; then
    warn "Neovim 0.12+ is required; install the latest official Neovim release manually."
    return 1
  fi

  case "$(uname -m)" in
    x86_64) install_dir="$HOME/.local/share/neovim/nvim-linux-x86_64";;
    aarch64|arm64) install_dir="$HOME/.local/share/neovim/nvim-linux-arm64";;
    *) warn "Unsupported CPU architecture for automatic Neovim installation."; return 1;;
  esac

  mkdir -p "$(dirname "$archive")" "$(dirname "$install_dir")" "$HOME/.local/bin"
  curl -fL "https://github.com/neovim/neovim/releases/latest/download/$(basename "$install_dir").tar.gz" -o "$archive"
  mkdir -p "$install_dir"
  tar -xzf "$archive" --strip-components=1 -C "$install_dir"
  ln -sfn "$install_dir/bin/nvim" "$HOME/.local/bin/nvim"
  hash -r 2>/dev/null || true
  info "Installed latest Neovim under $install_dir"
}

ensure_neovim() {
  if ! command_available nvim; then
    return
  fi

  local current
  current="$(nvim_version)"
  if ! version_at_least "$current" "0.12.0"; then
    warn "Neovim $current is older than the required 0.12.0"
    install_latest_neovim
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
install_if_missing bat
install_if_missing tree
install_if_missing jq
install_yq
install_if_missing node
install_if_missing npm
install_if_missing unzip
install_if_missing cc
install_if_missing curl
install_clipboard_tool_if_needed
ensure_neovim
install_with_script starship https://starship.rs/install.sh -y -b "$HOME/.local/bin"

link_path "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
link_path "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
link_path "$DOTFILES_DIR/lazygit/config.yml" "$HOME/.config/lazygit/config.yml"
link_path "$DOTFILES_DIR/git/config" "$HOME/.config/git/config"
link_path "$DOTFILES_DIR/shell/shell.sh" "$HOME/.config/dotfiles/shell.sh"
link_path "$DOTFILES_DIR/shell/starship.toml" "$HOME/.config/starship.toml"
source_line_in_rc "$HOME/.bashrc"
source_line_in_rc "$HOME/.zshrc"

install_tmux_plugins
validate_tmux_config

if command -v nvim >/dev/null 2>&1; then
  info "Bootstrapping Neovim plugins"
  nvim --headless -u "$HOME/.config/nvim/init.lua" '+lua require("lazy").sync({ wait = true })' +qa || warn "Neovim plugin bootstrap failed; open nvim once and run :Lazy sync"
fi

info "Done"
info "If tmux is already running, reload with: tmux source-file ~/.tmux.conf"
info "Inside tmux, install/update plugins with: prefix + I"
