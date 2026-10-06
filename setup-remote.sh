#!/usr/bin/env bash
# Lightweight setup for quick jobs on remote VMs: a few CLI tools and the shell
# config. Needs no root, git or tmux: tools are prebuilt binaries downloaded
# into ~/.local/bin. For a full workstation setup use setup.sh.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib.sh
. "$DOTFILES_DIR/scripts/lib.sh"

export PATH="$HOME/.local/bin:$PATH"

info "Remote setup from $DOTFILES_DIR (no root needed)"
info "Detected OS: $OS"

if ! command -v curl >/dev/null 2>&1; then
  warn "curl is required to download the tools; install it or copy the binaries by hand."
  exit 1
fi

install_release fzf junegunn/fzf "fzf-{v}-linux_{arch}.tar.gz" amd64 arm64
install_release rg BurntSushi/ripgrep "ripgrep-{v}-{arch}.tar.gz" x86_64-unknown-linux-musl aarch64-unknown-linux-gnu
install_release jq jqlang/jq "jq-linux-{arch}" amd64 arm64
install_with_script zoxide https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh
install_with_script starship https://starship.rs/install.sh -y -b "$HOME/.local/bin"

link_path "$DOTFILES_DIR/shell/shell.sh" "$HOME/.config/dotfiles/shell.sh"
link_path "$DOTFILES_DIR/shell/starship.toml" "$HOME/.config/starship.toml"
source_line_in_rc "$HOME/.bashrc"
source_line_in_rc "$HOME/.zshrc"

info "Done. Open a new shell to load the prompt, aliases, fzf and zoxide."
