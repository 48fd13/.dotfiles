# Dotfiles

Terminal setup for development and security/devops work: Neovim, tmux, a
monochrome shell with a starship prompt, and a shared git config. There are two
installers: a full one for a workstation and a no-root one for remote VMs.

## Layout

```
setup.sh              full workstation setup
setup-remote.sh       lightweight, no-root setup for remote VMs
scripts/lib.sh        helpers shared by both setup scripts
scripts/check-tools.sh     report which workflow tools are installed
scripts/install-tools.sh   preview/run package-manager installs for missing tools
nvim/                 Neovim config (lazy.nvim, carbonfox colorscheme)
tmux/.tmux.conf       tmux config and plugins
shell/shell.sh        shell config (history, fzf, zoxide, aliases, prompt)
shell/starship.toml   monochrome starship prompt
git/config            shared git settings
lazygit/config.yml    lazygit config
```

## Install

### Workstation

```sh
git clone <repo-url> ~/.dotfiles
cd ~/.dotfiles
./setup.sh
```

`setup.sh`:
- installs missing tools with the detected package manager (`apt`, `dnf`,
  `pacman`, `zypper` or `brew`); privileged steps run as root, via `sudo`, or
  are skipped with a warning
- installs `yq` (mikefarah) and `starship` into `~/.local/bin` when they are not
  packaged
- installs or upgrades Neovim to 0.12+ from the official release if needed
- backs up existing real config files under `~/.dotfiles-backup/<timestamp>/`
  and then links the repo files into place
- adds one line to `~/.bashrc` (and `~/.zshrc` if present) that sources the
  shell config
- installs tmux TPM and its plugins, validates the tmux config on a throwaway
  socket (a running tmux server is never touched), and syncs Neovim plugins

It is safe to run again; already-installed tools and correct links are skipped.

Linked files:

| Repo file | Target |
|---|---|
| `tmux/.tmux.conf` | `~/.tmux.conf` |
| `nvim/` | `~/.config/nvim` |
| `lazygit/config.yml` | `~/.config/lazygit/config.yml` |
| `git/config` | `~/.config/git/config` |
| `shell/shell.sh` | `~/.config/dotfiles/shell.sh` |
| `shell/starship.toml` | `~/.config/starship.toml` |

After installing: open a new shell, and if tmux is already running reload it
with `Ctrl-a r` (or `tmux source-file ~/.tmux.conf`). Inside tmux, `Ctrl-a I`
installs or updates plugins.

Git identity is not stored in the repo. Set it per machine:

```sh
git config --global user.name "..."
git config --global user.email "..."
```

### Remote VMs (quick hop-in, hop-out jobs)

`setup-remote.sh` needs no root, git or tmux. It downloads prebuilt binaries
into `~/.local/bin` and links only the shell config and prompt:

- `fzf`, `rg` (ripgrep), `jq` from their GitHub releases
- `zoxide` and `starship` from their official install scripts
- `shell/shell.sh` and `shell/starship.toml`

It needs only `curl` and outbound HTTPS (to GitHub, `starship.rs` and
`raw.githubusercontent.com`). Downloads are not checksum-verified.

Copy just the files the script uses, then run it:

```sh
rsync -a --relative setup-remote.sh scripts/lib.sh shell/ user@host:.dotfiles/
ssh user@host '~/.dotfiles/setup-remote.sh'
```

## Shell (`shell/shell.sh`)

Sourced from `~/.bashrc` or `~/.zshrc`. Every integration is guarded, so a
missing tool is skipped silently.

- **History:** 100k lines, timestamped (`HISTTIMEFORMAT`), duplicates removed,
  written after every command in bash so it survives a crash
- **fzf:** `Ctrl-r` history, `Ctrl-t` file picker (with `bat` preview when
  available), `Alt-c` directory jump, monochrome theme
- **zoxide:** `z foo` jumps to a frequent directory, `zi foo` picks
  interactively. It learns from your normal `cd` use; `cd` itself is unchanged
- **Prompt:** starship, monochrome, shows git branch and status, language
  versions, command duration and `user@host` over SSH
- **Aliases:** `ll` (`ls -lah`), `la`, `lg` (lazygit), `gs`, `gd`, `gl`, `v`
  (nvim), and `mkcd`. `cat` uses `bat` when installed
