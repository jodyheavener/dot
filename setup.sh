#!/usr/bin/env bash

COLOR_GRAY="\033[1;38;5;243m"
COLOR_BLUE="\033[1;34m"
COLOR_GREEN="\033[1;32m"
COLOR_RED="\033[1;31m"
COLOR_PURPLE="\033[1;35m"
COLOR_YELLOW="\033[1;33m"
COLOR_NONE="\033[0m"

LINKABLES_DIR="$(pwd)/linkables"

title() {
	echo -e "\n${COLOR_PURPLE}$1${COLOR_NONE}"
	echo -e "${COLOR_GRAY}==============================${COLOR_NONE}\n"
}

info() {
	echo -e "${COLOR_BLUE}Info: ${COLOR_NONE}$1"
}

success() {
	echo -e "${COLOR_GREEN}$1${COLOR_NONE}"
}

create_parent_directories() {
	target_path=$1
	parent_dir=$(dirname "$target_path")
	mkdir -p "$parent_dir"
}

setup_homebrew() {
	title "Setting up Homebrew"

	if test ! "$(command -v brew)"; then
		info "Homebrew not installed. Installing."
		NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi

	brew bundle -v
}

setup_shell() {
	title "Configuring shell"

	[[ -n "$(command -v brew)" ]] && zsh_path="$(brew --prefix)/bin/zsh" || zsh_path="$(which zsh)"

	if ! grep "$zsh_path" /etc/shells; then
		info "adding $zsh_path to /etc/shells"
		echo "$zsh_path" | sudo tee -a /etc/shells
	fi

	if [[ "$SHELL" != "$zsh_path" ]]; then
		chsh -s "$zsh_path"
		info "default shell changed to $zsh_path"
	fi

	if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
		info "Oh My Zsh no installed. Installing."
		sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	fi
}

setup_symlinks() {
	title "Creating symlinks"

	for file in $(find "$LINKABLES_DIR" -type f); do
		filename=${file#$LINKABLES_DIR/}
		target="$HOME/$filename"

		if [ -e "$target" ]; then
			info "~${target#$HOME} already exists... skipping."
		else
			info "creating symlink for $filename"
			create_parent_directories "$target"
			ln -s "$file" "$target"
		fi
	done
}

setup_macos() {
	title "Configuring macOS"

	info "you may need to enter your password"

	zsh ./.osx

	info "macOS preferences updated. A restart is recommended."
}

case "$1" in
	brew)
		setup_homebrew
		;;
	shell)
		setup_shell
		;;
	link)
		setup_symlinks
		;;
	macos)
	    setup_macos
	    ;;
	all)
		setup_homebrew
		setup_symlinks
		setup_shell
		setup_macos
		;;
	*)
		echo -e $"\nUsage: $(basename "$0") [brew|shell|link|macos|all]\n"
		exit 1
		;;
esac

echo -e
success "Done."
