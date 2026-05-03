# Dotfiles

Standard home directory dotfiles layout with terminal workflow helpers.

Files:
- tmux/.tmux.conf
- nvim/init.lua
- scripts/check-tools.sh
- scripts/install-tools.sh

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