- Debian/Ubuntu names are handled (`fdfind` as `fd`, `batcat` as `bat`)

In bash, starship replaces `PROMPT_COMMAND`, so the file initializes starship
first and adds the history flush and zoxide hooks after it. Keep that order.

## tmux (`tmux/.tmux.conf`)

Prefix is `Ctrl-a`.

| Keys | Action |
|---|---|
| `Ctrl-a r` | reload config |
| `Ctrl-a h/j/k/l` | move between panes |
| `Ctrl-a H/J/K/L` or arrows | resize panes |
| `Ctrl-a "`, `%`, `-`, `\|` | split (opens in the current directory) |
| `Ctrl-a c` | new window (current directory) |
| `Alt-i` | toggle a bottom terminal pane |
| `Ctrl-a Ctrl-a` | send the prefix to a nested tmux |
| copy mode | vi keys; `v` select, `y`/`Enter` copy to the system clipboard |

Other behavior: mouse on, 50k-line scrollback, windows numbered from 1 and
renumbered, monochrome status bar. On SSH sessions the status bar shows
`session@host` so a nested tmux is obvious.

Plugins (via TPM; the config only loads TPM when it is installed):
- `tmux-resurrect` and `tmux-continuum`: save sessions automatically and restore
  on start. Manual restore: `Ctrl-a Ctrl-r`. Snapshots live in
  `~/.local/share/tmux/resurrect/`. Auto-restore only fires on a fresh tmux
  server, so use the manual restore after a crash or kill
- `tmux-which-key`: key hints
- `tmux-logging`: `Ctrl-a Shift-P` toggles logging for a pane,
  `Ctrl-a Alt-Shift-P` saves the full scrollback, `Ctrl-a Alt-c` clears it

## Git (`git/config`)

Shared defaults, no identity. `delta` is the pager. Notable settings:
`init.defaultBranch = main`, merge-style pulls (`pull.rebase = false`),
`rebase.autoStash`/`autoSquash`, `push.autoSetupRemote`, `fetch.prune`,
`merge.conflictStyle = zdiff3`, `diff.algorithm = histogram`, `rerere`.

## Neovim

Plugins are managed by `lazy.nvim`. The colorscheme is plain `carbonfox`
(nightfox.nvim) with no custom color overrides. Markdown is rendered by
`markview.nvim` with its `marker` heading preset. Press `Space` (the leader
key) to open `which-key.nvim` and discover shortcut groups.

Leader groups:
- `Space f`: files/search (`ff` find files, `fg` live grep, `fb` buffers, `fr` recent files)
- `Space g`: git (`gf` git files, `gs` git status, `gc` commits)
- `Space b`: buffers (`bb` list buffers, `bd` delete, `bn`/`bp` next/previous)
- `Space w`: windows (`wh`/`wj`/`wk`/`wl` move, `ws` split, `wv` vertical split)
- `Space c`: code/LSP (`ca` code action, `cd` line diagnostics, `cr` rename)
- `Space h`: harpoon (`ha` add, `hh` menu, `1`-`4` jump)
- `Space e`: toggle Neo-tree and reveal the current file
- `Space E`: reveal the current file in Neo-tree

Direct LSP mappings such as `gd`, `gr`, `K`, `Space rn` and `Space ca` are kept.

## Tool checks

Check which workflow tools are installed, without changing anything:

```sh
./scripts/check-tools.sh
```

Preview the install command for missing tools, or run it after confirming:

```sh
./scripts/install-tools.sh --dry-run
./scripts/install-tools.sh
```

Checked tools: git, nvim, tmux, fzf, zoxide, rg, fd, lazygit, delta, bat, tree,
jq, yq, starship, node, npm, unzip, cc and curl. The install helper maps package
names per package manager, prints the planned command and asks before running
it. Homebrew is supported but not required. `yq` and `starship` are installed by
`setup.sh` instead, since distro packages are missing or different.

## Notes

- Neo-tree, markview and starship use Nerd Font glyphs; the terminal needs a
  Nerd Font to show them.
- `setup-remote.sh` and the shell file are the parts to reuse on machines
  without a Nerd Font or root: the prompt symbols are the only font-dependent
  piece there.
