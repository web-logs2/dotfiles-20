function hasCommand
  which $argv[1] >/dev/null 2>&1
end

set -gx PATH "$HOME/go/bin" "/opt/homebrew/bin" "$HOME/.pyenv/shims" "$HOME/bin" "$HOME/.cargo/bin" "$HOME/.local/bin" "$HOME/.pyenv/bin" "$HOME/.local/share/pnpm" "$PATH"

if test -e $HOME/.config/fish/custom.fish
  source $HOME/.config/fish/custom.fish
end

if status is-interactive
  if hasCommand zellij; and set -q "SSH_CONNECTION"
    set ZELLIJ_AUTO_ATTACH true
    # set ZELLIJ_AUTO_EXIT true
    eval (zellij setup --generate-auto-start fish | string collect)
  end

  fish_vi_key_bindings

  set -gx EDITOR nvim
  hasCommand code && set -gx EDITOR "code -w"
  set -gx XDG_CONFIG_HOME "$HOME/.config"

  alias ..="cd .."

  alias lzd=lazydocker
  alias lg=lazygit
  #alias r=joshuto
  alias dc=docker-compose
  alias svc="sudo systemctl"
  alias vi="nvim"
  alias code-note='code --folder-uri "vscode-remote://ssh-remote+home.lubui.com/home/urie/workspace/ts/code-notes-vitepress/docs"'
  # alias code-home="code --remote ssh-remote+home.lubui.com ~"
  alias cz="chezmoi"

  # Commands to run in interactive sessions can go here
  hasCommand pyenv && pyenv init - | source
  hasCommand zoxide && zoxide init fish | source

  # pnpm
  set -gx PNPM_HOME "$HOME/.local/share/pnpm"
  if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
  end
  # pnpm end
  
  function tm
    if set -q ZELLIJ
      echo already in zellij session
      return 1
    else if set -q TMUX
      echo already in tmux session
      return 1
    else if hasCommand zellij
      zellij attach -c
    else if hasCommand tmux
      tmux attach || tmux new
    else
      echo 'zellij/tmux command not found'
    end
  end

  if hasCommand joshuto
    function r
      set ID %self
      mkdir -p /tmp/$USER
      set OUTPUT_FILE "/tmp/$USER/joshuto-cwd-$ID"
      if not joshuto --output-file "$OUTPUT_FILE" $argv
        cd (cat "$OUTPUT_FILE")
      end
    end
  end

end

