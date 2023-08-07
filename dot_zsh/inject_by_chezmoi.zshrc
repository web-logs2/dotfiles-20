source ~/.zsh/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.zsh/.p10k.zsh ]] || source ~/.zsh/.p10k.zsh

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

for dir in "$HOME/go/bin" \
  /opt/homebrew/bin \
  /opt/homebrew/sbin \
  "$HOME/bin" \
  "$HOME/bin/darwin" \
  "$HOME/.cargo/bin" \
  "$HOME/.local/bin" \
  "$HOME/.pyenv/bin" \
  "$HOME/.local/share/pnpm" \
  "$HOME/.local/share/nvim/mason/bin"; do
  if [ -d "$dir" ]; then
    export PATH="$dir:$PATH"
  fi
done

export XDG_CONFIG_HOME="$HOME/.config"
export EDITOR=nvim
export PNPM_HOME="$HOME/.local/share/pnpm"

my_key_bindings() {
  :
}

set_fzf_option() {
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

if has_command zellij && [ -n SSH_CONNECTION ] &&
  [ -z VSCODE_GIT_IPC_HANDLE ] && [ -z NVIM ]; then
  export ZELLIJ_AUTO_ATTACH=true
  eval "$(zellij setup --generate-auto-start zsh)"
fi

set_fzf_option

my_key_bindings

alias ..="cd .."
alias lzd=lazydocker
alias lg=lazygit
alias dc=docker-compose
alias svc="sudo systemctl"
alias vi="nvim"
alias cz="chezmoi"

if has_command zoxide; then
  eval "$(zoxide init zsh)"
fi

if has_command joshuto; then
  alias sudor="sudo env JOSHUTO_CONFIG_HOME=$HOME/.config/joshuto joshuto"
fi