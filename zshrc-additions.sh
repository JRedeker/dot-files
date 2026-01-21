# =============================================================================
# OpenCode ZSH Configuration Additions
# Source this file from your .zshrc or copy the relevant sections
# =============================================================================

# =============================================================================
# 1. CRITICAL PATH & NVM SETUP (MUST BE FIRST)
# =============================================================================

# Ensure standard paths are loaded first
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# ----- NVM (Standard Loader) -----
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# ----- Terminal Capability -----
export TERM=xterm-256color
export COLORTERM=truecolor

# ----- Color Support -----
if command -v dircolors >/dev/null; then
  eval "$(dircolors -b)"
fi

# GCC colored output
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Colored man pages / less
export LESS='-R'
export LESS_TERMCAP_mb=$'\e[1;31m'     # begin blink
export LESS_TERMCAP_md=$'\e[1;36m'     # begin bold
export LESS_TERMCAP_me=$'\e[0m'        # reset
export LESS_TERMCAP_so=$'\e[1;33m'     # begin standout
export LESS_TERMCAP_se=$'\e[0m'        # end standout
export LESS_TERMCAP_us=$'\e[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\e[0m'        # end underline

# =============================================================================
# 2. HISTORY & BEHAVIOR
# =============================================================================
HISTFILE="$HOME/.zsh_history"
HISTSIZE=500000
SAVEHIST=500000
setopt inc_append_history       # Add to history immediately
# setopt share_history          # Disabled - causes I/O blocking with large history
setopt hist_ignore_all_dups     # Don't save duplicates
setopt extended_history         # Save timestamps

# =============================================================================
# 3. COMPLETION SYSTEM
# =============================================================================
autoload -Uz compinit
mkdir -p "$HOME/.cache/zsh"
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit -d "$HOME/.cache/zsh/compdump"
else
  compinit -C -d "$HOME/.cache/zsh/compdump"
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case insensitive

# =============================================================================
# 4. PLUGINS (Install these first - see install.sh)
# =============================================================================

# A. Powerlevel10k Theme
if [[ -r "$HOME/.zsh/plugins/powerlevel10k/powerlevel10k.zsh-theme" ]]; then
  source "$HOME/.zsh/plugins/powerlevel10k/powerlevel10k.zsh-theme"
fi

# B. zsh-autosuggestions (The "Ghost Text" - Use Right Arrow to accept)
if [[ -r "$HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'
  ZSH_AUTOSUGGEST_STRATEGY=(history)
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
fi

# C. Fast Syntax Highlighting (Must be loaded LAST)
if [[ -r "$HOME/.zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ]]; then
  source "$HOME/.zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
fi

# Load p10k config if it exists
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# =============================================================================
# 5. INTEGRATIONS & ALIASES
# =============================================================================

# FZF Defaults
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git 2>/dev/null || rg --files --hidden --follow --glob "!.git" 2>/dev/null'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Python / Pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv >/dev/null; then
  eval "$(pyenv init - zsh)"
fi

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Common Aliases
alias ll='ls -alF'
alias gs='git status -sb'
alias reload='source ~/.zshrc'
alias lsa='ls -a'
alias cdd='cd ~/dev/'
alias cdh='cd ~'

# =============================================================================
# 6. OPENCODE CONFIGURATION
# =============================================================================

# Add opencode to PATH
export PATH=$HOME/.opencode/bin:$PATH

# MORPH_API_KEY - Get your own key from morph.ai
# export MORPH_API_KEY="YOUR_MORPH_API_KEY_HERE"

# Scratch directory shortcut - creates dated scratch folder and opens opencode
alias cds='mkdir -p ~/scratch/$(date +%Y-%m-%d) && cd ~/scratch/$(date +%Y-%m-%d) && oc'

# Wrap opencode in tmux for crash isolation (prevents WSL2 cascade failures)
oc() {
  local session_name="oc-$(date +%s)-$$"

  if command -v tmux &>/dev/null; then
    tmux new-session -d -s "$session_name" opencode "$@"
    tmux attach-session -t "$session_name"
  else
    echo "tmux not installed - running opencode directly (no isolation)"
    command opencode "$@"
  fi
}

# List all opencode tmux sessions
oc-list() {
  tmux ls 2>/dev/null | grep "^oc-" || echo "No opencode sessions"
}

# Kill all opencode tmux sessions
oc-killall() {
  tmux ls 2>/dev/null | grep "^oc-" | cut -d: -f1 | xargs -r -n1 tmux kill-session -t
  echo "All opencode sessions terminated"
}
