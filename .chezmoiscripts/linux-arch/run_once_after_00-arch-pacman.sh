#!/usr/bin/env bash

source "$BASH_UTIL_PATH"

! confirm "Confirm to pacman install" && exit 0

echo "pacman package install start"

sudo pacman -Syyu
sudo pacman --needed -Sy \
  bat \
  android-tools \
  bottom \
  chezmoi \
  docker \
  docker-compose \
  fish \
  fzf \
  git \
  base-devel \
  git-delta \
  go \
  iperf3 \
  jq \
  lazygit \
  lsof \
  neovim \
  nmap \
  nodejs \
  npm \
  openbsd-netcat \
  openssh \
  p7zip \
  samba \
  zellij \
  python \
  translate-shell \
  tree \
  otf-firamono-nerd \
  unzip \
  wget \
  ripgrep \
  openssl \
  gum \
  lego \
  unrar \
  dsq \
  rsync \
  github-cli \
  glow \
  perl-image-exiftool \
  zoxide

if ! has_command yay; then
  mkdir -p ~/install && cd ~/install || exit 1
  git clone https://aur.archlinux.org/yay.git
  cd yay || exit 1
  makepkg -si
  yay -Y --gendb
  yay
fi

if has_command yay; then
  yay -S --answerclean None --answerdiff None --needed \
    joshuto-git \
    lazydocker
fi

echo "pacman package install end"