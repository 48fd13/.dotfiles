# Dotfiles shell setup. Sourced from ~/.bashrc or ~/.zshrc by setup.sh.
# Every integration is guarded, so a missing tool never breaks the shell.

case $- in *i*) ;; *) return 0 2>/dev/null || exit 0 ;; esac

if [ -n "${ZSH_VERSION:-}" ]; then
  dotfiles_shell=zsh
elif [ -n "${BASH_VERSION:-}" ]; then
  dotfiles_shell=bash
else
  return 0
fi

has() { command -v "$1" >/dev/null 2>&1; }

# PATH: user-local installs (starship, nvim)
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) PATH="$HOME/.local/bin:$PATH" ;; esac

# Debian/Ubuntu ship fd and bat under different names
if ! has fd && has fdfind; then alias fd=fdfind; fi
if ! has bat && has batcat; then alias bat=batcat; fi

# History
HISTSIZE=100000
HISTTIMEFORMAT="%F %T "
if [ "$dotfiles_shell" = bash ]; then
  HISTFILESIZE=200000
  HISTCONTROL=ignoreboth:erasedups
  shopt -s histappend cmdhist checkwinsize globstar 2>/dev/null
else
  SAVEHIST=200000
  HISTFILE="${HISTFILE:-$HOME/.zsh_history}"
  setopt HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS SHARE_HISTORY INC_APPEND_HISTORY
fi

# Editor
if has nvim; then
  export EDITOR=nvim VISUAL=nvim
  alias v=nvim vi=nvim vim=nvim
fi

# fzf: Ctrl-r history, Ctrl-t files, Alt-c directories
if has fzf; then
  if has fd; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  elif has fdfind; then
    export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git'
  fi
  export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND:-}"
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --info=inline
    --color=bg+:#262626,fg:#a2a9b0,fg+:#f2f4f8,hl:#dde1e6,hl+:#ffffff,pointer:#f2f4f8,marker:#a2a9b0,prompt:#787f87,info:#787f87,border:#525252'
  if has bat; then
    export FZF_CTRL_T_OPTS='--preview "bat --color=always --style=numbers --line-range=:200 {}"'
  elif has batcat; then
    export FZF_CTRL_T_OPTS='--preview "batcat --color=always --style=numbers --line-range=:200 {}"'
  fi
  eval "$(fzf --$dotfiles_shell 2>/dev/null)" 2>/dev/null || true
fi

# ls / cat
case "$(uname -s)" in
  Darwin) alias ls='ls -G' ;;
  *) alias ls='ls --color=auto --group-directories-first' ;;
esac
alias ll='ls -lah'
alias la='ls -A'
if has bat; then alias cat='bat --paging=never --style=plain'; fi
if has batcat && ! has bat; then alias cat='batcat --paging=never --style=plain'; fi

# Git / misc shortcuts
alias lg=lazygit
alias gs='git status -sb'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate -20'
alias grep='grep --color=auto'
mkcd() { mkdir -p "$1" && cd "$1"; }

# Prompt hooks. Order matters in bash: starship overwrites PROMPT_COMMAND, so
# it goes first; zoxide and the history flush must be added after it.
if has starship; then eval "$(starship init $dotfiles_shell)"; fi
if [ "$dotfiles_shell" = bash ]; then
  PROMPT_COMMAND="history -a${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
fi
# zoxide: `z foo` jumps to a frequent dir, `zi` is interactive. Must be last.
if has zoxide; then eval "$(zoxide init $dotfiles_shell)"; fi

unset dotfiles_shell
