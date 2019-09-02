#!/bin/zsh

user() {
  printf "\r\033[00;34m[ .. ] »\033[0m $1\n"
}

info() {
  printf "\r\033[0;33m[ ?? ] »\033[0m $1\n"
}

success() {
  printf "\r\033[00;32m[ !! ] »\033[0m $1\n"
}

contains() {
  local n=$#
  local value=${!n}
  for ((i=1;i < $#;i++)) {
    if [ "${!i}" == "${value}" ]; then
      echo true
      return 0
    fi
  }
  echo false
  return 1
}

link() {
  rm -f "$2"
  ln -s "$1" "$2"
}

begin() {
  exclusions=(".DS_Store" "README.md", "setup.sh", ".git", "brew-list")

  # Symlink all the things
  user "Symlinking dotfiles."
  for file in .[^.]*; do
    if [ $(contains "${exclusions[@]}" "$file") == false ]; then
      link "`pwd`/$file" "$HOME/$file"
    fi
  done
  info "Dotfiles symlinked."

  # Do the OSX thing
  user "Loading OSX preferences. You will need to enter your password."
  zsh ./.osx
  info "OSX preferences loaded. Note that some of these changes require a logout/restart to take effect."

  success "Everything worked!"

  # Reload ZSH
  user "Going to reload ZSH now..."
  exec zsh;
}

success "Welcome to Jody's Dot Files!"

# Optionally force
if [ "$1" == "--force" -o "$1" == "-f" ]; then
  begin;
else
  info "This script will symlink everything from this directory to your home directory."
  info "These dotfiles may overwrite existing ones in your home directory."
  read -p "Are you absolutely sure you want to continue? (Yn)" -n 1;
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "";
    user "Sounds good. Let's go!"
    begin;
  fi;
fi;

unset begin;
