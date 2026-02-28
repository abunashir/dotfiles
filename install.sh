#!/bin/bash

# Dotfiles install script for GitHub Codespaces (and any Debian/Ubuntu machine).
# Installs zsh, tmux, vim and sets up thoughtbot/dotfiles + personal .local overrides.

set -e

DOTFILES_DIR="$HOME/dotfiles"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

fancy_echo() {
  printf "\n==> %s\n" "$1"
}

# ---------------------------------------------------------------------------
# Packages
# ---------------------------------------------------------------------------

fancy_echo "Installing zsh, tmux, vim, and rcm..."
sudo rm -f /etc/apt/sources.list.d/yarn.list
sudo apt-get update -qq
sudo apt-get install -qq -y zsh tmux vim curl git rcm

# ---------------------------------------------------------------------------
# thoughtbot/dotfiles
# ---------------------------------------------------------------------------

if [ ! -d "$DOTFILES_DIR" ]; then
  fancy_echo "Cloning thoughtbot/dotfiles..."
  git clone https://github.com/thoughtbot/dotfiles "$DOTFILES_DIR"
fi

fancy_echo "Patching thoughtbot dotfiles for Linux..."
sed -i 's|eval "\$(/opt/homebrew/bin/brew shellenv)"|[ -x /opt/homebrew/bin/brew ] \&\& eval "$(/opt/homebrew/bin/brew shellenv)"|' "$DOTFILES_DIR/zshrc"

fancy_echo "Running rcup..."
env RCRC="$DOTFILES_DIR/rcrc" rcup -d "$DOTFILES_DIR" -f

# ---------------------------------------------------------------------------
# Personal .local overrides
# ---------------------------------------------------------------------------

fancy_echo "Copying personal dotfiles..."
cp "$SCRIPT_DIR"/.*.local "$HOME/"

# ---------------------------------------------------------------------------
# vim-plug + plugins
# ---------------------------------------------------------------------------

if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
  fancy_echo "Installing vim-plug..."
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

fancy_echo "Installing vim plugins..."
vim -es -u "$HOME/.vimrc" -i NONE +PlugInstall +qall || true

# ---------------------------------------------------------------------------
# Claude Code
# ---------------------------------------------------------------------------

if command -v npm &>/dev/null; then
  fancy_echo "Installing Claude Code..."
  npm install -g @anthropic-ai/claude-code --silent
fi

# ---------------------------------------------------------------------------
# Default shell
# ---------------------------------------------------------------------------

if [ "$SHELL" != "$(which zsh)" ]; then
  fancy_echo "Setting zsh as default shell..."
  sudo chsh -s "$(which zsh)" "$USER"
fi

fancy_echo "Done!"
