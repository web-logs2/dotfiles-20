function hasCommand
  which $argv[1] >/dev/null 2>&1
end

function tm
  if test -z "$TMUX"
    tmux attach || tmux new
  else
    echo already in tmux session
    return 1
  end
end

# function ssh
#   if test "$TMUX" != ""
#     TERM=xterm-256color command ssh $argv
#   else
#     command ssh $argv
#   end
# end

set -gx PATH "/opt/homebrew/bin" "$HOME/.pyenv/shims" "$HOME/bin" "$HOME/.cargo/bin" "$HOME/.local/bin" "$HOME/.pyenv/bin" "$HOME/.local/share/pnpm" "$PATH"

if status is-interactive
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
  alias code-leet="code --remote ssh-remote+home.lubui.com /home/urie/workplace/leetcode"
  alias ce="chezmoi edit --apply"

  # Commands to run in interactive sessions can go here
  hasCommand pyenv && pyenv init - | source
  hasCommand zoxide && zoxide init fish | source

  # pnpm
  set -gx PNPM_HOME "$HOME/.local/share/pnpm"
  if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
  end
  # pnpm end

  if hasCommand joshuto
    function r
      set ID %self
      mkdir -p /tmp/$USER
      set OUTPUT_FILE "/tmp/$USER/joshuto-cwd-$ID"
      if not joshuto --output-file "$OUTPUT_FILE" $argv
        set JOSHUTO_CWD $(cat "$OUTPUT_FILE")
        cd "$JOSHUTO_CWD"
      end
    end
  end

end

