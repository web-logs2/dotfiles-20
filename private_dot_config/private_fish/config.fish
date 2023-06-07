# start tmux
# if test -z "$TMUX"; and test "$SSH_CONNECTION" != ""
    # exec sh -c "tmux attach || tmux new"
# end
function hasCommand
  which $argv[1] >/dev/null 2>&1
end

set -gx PATH "/opt/homebrew/bin" "$HOME/.pyenv/shims" "$HOME/bin" "$HOME/.cargo/bin" "$HOME/.local/bin" "$HOME/.pyenv/bin" "$HOME/.local/share/pnpm" "$PATH"

if status is-interactive
    fish_vi_key_bindings

    set -gx EDITOR nvim
    hasCommand code && set -gx EDITOR "code -w"

    set -gx JOSHUTO_CONFIG_HOME ~/dotfiles/joshuto/config

    alias lzd=lazydocker
    alias lg=lazygit
    #alias r=joshuto
    alias dc=docker-compose
    alias svc="sudo systemctl"
    alias vi="nvim"
    alias tm="tmux attach || tmux new"
    alias code-leet="code --remote ssh-remote+home.lubui.com /home/urie/workplace/leetcode"
    alias ce="chezmoi edit --apply"

    # Commands to run in interactive sessions can go here
    hasCommand pyenv && pyenv init - | source
    hasCommand zoxide && zoxide init fish | source
    
    if test "$TMUX" != ""
      alias ssh="TERM=xterm command ssh"  
    end

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

