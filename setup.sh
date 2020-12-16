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

# Value in array
function contains() {
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

# Main setup function
function setup() {
  # Set up ohmyzsh
  info "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

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
  cat brew-list | xargs brew install
  info "Brew packages have been installed."

  # Symlink/copy all the things
  info "Symlinking and copying dotfiles."
  symlinkable_entries=(.iterm2 .aliases .exports .functions .gitconfig .gitignore .zshrc)
  copiable_entries=(.aws)

  for entry in .[^.]*; do
    if [ $(contains "${symlinkable_entries[@]}" "$entry") == true ]; then
      rm -r -f "$HOME/$entry"
      ln -s "`pwd`/$entry" "$HOME/$entry"
    fi

    if [ $(contains "${copiable_entries[@]}" "$entry") == true ]; then
      rm -r -f "$HOME/$entry"
      cp -r "`pwd`/$entry" "$HOME/$entry"
    fi

    if [ $entry == '.aws' ]; then
      info "After this is finished please set up your AWS config file at $HOME/$entry/credentials"
    fi
  done

  # We installed rbenv in the previous Brew step, so let's set the default global version
  # We're going with version v2.6.5 for now, but this could be updated at a later time
  # DISABLED because I don't really use Ruby these days
  #
  # info "Setting up rbenv."
  # rbenv install 2.6.5 && rbenv global 2.6.5;

  # Now let's install nvm and the default global version
  # We're going with version v14.15.1 for now, but this could be updated at a later time
  info "Setting up nvm."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash;
  nvm install v14.15.1 && nvm alias default v14.15.1;

  info "Loading macOS preferences. You may need to enter your password."
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

read -p "Are you absolutely sure you want to continue? (Yn)" -n 1;

if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "";
  info "Sounds good. Let's go!"
  setup;
fi;

unset setup;
