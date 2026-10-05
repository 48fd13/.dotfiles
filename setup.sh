#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
OS="$(uname -s)"
APT_UPDATED=0

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
      apt_update
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

apt_update() {
  if [ "$APT_UPDATED" -eq 0 ]; then
    sudo apt-get update || return 1
    APT_UPDATED=1
  fi
}

apt_package_available() {
  local package_name="$1"

  if ! command -v apt-cache >/dev/null 2>&1; then
    return 0
  fi

  apt_update || return 0
  apt-cache show "$package_name" >/dev/null 2>&1
}

manual_install_hint() {
  local command_name="$1"

  case "$command_name" in
    zoxide)
      printf 'Older Ubuntu repositories may not package zoxide; use the official install instructions or a newer package source.'
      ;;
    lazygit)
      printf 'Older Ubuntu repositories may not package lazygit; use the official release packages or a newer package source.'
      ;;
    delta)
      printf 'Older Ubuntu repositories may not package git-delta; use the official delta release packages or a newer package source.'
      ;;
    *)
      return 1
      ;;
  esac
}

warn_manual_install() {
  local command_name="$1"
  local package_name="$2"
  local hint

  hint="$(manual_install_hint "$command_name" || true)"
  if [ -n "$hint" ]; then
    warn "$command_name is not installed and apt package $package_name is unavailable. $hint"
  else
    warn "$command_name is not installed and apt package $package_name is unavailable. Install it manually."
  fi
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
    node:apt) printf 'nodejs' ;;
    cc:apt) printf 'build-essential' ;;
    cc:dnf) printf 'gcc' ;;
    cc:pacman) printf 'base-devel' ;;
    cc:zypper) printf 'gcc' ;;
    *) printf '%s' "$command_name" ;;
  esac
}

install_if_missing() {
  local command_name="$1"
  local package_name
  local package_manager
  package_name="$(package_for_command "$command_name")"
  package_manager="$(detect_package_manager)"

  if command_available "$command_name"; then
    info "$command_name already installed"
    return
  fi

  if [ "$package_manager" = "apt" ] && ! apt_package_available "$package_name"; then
    warn_manual_install "$command_name" "$package_name"
  elif [ "$package_manager" != "none" ]; then
    info "Installing $package_name"
    install_package "$package_name" || warn "Failed to install $package_name. Install it manually."
  else
    warn "$command_name is not installed. Install $package_name manually."
  fi
}

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

command_available() {
  case "$1" in
    fd) command -v fd >/dev/null 2>&1 || command -v fdfind >/dev/null 2>&1 ;;
    bat) command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1 ;;
    *) command -v "$1" >/dev/null 2>&1 ;;
  esac
}

# On apt, the `yq` package is a different (Python) tool, so install the
# widely used mikefarah/yq from its release binary instead.
install_yq() {
  if command -v yq >/dev/null 2>&1; then
    info "yq already installed"
    return
  fi

  if command -v brew >/dev/null 2>&1; then
    info "Installing yq"
    brew install yq || warn "Failed to install yq. Install it manually."
    return
  fi

  local arch
  case "$(uname -m)" in
    x86_64) arch=amd64 ;;
    aarch64|arm64) arch=arm64 ;;
    *) warn "Unsupported CPU architecture for yq; install it manually."; return ;;
  esac

  if [ "$OS" != "Linux" ] || ! command -v curl >/dev/null 2>&1; then
    warn "yq was not installed; install mikefarah/yq manually."
    return
  fi

  info "Installing yq"
  mkdir -p "$HOME/.local/bin"
  curl -fsSL "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_$arch" -o "$HOME/.local/bin/yq" \
    && chmod +x "$HOME/.local/bin/yq" \
    || warn "Failed to install yq. Install it manually."
}

# starship is not in older distro repos; use its official installer into
# ~/.local/bin.
install_with_script() {
  local command_name="$1"
  local url="$2"
  shift 2

  if command -v "$command_name" >/dev/null 2>&1 || [ -x "$HOME/.local/bin/$command_name" ]; then
    info "$command_name already installed"
    return
  fi

  if ! command -v curl >/dev/null 2>&1; then
    warn "curl is missing, so $command_name was not installed"
    return
  fi

  info "Installing $command_name"
  mkdir -p "$HOME/.local/bin"
  curl -fsSL "$url" | sh -s -- "$@" || warn "Failed to install $command_name. Install it manually."
}

source_line_in_rc() {
  local rc="$1"
  local line='[ -f "$HOME/.config/dotfiles/shell.sh" ] && . "$HOME/.config/dotfiles/shell.sh"'

  [ -f "$rc" ] || return 0
  if grep -qF '.config/dotfiles/shell.sh' "$rc"; then
    info "$rc already sources dotfiles shell config"
  else
    printf '\n# dotfiles shell setup\n%s\n' "$line" >> "$rc"
    info "Added dotfiles shell config to $rc"
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

if [ -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]; then
  info "Installing tmux plugins"
  TMUX_PLUGIN_MANAGER_PATH="$HOME/.tmux/plugins/" "$HOME/.tmux/plugins/tpm/bin/install_plugins" || warn "tmux plugin install failed; press prefix + I inside tmux"
fi

if command -v tmux >/dev/null 2>&1; then
  info "Validating tmux config"
  # Use a throwaway socket so validation never touches the running tmux server.
  tmux -L dotfiles-validate -f "$HOME/.tmux.conf" start-server \; source-file "$HOME/.tmux.conf" \; kill-server || warn "tmux config validation failed"
fi

if command -v nvim >/dev/null 2>&1; then
  info "Bootstrapping Neovim plugins"
  nvim --headless -u "$HOME/.config/nvim/init.lua" '+lua require("lazy").sync({ wait = true })' +qa || warn "Neovim plugin bootstrap failed; open nvim once and run :Lazy sync"
fi

info "Done"
info "If tmux is already running, reload with: tmux source-file ~/.tmux.conf"
info "Inside tmux, install/update plugins with: prefix + I"
