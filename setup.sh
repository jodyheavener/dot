#!/usr/bin/env bash

# Exit on any error
set -e

COLOR_GRAY="\033[1;38;5;243m"
COLOR_BLUE="\033[1;34m"
COLOR_GREEN="\033[1;32m"
COLOR_RED="\033[1;31m"
COLOR_PURPLE="\033[1;35m"
COLOR_YELLOW="\033[1;33m"
COLOR_NONE="\033[0m"

LINKABLES_DIR="$(pwd)/linkables"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

error() {
	echo -e "${COLOR_RED}Error: ${COLOR_NONE}$1" >&2
}

warning() {
	echo -e "${COLOR_YELLOW}Warning: ${COLOR_NONE}$1"
}

# Check if a command exists
command_exists() {
	command -v "$1" >/dev/null 2>&1
}

# Check for required dependencies
check_dependencies() {
	local missing_deps=()
	
	if ! command_exists curl; then
		missing_deps+=("curl")
	fi
	
	if ! command_exists sudo; then
		missing_deps+=("sudo")
	fi
	
	if [ ${#missing_deps[@]} -ne 0 ]; then
		error "Missing required dependencies: ${missing_deps[*]}"
		info "Please install the missing dependencies and try again."
		exit 1
	fi
}

# Check user permissions and provide guidance
check_user_permissions() {
	# Check if running as root
	if [[ $EUID -eq 0 ]]; then
		error "This script should not be run as root (sudo)."
		error "Please run as a regular user."
		exit 1
	fi
	
	# Check if user is in admin group
	if ! groups | grep -q admin; then
		warning "Current user is not in the admin group."
		echo
		info "Options for non-admin users:"
		echo
		info "1. Ask an administrator to add you to the admin group:"
		info "   sudo dseditgroup -o edit -a $(whoami) -t user admin"
		info "   Then log out and log back in."
		echo
		info "2. Use an administrator account to run this script"
		echo
		info "3. Skip Homebrew installation and install packages manually:"
		info "   - Install Homebrew manually: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
		info "   - Then run: ./setup.sh shell link macos"
		echo
		info "4. Continue anyway (some features may not work):"
		read -p "Do you want to continue? (y/N): " -n 1 -r
		echo
		if [[ ! $REPLY =~ ^[Yy]$ ]]; then
			info "Exiting. Please choose one of the options above."
			exit 1
		fi
		warning "Continuing without admin privileges. Homebrew installation may fail."
	fi
}

create_parent_directories() {
	target_path=$1
	parent_dir=$(dirname "$target_path")
	mkdir -p "$parent_dir"
}

setup_homebrew() {
	title "Setting up Homebrew"

	if ! command_exists brew; then
		info "Homebrew not installed. Installing."
		
		# Check if user has admin privileges
		if ! groups | grep -q admin; then
			warning "You don't have admin privileges. Homebrew installation may fail."
			info "If installation fails, you can:"
			info "  1. Ask an admin to add you to the admin group"
			info "  2. Install Homebrew manually later"
			info "  3. Skip this step and run other setup steps"
			echo
		fi
		
		info "Installing Homebrew (this may take a few minutes)..."
		info "You may be prompted for your password to grant administrator access."
		
		# Install Homebrew with proper error handling
		if ! NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
			error "Failed to install Homebrew"
			info "This is likely because you don't have administrator privileges."
			info "Solutions:"
			info "  1. Ask an administrator to add you to the admin group:"
			info "     sudo dseditgroup -o edit -a $(whoami) -t user admin"
			info "  2. Install Homebrew manually:"
			info "     /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
			info "  3. Skip Homebrew and continue with other setup steps"
			info "  4. Use an administrator account"
			echo
			read -p "Do you want to continue with other setup steps? (y/N): " -n 1 -r
			echo
			if [[ ! $REPLY =~ ^[Yy]$ ]]; then
				return 1
			fi
			warning "Skipping Homebrew setup. You can install it manually later."
			return 0
		fi
		
		# Add Homebrew to PATH for current session
		if [[ -f "/opt/homebrew/bin/brew" ]]; then
			export PATH="/opt/homebrew/bin:$PATH"
			info "Added /opt/homebrew/bin to PATH"
		elif [[ -f "/usr/local/bin/brew" ]]; then
			export PATH="/usr/local/bin:$PATH"
			info "Added /usr/local/bin to PATH"
		fi
		
		# Verify installation
		if ! command_exists brew; then
			error "Homebrew installation completed but brew command not found"
			info "Try restarting your terminal or running:"
			info "  echo 'eval \"\$(/opt/homebrew/bin/brew shellenv)\"' >> ~/.zprofile"
			info "  eval \"\$(/opt/homebrew/bin/brew shellenv)\""
			return 1
		fi
		
		success "Homebrew installed successfully"
	else
		info "Homebrew is already installed"
	fi

	# Only run brew bundle if Homebrew is available
	if command_exists brew; then
		info "Running brew bundle..."
		if ! brew bundle -v; then
			error "Failed to install packages from Brewfile"
			info "You can install packages manually later with: brew install <package>"
			return 1
		fi
		success "Homebrew setup completed successfully"
	else
		warning "Homebrew not available, skipping brew bundle"
		info "You can install packages manually later or install Homebrew first"
	fi
}

setup_shell() {
	title "Configuring shell"

	# Determine zsh path with better error handling
	if command_exists brew; then
		zsh_path="$(brew --prefix)/bin/zsh"
		if [[ ! -f "$zsh_path" ]]; then
			warning "Homebrew zsh not found at $zsh_path, falling back to system zsh"
			zsh_path="$(which zsh)"
		fi
	else
		zsh_path="$(which zsh)"
	fi

	if [[ ! -f "$zsh_path" ]]; then
		error "zsh not found. Please install zsh first."
		return 1
	fi

	info "Using zsh at: $zsh_path"

	# Add zsh to /etc/shells if not already present
	if ! grep -q "$zsh_path" /etc/shells; then
		info "Adding $zsh_path to /etc/shells"
		if ! echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null; then
			error "Failed to add $zsh_path to /etc/shells"
			return 1
		fi
	fi

	# Change default shell if needed
	if [[ "$SHELL" != "$zsh_path" ]]; then
		info "Changing default shell to $zsh_path"
		if ! chsh -s "$zsh_path"; then
			error "Failed to change default shell to $zsh_path"
			info "You may need to change it manually with: chsh -s $zsh_path"
			return 1
		fi
		info "Default shell changed to $zsh_path"
	else
		info "Default shell is already $zsh_path"
	fi

	# Install Oh My Zsh if not present
	if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
		info "Oh My Zsh not installed. Installing."
		# Backup existing .zshrc if it exists
		if [[ -f "$HOME/.zshrc" ]]; then
			info "Backing up existing .zshrc to .zshrc.backup"
			mv "$HOME/.zshrc" "$HOME/.zshrc.backup"
		fi
		
		if ! sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
			error "Failed to install Oh My Zsh"
			# Restore backup if installation failed
			if [[ -f "$HOME/.zshrc.backup" ]]; then
				mv "$HOME/.zshrc.backup" "$HOME/.zshrc"
			fi
			return 1
		fi
		
		# Restore backup if user had existing .zshrc
		if [[ -f "$HOME/.zshrc.backup" ]]; then
			info "Restoring your original .zshrc"
			mv "$HOME/.zshrc.backup" "$HOME/.zshrc"
		fi
	else
		info "Oh My Zsh is already installed"
	fi
	
	success "Shell setup completed successfully"
}

setup_symlinks() {
	title "Creating symlinks"

	if [ ! -d "$LINKABLES_DIR" ]; then
		error "Linkables directory not found at $LINKABLES_DIR"
		return 1
	fi

	local symlink_count=0
	local skip_count=0
	local error_count=0
	local replace_existing=false
	
	# Check if we should replace existing files without prompting
	# Look for --force in all arguments
	for arg in "$@"; do
		if [[ "$arg" == "--force" ]]; then
			replace_existing=true
			info "Force mode enabled - will replace existing files without prompting"
			break
		fi
	done
	
	# Debug: show what arguments were passed
	info "Arguments passed to setup_symlinks: $*"
	info "Replace existing files: $replace_existing"

	# Use find with proper error handling
	while IFS= read -r -d '' file; do
		filename=${file#$LINKABLES_DIR/}
		target="$HOME/$filename"

		# Check if source file exists and is readable
		if [[ ! -f "$file" ]]; then
			warning "Source file $file is not a regular file, skipping"
			continue
		fi

		if [[ ! -r "$file" ]]; then
			warning "Source file $file is not readable, skipping"
			continue
		fi

		if [ -e "$target" ]; then
			# Check if it's already a symlink
			if [ -L "$target" ]; then
				info "~${target#$HOME} is already a symlink... skipping."
				((skip_count++))
			else
				# It's a regular file/directory
				if [[ "$replace_existing" == true ]]; then
					info "~${target#$HOME} exists as regular file/directory. Replacing with symlink."
					info "Backing up original to ${target}.backup"
					mv "$target" "${target}.backup"
					info "Creating symlink for $filename"
					create_parent_directories "$target"
					
					if ln -s "$file" "$target"; then
						((symlink_count++))
					else
						error "Failed to create symlink for $filename"
						((error_count++))
					fi
				else
					warning "~${target#$HOME} already exists as a regular file/directory."
					info "This will be replaced with a symlink to your dotfiles."
					read -p "Replace it? (y/N): " -n 1 -r
					echo
					if [[ $REPLY =~ ^[Yy]$ ]]; then
						info "Backing up original to ${target}.backup"
						mv "$target" "${target}.backup"
						info "Creating symlink for $filename"
						create_parent_directories "$target"
						
						if ln -s "$file" "$target"; then
							((symlink_count++))
						else
							error "Failed to create symlink for $filename"
							((error_count++))
						fi
					else
						info "Skipping $filename"
						((skip_count++))
					fi
				fi
			fi
		else
			info "Creating symlink for $filename"
			create_parent_directories "$target"
			
			if ln -s "$file" "$target"; then
				((symlink_count++))
			else
				error "Failed to create symlink for $filename"
				((error_count++))
			fi
		fi
	done < <(find "$LINKABLES_DIR" -type f -print0 2>/dev/null)

	info "Symlink creation summary:"
	info "  Created: $symlink_count"
	info "  Skipped: $skip_count"
	info "  Errors: $error_count"

	if [ $error_count -gt 0 ]; then
		error "Some symlinks failed to create"
		return 1
	fi

	success "Symlink setup completed successfully"
}

setup_macos() {
	title "Configuring macOS"

	# Check if .macos file exists
	if [[ ! -f "$SCRIPT_DIR/.macos" ]]; then
		error ".macos file not found at $SCRIPT_DIR/.macos"
		info "Please ensure the .macos file exists in the script directory"
		return 1
	fi

	# Check if .macos file is executable
	if [[ ! -x "$SCRIPT_DIR/.macos" ]]; then
		info "Making .macos file executable"
		chmod +x "$SCRIPT_DIR/.macos"
	fi

	info "You may need to enter your password for macOS configuration"

	if ! zsh "$SCRIPT_DIR/.macos"; then
		error "macOS configuration failed"
		info "Some settings may not have been applied"
		return 1
	fi

	info "macOS preferences updated. A restart is recommended."
	success "macOS configuration completed successfully"
}

# Main execution
main() {
	# Check dependencies and permissions first
	check_dependencies
	check_user_permissions

	case "$1" in
		brew)
			setup_homebrew
			;;
		shell)
			setup_shell
			;;
		link)
			setup_symlinks "$@"
			;;
		macos)
			setup_macos
			;;
		all)
			info "Running complete setup..."
			setup_homebrew || { error "Homebrew setup failed"; exit 1; }
			setup_shell || { error "Shell setup failed"; exit 1; }
			setup_symlinks "$@" || { error "Symlink setup failed"; exit 1; }
			setup_macos || { error "macOS setup failed"; exit 1; }
			;;
		no-brew)
			info "Running setup without Homebrew (for non-admin users)..."
			setup_shell || { error "Shell setup failed"; exit 1; }
			setup_symlinks "$@" || { error "Symlink setup failed"; exit 1; }
			setup_macos || { error "macOS setup failed"; exit 1; }
			;;
		*)
			echo -e "\nUsage: $(basename "$0") [brew|shell|link|macos|all|no-brew] [--force]\n"
			echo "  brew     - Install Homebrew and packages from Brewfile"
			echo "  shell    - Configure zsh and install Oh My Zsh"
			echo "  link     - Create symlinks from linkables directory"
			echo "  macos    - Apply macOS system preferences"
			echo "  all      - Run all setup steps in correct order"
			echo "  no-brew  - Run setup without Homebrew (for non-admin users)"
			echo ""
			echo "Options:"
			echo "  --force  - Replace existing files without prompting (for link command)\n"
			exit 1
			;;
	esac

	echo
	success "Setup completed successfully!"
}

# Run main function
main "$@"
