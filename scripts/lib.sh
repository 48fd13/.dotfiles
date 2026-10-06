#!/usr/bin/env bash
# Shared helpers for setup.sh and setup-remote.sh.
# The caller must set DOTFILES_DIR before sourcing this file.

BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
OS="$(uname -s)"
APT_UPDATED=0

# Run privileged commands as root, via sudo, or not at all (returns 1).
run_privileged() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  elif command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  else
    warn "Need root to run: $*"
    return 1
  fi
}

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
      run_privileged apt-get install -y "$package_name"
      ;;
    dnf)
      run_privileged dnf install -y "$package_name"
      ;;
    pacman)
      run_privileged pacman -S --needed "$package_name"
      ;;
    zypper)
      run_privileged zypper install -y "$package_name"
      ;;
    *)
      return 1
      ;;
  esac
}

apt_update() {
  if [ "$APT_UPDATED" -eq 0 ]; then
    run_privileged apt-get update || return 1
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

command_available() {
  case "$1" in
    fd) command -v fd >/dev/null 2>&1 || command -v fdfind >/dev/null 2>&1 ;;
    bat) command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1 ;;
    *) command -v "$1" >/dev/null 2>&1 ;;
  esac
}

# On apt, the `yq` package is a different (Python) tool, so install the
# widely used mikefarah/yq instead: brew where available, else its release binary.
install_yq() {
  if command -v yq >/dev/null 2>&1; then
    info "yq already installed"
  elif command -v brew >/dev/null 2>&1; then
    info "Installing yq"
    brew install yq || warn "Failed to install yq. Install it manually."
  else
    install_release yq mikefarah/yq "yq_linux_{arch}" amd64 arm64
  fi
}

# Install a prebuilt binary from a GitHub release into ~/.local/bin. No root.
# usage: install_release <cmd> <owner/repo> <asset-template> <x86_64-name> <arm64-name>
# Template placeholders: {v} = release version without a leading "v",
# {arch} = the arch name for this CPU. A .tar.gz asset is unpacked and the
# binary named <cmd> is picked out; any other asset is used as the binary.
install_release() {
  local cmd="$1" repo="$2" template="$3" x86="$4" arm="$5"
  local bin_dir="$HOME/.local/bin" arch tag version asset tmp found

  if command -v "$cmd" >/dev/null 2>&1 || [ -x "$bin_dir/$cmd" ]; then
    info "$cmd already installed"
    return
  fi

  if [ "$OS" != "Linux" ] || ! command -v curl >/dev/null 2>&1; then
    warn "$cmd was not installed (needs Linux and curl); install it manually."
    return
  fi

  case "$(uname -m)" in
    x86_64) arch="$x86" ;;
    aarch64|arm64) arch="$arm" ;;
    *) warn "Unsupported CPU architecture for $cmd; install it manually."; return ;;
  esac

  tag="$(curl -fsSLI -o /dev/null -w '%{url_effective}' "https://github.com/$repo/releases/latest")" \
    || { warn "Could not look up the latest $cmd release."; return; }
  tag="${tag##*/}"
  version="${tag#v}"
  asset="${template//\{v\}/$version}"
  asset="${asset//\{arch\}/$arch}"

  tmp="$(mktemp -d)"
  info "Installing $cmd $version"
  mkdir -p "$bin_dir"
  if ! curl -fsSL "https://github.com/$repo/releases/download/$tag/$asset" -o "$tmp/$asset"; then
    warn "Failed to download $asset for $cmd. Install it manually."
  elif [[ "$asset" == *.tar.gz ]]; then
    tar -xzf "$tmp/$asset" -C "$tmp" \
      && found="$(find "$tmp" -type f -name "$cmd" | head -n1)" \
      && [ -n "$found" ] \
      && install -m 755 "$found" "$bin_dir/$cmd" \
      || warn "Failed to unpack $cmd. Install it manually."
  else
    install -m 755 "$tmp/$asset" "$bin_dir/$cmd" || warn "Failed to install $cmd."
  fi
  rm -rf "$tmp"
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

# Clone tpm and install the plugins listed in tmux.conf.
install_tmux_plugins() {
  if ! command -v git >/dev/null 2>&1; then
    warn "git is missing, so tmux plugin manager was not installed"
    return
  fi

  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    info "Installing tmux plugin manager"
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  else
    info "tmux plugin manager already installed"
  fi

  if [ -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]; then
    info "Installing tmux plugins"
    TMUX_PLUGIN_MANAGER_PATH="$HOME/.tmux/plugins/" "$HOME/.tmux/plugins/tpm/bin/install_plugins" \
      || warn "tmux plugin install failed; press prefix + I inside tmux"
  fi
}

# Validate on a throwaway socket so a running tmux server is never touched.
validate_tmux_config() {
  command -v tmux >/dev/null 2>&1 || return 0
  info "Validating tmux config"
  tmux -L dotfiles-validate -f "$HOME/.tmux.conf" start-server \; source-file "$HOME/.tmux.conf" \; kill-server \
    || warn "tmux config validation failed"
}
