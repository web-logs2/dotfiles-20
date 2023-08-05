#!/usr/bin/env bash

source "$BASH_UTIL_PATH"

! confirm "Confirm to brew install" && exit 0

echo "brew install start"

brew bundle --no-lock --file=/dev/stdin <<EOF
tap "homebrew/bundle"
tap "homebrew/services"
tap "homebrew/cask-fonts"
tap "dteoh/sqa"
tap "daipeihust/tap"

brew "git"
brew "git-delta"
brew "bat"
brew "chezmoi"
brew "fd"
brew "fish"
brew "fzf"
brew "iperf3"
brew "lazygit"
brew "neovim"
brew "python"
brew "pipx"
brew "pyenv"
brew "pipenv"
brew "zellij"
brew "cmake"
brew "go"
brew "ripgrep"
brew "gum"
brew "zoxide"
brew "lego"
brew "dsq"
brew "koekeishiya/formulae/yabai"
brew "koekeishiya/formulae/skhd"
brew "pngpaste"
brew "ffmpeg"
brew "gh"
brew "im-select"
brew "m-cli"
brew "scrcpy"
brew "node"
brew "glow"

cask "font-fira-mono-nerd-font"
cask "alacritty"
cask "google-chrome"
cask "android-platform-tools"
cask "telegram"
cask "raycast"
cask "wechat"
cask "neteasemusic"
cask "visual-studio-code"
cask "rar"
cask "jellyfin-media-player"

EOF

# for fish shell
# echo \n"$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 (which yabai)) --load-sa"|sudo tee -a /private/etc/sudoers.d/yabai

# for bash shell
# if sudo cat /private/etc/sudoers.d/yabai | grep yabai; then
#     echo add yabai to sudo...
#     echo \n"$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 $(which yabai)) --load-sa" | sudo tee -a /private/etc/sudoers.d/yabai
# fi

echo "brew install end"