function has_command
    command -v $argv[1] >/dev/null 2>&1
end

for dir in "$HOME/go/bin" \
    /opt/homebrew/bin \
    /opt/homebrew/sbin \
    "$HOME/bin" \
    "$HOME/bin/darwin" \
    "$HOME/.cargo/bin" \
    "$HOME/.local/bin" \
    "$HOME/.pyenv/bin" \
    "$HOME/.local/share/pnpm" \
    "$HOME/.local/share/nvim/mason/bin"
    if test -e "$dir"
        set -gx PATH "$dir" "$PATH"
    end
end

set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx EDITOR nvim
set -gx PNPM_HOME "$HOME/.local/share/pnpm"

function my_key_bindings
    fish_vi_key_bindings
    fzf_key_bindings
    bind -M insert \cA beginning-of-line
    bind -M insert \cE end-of-line
end

function set_fzf_option
    if has_command fd
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
    if test (uname) = Darwin
        and test (uname -m) = arm64
        conda env config vars set CONDA_SUBDIR=osx-arm64
    end
    if has_command fzf
        conda activate (conda env list | grep -vE '^\s*#' | grep -vE '^$' | fzf --bind "enter:become(echo {1})")
    end
end

function pyenv-init
    pyenv init - | source
    pyenv versions
    echo -n "exec `python -V`: "
    python -V
end

function tm
    if set -q ZELLIJ
        echo "already in zellij session"
        return 1
    else if set -q TMUX
        echo "already in tmux session"
        return 1
    else if has_command zellij
        zellij attach -c
    else if has_command tmux
        tmux attach or tmux new
    else
        echo 'zellij/tmux command not found'
    end
end

function editor-detect
    if has_command code
        if not set -q SSH_CONNECTION
            or set -q VSCODE_GIT_IPC_HANDLE
            set -gx EDITOR "code -w"
        end
    end
    env | grep EDITOR
end

if status is-interactive
    if has_command zellij
        and set -q SSH_CONNECTION
        and not set -q VSCODE_GIT_IPC_HANDLE
        and not set -q NVIM
        set ZELLIJ_AUTO_ATTACH true
        # set ZELLIJ_AUTO_EXIT true
        eval (zellij setup --generate-auto-start fish | string collect)
    end

    set_fzf_option

    my_key_bindings

    alias ..="cd .."
    alias lzd=lazydocker
    alias lg=lazygit
    alias dc=docker-compose
    alias svc="sudo systemctl"
    alias vi="nvim"
    alias cz="chezmoi"

    has_command zoxide
    and zoxide init fish | source

    if has_command joshuto
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