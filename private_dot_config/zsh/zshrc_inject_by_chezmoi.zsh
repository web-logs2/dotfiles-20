typeset -U path
path=(
  "$HOME/go/bin"
  /opt/homebrew/bin
  /opt/homebrew/sbin
  "$HOME/bin"
  "$HOME/bin/darwin"
  "$HOME/.cargo/bin"
  "$HOME/.local/bin"
  "$HOME/.pyenv/bin"
  "$HOME/.local/share/pnpm"
  "$HOME/.local/share/nvim/mason/bin"
  $path
)
export PATH

has_command() {
  command -v "$1" >/dev/null 2>&1
}

if has_command zellij && [[ -n $SSH_CONNECTION ]] &&
  [[ -z $VSCODE_GIT_IPC_HANDLE ]] && [[ -z $NVIM ]]; then
  ZELLIJ_AUTO_ATTACH=true
  eval "$(zellij setup --generate-auto-start zsh)"
fi

function zcompile-many() {
  local f
  for f; do zcompile -R -- "$f".zwc "$f"; done
}

ZSH_CONFIG_PATH="$HOME/.config/zsh"

mkdir -p "$ZSH_CONFIG_PATH"

# Clone and compile to wordcode missing plugins.
if [[ ! -e "${ZSH_CONFIG_PATH}"/zsh-syntax-highlighting ]]; then
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CONFIG_PATH}"/zsh-syntax-highlighting
  zcompile-many "${ZSH_CONFIG_PATH}"/zsh-syntax-highlighting/{zsh-syntax-highlighting.zsh,highlighters/*/*.zsh}
fi
if [[ ! -e "${ZSH_CONFIG_PATH}"/zsh-autosuggestions ]]; then
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git "${ZSH_CONFIG_PATH}"/zsh-autosuggestions
  zcompile-many "${ZSH_CONFIG_PATH}"/zsh-autosuggestions/{zsh-autosuggestions.zsh,src/**/*.zsh}
fi
if [[ ! -e "${ZSH_CONFIG_PATH}"/powerlevel10k ]]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CONFIG_PATH}"/powerlevel10k
  make -C "${ZSH_CONFIG_PATH}"/powerlevel10k pkg
fi

function source_if_exist() {
  local fp="$1"
  if [[ -f $fp ]]; then
    source "$fp"
  fi
}

# Activate Powerlevel10k Instant Prompt.
source_if_exist "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"

# Enable the "new" completion system (compsys).
autoload -Uz compinit && compinit
[[ ~/.zcompdump.zwc -nt ~/.zcompdump ]] || zcompile-many ~/.zcompdump
unfunction zcompile-many

ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# Load plugins.
source "${ZSH_CONFIG_PATH}"/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source "${ZSH_CONFIG_PATH}"/zsh-autosuggestions/zsh-autosuggestions.zsh
source "${ZSH_CONFIG_PATH}"/powerlevel10k/powerlevel10k.zsh-theme
source "${ZSH_CONFIG_PATH}"/powerlevel10k/config/p10k-robbyrussell.zsh

unset ZSH_CONFIG_PATH

export XDG_CONFIG_HOME="$HOME/.config"
export EDITOR=nvim
export PNPM_HOME="$HOME/.local/share/pnpm"

conda-init() {
  conda shell.zsh hook | source
  if has_command fzf; then
    conda activate $(conda env list | grep -vE '^\s*#' | grep -vE '^$' | fzf --bind "enter:become(echo {1})")
  fi
}

pyenv-init() {
  pyenv init - | source
  pyenv versions
  echo -n "exec $(python -V): "
  python -V
}

tm() {
  if [[ -n $ZELLIJ ]]; then
    echo "already in zellij session"
    return 1
  elif [[ -n $TMUX ]]; then
    echo "already in tmux session"
    return 1
  elif has_command zellij; then
    zellij attach -c
  elif has_command tmux; then
    tmux attach || tmux new
  else
    echo 'zellij/tmux command not found'
  fi
}

editor-detect() {
  if has_command code; then
    if [[ -n $SSH_CONNECTION ]] || [[ -n $VSCODE_GIT_IPC_HANDLE ]]; then
      export EDITOR="code -w"
    fi
  fi
  env | grep EDITOR
}

if has_command joshuto; then
  r() {
    local ID="$$"
    mkdir -p /tmp/$USER
    local OUTPUT_FILE="/tmp/$USER/joshuto-cwd-$ID"
    env joshuto --output-file "$OUTPUT_FILE" $@
    local exit_code=$?

    case "$exit_code" in
    # regular exit
    0) ;;
    # output contains current directory
    101)
      cd "$(cat "$OUTPUT_FILE")"
      ;;
    # output selected files
    102) ;;
    *)
      echo "Exit code: $exit_code"
      ;;
    esac
  }
fi

# set fzf option
function() {
  export FZF_DEFAULT_COMMAND="fd --strip-cwd-prefix --follow --exclude node_modules"
  export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
  local FZF_CTRL_D_COMMAND="$FZF_DEFAULT_COMMAND --type d"
  local FZF_CTRL_F_COMMAND="$FZF_DEFAULT_COMMAND --type f"
  export FZF_CTRL_T_OPTS="$FZF_DEFAULT_OPTS \
      --prompt 'All> ' \
      --bind \"ctrl-d:change-prompt(Directories> )+reload($FZF_CTRL_D_COMMAND)\" \
      --bind \"ctrl-f:change-prompt(Files> )+reload($FZF_CTRL_F_COMMAND)\" \
      --bind \"ctrl-a:change-prompt(All> )+reload($FZF_DEFAULT_COMMAND)\""
}

# set vi keybind
set -o vi
source_if_exist ~/.config/zsh/fzf-key-bindings.zsh
source_if_exist ~/.config/zsh/fzf-completion.zsh

alias ..="cd .."
alias lzd=lazydocker
alias lg=lazygit
alias dc=docker-compose
alias svc="sudo systemctl"
alias vi="nvim"
alias cz="chezmoi"

if has_command joshuto; then
  alias sudor="sudo env JOSHUTO_CONFIG_HOME=$HOME/.config/joshuto joshuto"
fi

if has_command zoxide; then
  eval "$(zoxide init zsh)"
fi

# enable zsh history
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
