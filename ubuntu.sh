#!/bin/bash

# This is my script for setting up ubuntu machines in
# a similar setup to how thoughtbot's laptop script
# works (https://github.com/thoughtbot/laptop)

append_to_zshrc() {
  if [ -w "$HOME/.zshrc.local" ]; then
    zshrc="$HOME/.zshrc.local"
  else
    zshrc="$HOME/.zshrc"
  fi

  grep -q -F "$1" "$zshrc" || echo "$1" >> "$zshrc"
}

set -e

[ ! -e "$HOME/.bin" ] && mkdir "$HOME/.bin"
[ ! -f "$HOME/.zshrc" ] && touch "$HOME/.zshrc"

append_to_zshrc 'export PATH="$HOME/.bin:$PATH"'

# add all ppa's first
sudo add-apt-repository -y ppa:jonathonf/vim
sudo add-apt-repository -y ppa:martin-frost/thoughtbot-rcm

# basics
sudo apt-get install -y ctags git libssl-dev libreadline-dev openssl \
  tmux vim zsh wget silversearcher-ag rcm build-essential sqlite3 snapd

chsh -s "$(which zsh)"

# image manip
sudo apt-get install -y imagemagick libmagickwand-dev --fix-missing

# capybara-webkit dependencies
sudo apt-get install -y qt5-default libqt5webkit5-dev \
  gstreamer1.0-plugins-base gstreamer1.0-tools gstreamer1.0-x

# databases
sudo apt-get install -y redis-server
sudo apt-get install -y postgresql postgresql-contrib libpq-dev

# Install asdf as package manager
if [ ! -d "$HOME/.asdf" ]; then
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.5
  append_to_zshrc "source $HOME/.asdf/asdf.sh" 1
fi

alias install_asdf_plugin=add_or_update_asdf_plugin
add_or_update_asdf_plugin() {
  local name="$1"
  local url="$2"

  if ! asdf plugin-list | grep -Fq "$name"; then
    asdf plugin-add "$name" "$url"
  else
    asdf plugin-update "$name"
  fi
}

# shellcheck disable=SC1090
source "$HOME/.asdf/asdf.sh"
add_or_update_asdf_plugin "ruby" "https://github.com/asdf-vm/asdf-ruby.git"
add_or_update_asdf_plugin "nodejs" "https://github.com/asdf-vm/asdf-nodejs.git"
add_or_update_asdf_plugin "python" "https://github.com/danhper/asdf-python.git"
add_or_update_asdf_plugin "golang" "https://github.com/kennyp/asdf-golang.git"

install_asdf_language() {
  local language="$1"
  local version
  version="$(asdf list-all "$language" | grep -v "[a-z]" | tail -1)"

  if ! asdf list "$language" | grep -Fq "$version"; then
    asdf install "$language" "$version"
    asdf global "$language" "$version"
  fi
}

# install latest ruby
install_asdf_language "ruby"
gem update --system

# install latest nodejs
bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
install_asdf_language "nodejs"

# install latest python
install_asdf_language "python"

# install latest golang
install_asdf_language "golang"

# setup dotfiles
cp .**.local  ~/

if [ ! -d "$HOME/dotfiles" ]; then
  cp ~/.zshrc ~/.zshrc.local
  git clone https://github.com/thoughtbot/dotfiles ~/dotfiles
fi

cd ~/dotfiles && env RCRC=$HOME/dotfiles/rcrc rcup

# cleanup dependencies
sudo apt-get autoremove -y
