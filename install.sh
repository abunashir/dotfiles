#!/bin/bash

# Dotfiles install script for GitHub Codespaces (and any Debian/Ubuntu machine).
# Installs zsh, tmux, vim and sets up thoughtbot/dotfiles + personal .local overrides.

set -e

THOUGHTBOT_DIR="$HOME/thoughtbot-dotfiles"
PERSONAL_DIR="$HOME/dotfiles"

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
# Personal dotfiles
# ---------------------------------------------------------------------------

if [ ! -d "$PERSONAL_DIR" ]; then
  fancy_echo "Cloning personal dotfiles..."
  git clone https://github.com/abunashir/dotfiles.git "$PERSONAL_DIR"
fi

# ---------------------------------------------------------------------------
# thoughtbot/dotfiles
# ---------------------------------------------------------------------------

if [ ! -d "$THOUGHTBOT_DIR" ]; then
  fancy_echo "Cloning thoughtbot/dotfiles..."
  git clone https://github.com/thoughtbot/dotfiles "$THOUGHTBOT_DIR"
fi

fancy_echo "Patching thoughtbot dotfiles for Linux..."
sed -i 's|eval "\$(/opt/homebrew/bin/brew shellenv)"|[ -x /opt/homebrew/bin/brew ] \&\& eval "$(/opt/homebrew/bin/brew shellenv)"|' "$THOUGHTBOT_DIR/zshrc"

fancy_echo "Running rcup..."
env RCRC="$THOUGHTBOT_DIR/rcrc" rcup -d "$THOUGHTBOT_DIR" -d "$PERSONAL_DIR" -f

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

fancy_echo "Installing Claude Code..."
curl -fsSL https://claude.ai/install.sh | bash

fancy_echo "Setting up Claude global skills..."
mkdir -p "$HOME/.claude"
ln -sf "$PERSONAL_DIR/claude/commands" "$HOME/.claude/commands"

# ---------------------------------------------------------------------------
# Default shell
# ---------------------------------------------------------------------------

if [ "$SHELL" != "$(which zsh)" ]; then
  fancy_echo "Setting zsh as default shell..."
  sudo chsh -s "$(which zsh)" "$USER"
fi

echo "set-option -g default-shell $(which zsh)" >> "$HOME/.tmux.conf.local"

fancy_echo "Done!"
