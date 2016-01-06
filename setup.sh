#!/usr/bin/env zsh

cd "$(dirname "${BASH_SOURCE}")";

function user() {
  printf "\r\033[00;34m[ .. ] »\033[0m $1\n"
}

function info() {
  printf "\r\033[0;33m[ ?? ] »\033[0m $1\n"
}

function success() {
  printf "\r\033[00;32m[ !! ] »\033[0m $1\n"
}

function begin() {
  # Copy everything over to home directory
  user "Copying over dotfiles"
  rsync --exclude ".git/"     \
        --exclude "init/"     \
        --exclude ".DS_Store" \
        --exclude "setup.sh"  \
        --exclude "README.md" \
        -avh --no-perms . ~;

  # Reload ZSH
  # Do the same with .bash_profile if you want
  user "Reloading ZSH"
  source ~/.zshrc;

  user "Loading OSX preferences. You may need to enter your password."
  zsh ./.osx
  info "OSX preferences loaded. Note that some of these changes require a logout/restart to take effect."

  success "All done. Enjoy."
}

success "Welcome to Jody's dot setup!"

# Optionally force
if [ "$1" == "--force" -o "$1" == "-f" ]; then
  begin;
else
  info "These dotfiles may overwrite existing ones in your home directory."
  read -p "Are you absolutely sure you want to continue? (Yn)" -n 1;
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "";
    user "Sounds good. Let's go!"
    begin;
  fi;
fi;

unset begin;
