has_command() {
  command -v "$1" >/dev/null 2>&1
}

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
  if [ -n $ZELLIJ ]; then
    echo "already in zellij session"
    return 1
  elif [ -n $TMUX ]; then
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
    if [ -n $SSH_CONNECTION ] || [ -n $VSCODE_GIT_IPC_HANDLE ]; then
      export EDITOR="code -w"
    fi
  fi
  env | grep EDITOR
}

if has_command joshuto; then
  r() {
    ID="$$"
    mkdir -p /tmp/$USER
    OUTPUT_FILE="/tmp/$USER/joshuto-cwd-$ID"
    env joshuto --output-file "$OUTPUT_FILE" $@
    exit_code=$?

    case "$exit_code" in
    # regular exit
    0) ;;
    # output contains current directory
    101)
      JOSHUTO_CWD=$(cat "$OUTPUT_FILE")
      cd "$JOSHUTO_CWD"
      ;;
    # output selected files
    102) ;;
    *)
      echo "Exit code: $exit_code"
      ;;
    esac
  }
fi