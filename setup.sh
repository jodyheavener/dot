#!/bin/zsh

# Print various messages
function info() {
  printf "\r\033[00;34m[ .. ] »\033[0m $1\n"
}

function notice() {
  printf "\r\033[0;33m[ ?? ] »\033[0m $1\n"
}

function success() {
  printf "\r\033[00;32m[ !! ] »\033[0m $1\n"
}

# Main setup function
function setup() {
  # Set up ohmyzsh
  info "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  # FIXME: Exits after this?

  # Install Xcode for its dev tools if it's not installed
  if ! xcode-select -p > /dev/null; then
    info "Installing Xcode..."
    xcode-select --install
    read -n 1 -s -r -p "Press any key to continue when Xcode install is completed."
  fi

  # Install Homebrew if it's not installed
  if [ ! -f "/usr/local/bin/brew" ]; then
    info "Installing Brew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi

  # Install a pre-generated set of brew packages
  # Want to update this? Run `brew list > brew-list`
  # FIXME: fine-tune this list
  # cat brew-list | xargs brew install
  # info "Brew packages have been installed."

  # Symlink/copy all the things
  info "Symlinking and copying dotfiles."
  symlinkable_entries=(.aliases .exports .functions .gitconfig .gitignore .zshrc .git_commit_template)
  copiable_entries=()

  for entry in .[^.]*; do
    if [[ "${symlinkable_entries[*]}" =~ (^|[[:space:]])"${entry}"($|[[:space:]]) ]]; then
      rm -r -f "$HOME/$entry"
      ln -s "`pwd`/$entry" "$HOME/$entry"
    fi

    if [[ "${copiable_entries[*]}" =~ (^|[[:space:]])"${entry}"($|[[:space:]]) ]]; then
      rm -r -f "$HOME/$entry"
      cp -r "`pwd`/$entry" "$HOME/$entry"
    fi
  done

  # Now let's install nvm and the default global version
  # We're going with version v16.12.0 for now, but this could be updated at a later time
  info "Setting up nvm."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
  # FIXME: nvm not available after this?
  nvm install v16.12.0 && nvm alias default v16.12.0;

  info "Loading macOS preferences. You may need to enter your password."
  # FIXME: fine tune this
  zsh ./.osx
  info "macOS preferences updated. A restart is recommended."

  info "Reloading ZSH..."
  exec zsh;

  success "All done!"
  info "You may also want to set up SSH keys (+ Git signing key), install Yarn packages (yarn-list), and install some apps (apps-list)."
}

# macOS Only
[[ "$OSTYPE" =~ ^darwin ]] || return 1;

# Let's get going!
success "Welcome to Jody's macOS setup."
notice "This script will symlink dotfiles, prepare default configurations, modify OS behaviour, and install a handful of other handy tools."
notice "Important: the symlinking process will overwrite any existing dotfiles of the same name, and the OS configuration can change how your system runs."
notice "Important: dotfiles are symlinked from this repo, so this repo needs to remain in place for continued usage."

# FIXME: this doesn't work
read -p "Are you absolutely sure you want to continue? (Yn)" -n 1;

if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "";
  info "Sounds good. Let's go!"
  setup;
fi;

unset setup;
