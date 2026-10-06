# Dotfiles

Standard home directory dotfiles layout with terminal workflow helpers.

Setup scripts:
- `./setup.sh`: full workstation setup (nvim, lazygit, delta, node, tmux plugins, prompt, shell, git config).
- `./setup-remote.sh`: lightweight setup for quick jobs on remote VMs. Needs no root, git or tmux: fzf, ripgrep, jq, zoxide and starship are downloaded as prebuilt binaries into `~/.local/bin`, and the shell config and prompt are linked. Needs only `curl` and outbound HTTPS.
- `scripts/lib.sh`: helpers shared by both scripts.

On a remote VM (no git needed), copy the three pieces the script uses and run it:

```sh
rsync -a --relative setup-remote.sh scripts/lib.sh shell/ user@host:.dotfiles/
ssh user@host '~/.dotfiles/setup-remote.sh'
```

Git identity for the workstation setup is not stored in the repo; set it per machine:
`git config --global user.name "..."` and `git config --global user.email "..."`.

Files:
- tmux/.tmux.conf
- nvim/init.lua
- nvim/lazy-lock.json
- shell/shell.sh, shell/starship.toml
- git/config
- scripts/check-tools.sh
- scripts/install-tools.sh
- scripts/lib.sh
- setup.sh
- setup-remote.sh

Workflow tools checked by the scripts:
- git, nvim, tmux
- fzf, zoxide, ripgrep (`rg`), fd
- lazygit, delta

## Neovim

The Neovim config uses `lazy.nvim` for plugins. Press `Space` (the leader key)
to open `which-key.nvim` and discover shortcut groups.

Leader groups include:
- `Space f`: files/search (`ff` find files, `fg` live grep, `fb` buffers, `fr` recent files)
- `Space g`: git (`gf` git files, `gs` git status, `gc` commits)
- `Space b`: buffers (`bb` list buffers, `bd` delete, `bn`/`bp` next/previous)
- `Space w`: windows (`wh`/`wj`/`wk`/`wl` move, `ws` split, `wv` vertical split)
- `Space c`: code/LSP (`ca` code action, `cd` line diagnostics, `cr` rename)
- `Space e`: toggle Neo-tree and reveal the current file
- `Space E`: reveal the current file in Neo-tree

Existing direct LSP mappings such as `gd`, `gr`, `K`, `Space rn`, and
`Space ca` are kept.

## Setup

Run the setup script from the repo:

```sh
cd /path/to/dotfiles
./setup.sh
```

The setup script:
- installs/checks core tools where a supported package manager is available
- backs up existing real config paths under `~/.dotfiles-backup/`
- links `~/.config/nvim` to `<dotfiles>/nvim`
- links `~/.tmux.conf` to `<dotfiles>/tmux/.tmux.conf`
- bootstraps tmux TPM and Neovim lazy.nvim plugins when possible

## Tool checks and optional installs

Check for expected workflow tools without installing anything:

```sh
./scripts/check-tools.sh
```

Preview the install command for missing tools:

```sh
./scripts/install-tools.sh --dry-run
```

The install helper detects `apt`, `dnf`, `pacman`, `zypper`, or `brew`, maps
package names where they differ, prints the planned command, and asks for
confirmation before running it. It is package-manager-neutral; Homebrew is
supported when present but is not required or assumed.
