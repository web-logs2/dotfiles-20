function hasCommand
    command -v $argv[1] >/dev/null 2>&1
end

for dir in "$HOME/go/bin" /opt/homebrew/bin /opt/homebrew/sbin "$HOME/bin" "$HOME/.cargo/bin" "$HOME/.local/bin" "$HOME/.pyenv/bin" "$HOME/.local/share/pnpm" "$HOME/.local/share/nvim/mason/bin"
    if test -e "$dir"
        set -gx PATH "$dir" "$PATH"
    end
end

function my_key_bindings
    fish_vi_key_bindings
    fzf_key_bindings
    bind -M insert \cA beginning-of-line
    bind -M insert \cE end-of-line
end

function set_fzf_option
    if hasCommand fd
        set -gx FZF_DEFAULT_COMMAND "fd --strip-cwd-prefix --follow --exclude node_modules"
        set -gx FZF_DEFAULT_OPTS "--height 40% --layout=reverse --border"

        set FZF_CTRL_D_COMMAND "$FZF_DEFAULT_COMMAND --type d"
        set FZF_CTRL_F_COMMAND "$FZF_DEFAULT_COMMAND --type f"
        set -gx FZF_CTRL_T_OPTS "$FZF_DEFAULT_OPTS \
            --prompt 'All> ' \
            --bind \"ctrl-d:change-prompt(Directories> )+reload($FZF_CTRL_D_COMMAND)\" \
            --bind \"ctrl-f:change-prompt(Files> )+reload($FZF_CTRL_F_COMMAND)\" \
            --bind \"ctrl-a:change-prompt(All> )+reload($FZF_DEFAULT_COMMAND)\""
    end
end

function conda-init
    conda shell.fish hook | source
    if test (uname) = Darwin; and test (uname -m) = arm64
        conda env config vars set CONDA_SUBDIR=osx-arm64
    end
    if hasCommand fzf
        conda activate (conda env list | grep -vE '^\s*#' | grep -vE '^$' | fzf --bind "enter:become(echo {1})")
    end
end

function pyenv-init
    pyenv init - | source
    pyenv versions
    echo "exec `python -V`: $(python -V)"
end

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
        tmux attach; or tmux new
    else
        echo 'zellij/tmux command not found'
    end
end


if status is-interactive
    if hasCommand zellij; and set -q SSH_CONNECTION; and not set -q VSCODE_GIT_IPC_HANDLE; and not set -q NVIM
        set ZELLIJ_AUTO_ATTACH true
        # set ZELLIJ_AUTO_EXIT true
        eval (zellij setup --generate-auto-start fish | string collect)
    end

    set_fzf_option

    my_key_bindings

    set -gx EDITOR nvim
    if hasCommand code
        if not set -q SSH_CONNECTION; or set -q VSCODE_GIT_IPC_HANDLE
            set -gx EDITOR "code -w"
        end
    end
    set -gx XDG_CONFIG_HOME "$HOME/.config"

    alias ..="cd .."

    alias lzd=lazydocker
    alias lg=lazygit
    alias dc=docker-compose
    alias svc="sudo systemctl"
    alias vi="nvim"
    alias code-note='code --folder-uri "vscode-remote://ssh-remote+home.lubui.com/home/urie/workspace/ts/code-notes-vitepress/docs"'
    # alias code-home="code --remote ssh-remote+home.lubui.com ~"
    alias cz="chezmoi"

    # Commands to run in interactive sessions can go here
    # hasCommand pyenv; and pyenv init - | source
    hasCommand zoxide; and zoxide init fish | source

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
                cd (cat "$OUTPUT_FILE")
            end
        end
        alias sudor="sudo env JOSHUTO_CONFIG_HOME=$HOME/.config/joshuto joshuto"
    end

end