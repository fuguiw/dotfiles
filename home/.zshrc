# Enable Powerlevel10k instant prompt when cached prompt data exists.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
export GOPATH="$HOME/go"
export EDITOR="${EDITOR:-nvim}"
export LANG="${LANG:-en_US.UTF-8}"

typeset -U path PATH

# Prepend directories to PATH when they exist.
path_prepend() {
  local dir
  for dir in "$@"; do
    [[ -d "$dir" ]] && path=("$dir" $path)
  done
}

# Append directories to PATH when they exist.
path_append() {
  local dir
  for dir in "$@"; do
    [[ -d "$dir" ]] && path+=("$dir")
  done
}

path_prepend \
  "$HOME/.local/bin" \
  "$HOME/.bun/bin" \
  "/opt/homebrew/bin" \
  "/opt/homebrew/sbin" \
  "/usr/local/bin" \
  "/usr/local/sbin"
path_append "$GOPATH/bin"
export PATH

if [[ -d "$ZSH" ]]; then
  plugins=(
    git
    macos
    z
  )

  if [[ -r "$ZSH/custom/themes/powerlevel10k/powerlevel10k.zsh-theme" ]]; then
    ZSH_THEME="powerlevel10k/powerlevel10k"
  else
    ZSH_THEME="robbyrussell"
  fi

  source "$ZSH/oh-my-zsh.sh"
fi

alias reload!='source ~/.zshrc'
alias python='python3'
alias pip='pip3'

if command -v nvim >/dev/null 2>&1; then
  alias vim='nvim'
else
  export EDITOR="vim"
fi

if [[ -t 1 ]]; then
  export GPG_TTY="$(tty)"
fi

[[ -r "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"
[[ -r "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

[[ -r "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

if command -v codex >/dev/null 2>&1; then
  eval "$(codex completion zsh)"
fi

if (( ${+functions[p10k]} )) && [[ -r "$HOME/.p10k.zsh" ]]; then
  source "$HOME/.p10k.zsh"
fi

[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
[[ -r "$HOME/.config/zsh/local.zsh" ]] && source "$HOME/.config/zsh/local.zsh"
