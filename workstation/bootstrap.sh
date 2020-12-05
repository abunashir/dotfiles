#!/bin/bash

# Welcome to the bootstrap script!
# Be prepared to turn your linux device
# into an awesome development machine.

set -e
if [ "${UPGRADE_PACKAGES}" != "none" ]; then
  echo "==> Updating and upgrading packages ..."

  # Add third party repositories
  sudo add-apt-repository -y ppa:martin-frost/thoughtbot-rcm
  sudo add-apt-repository ppa:jonathonf/vim -y

  sudo apt-get update
  sudo apt-get upgrade -y
fi

fancy_echo() {
  local fmt="$1"; shift

  # shellcheck disable=SC2059
  printf "\\n$fmt\\n" "$@"
}

append_to_zshrc() {
  if [ -w "$HOME/.zshrc.local" ]; then
    zshrc="$HOME/.zshrc.local"
  else
    zshrc="$HOME/.zshrc"
  fi

  grep -q -F "$1" "$zshrc" || echo "$1" >> "$zshrc"
}

gem_install_or_update() {
  if gem list "$1" --installed > /dev/null; then
    gem update "$@"
  else
    gem install "$@"
  fi
}


[ ! -e "$HOME/.bin" ] && mkdir "$HOME/.bin"
[ ! -f "$HOME/.zshrc" ] && touch "$HOME/.zshrc"

append_to_zshrc 'export PATH="$HOME/.bin:$PATH"'

fancy_echo  "Installing basic packages"
sudo apt-get install -qq -y \
  build-essential \
  ca-certificates \
  clang \
  cmake \
  curl \
  ctags \
  direnv \
  docker.io \
  git \
  htop \
  libssl-dev \
  libreadline-dev \
  libpq-dev \
  libsqlite3-dev \
  locales \
  openssl \
  python \
  tmux \
  tree \
  vim \
  zsh \
  zlib1g-dev \
  wget \
  silversearcher-ag rcm \
  --fix-missing \
  --no-install-recommends \

rm -rf /var/lib/apt/lists/*

# change shell
chsh -s "$(which zsh)"

fancy_echo  "Configuring asdf version manager ..."
if [ ! -d "$HOME/.asdf" ]; then
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.0
  append_to_zshrc "source $HOME/.asdf/asdf.sh"
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

source "$HOME/.asdf/asdf.sh"

fancy_echo "Adding ASDF pluglins"
add_or_update_asdf_plugin "golang" "https://github.com/kennyp/asdf-golang.git"
add_or_update_asdf_plugin "java" "https://github.com/halcyon/asdf-java.git"
add_or_update_asdf_plugin "nodejs" "https://github.com/asdf-vm/asdf-nodejs.git"
add_or_update_asdf_plugin "python" "https://github.com/danhper/asdf-python.git"
add_or_update_asdf_plugin "ruby" "https://github.com/asdf-vm/asdf-ruby.git"


install_asdf_language() {
  local language="$1"
  local version
  version="$(asdf list-all "$language" | grep -v "[a-z]" | tail -1)"

  if ! asdf list "$language" | grep -Fq "$version"; then
    asdf install "$language" "$version"
    asdf global "$language" "$version"
  fi
}

fancy_echo "Installing latest Go ..."
install_asdf_language "golang"

fancy_echo "Installing latest Nodejs ..."
bash "$HOME/.asdf/plugins/nodejs/bin/import-release-team-keyring"
install_asdf_language "nodejs"

fancy_echo "Installing latest Ruby ..."
install_asdf_language "ruby"
gem update --system

echo "Copying over dotfiles"
git clone https://github.com/thoughtbot/dotfiles
git clone https://github.com/abunashir/dotfiles local-dotfiles

fancy_echo "Install dotfiles"
# cp ~/.zshrc ~/.zshrc.local
# cd ~/dotfiles && env RCRC=$HOME/dotfiles/rcrc rcup
# cd ~/local-dotfiles && cp .**.local  ~/

fancy_echo "Cleanup"
sudo apt-get autoremove -y

fancy_echo "==> Done!"
