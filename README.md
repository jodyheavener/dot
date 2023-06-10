# Jody's macOS Setup

If you're not Jody, make sure you look through everything and tailor it to your needs first.

🫡 A bunch of this pulled from [nicknisi/dotfiles](https://github.com/nicknisi/dotfiles)

## Usage

Running `./setup.sh all` to do a full setup. You can also run the individual parts:

- `./setup.sh brew` to set up Homebrew and everything in `./Brewfile`
- `./setup.sh link` to symlink all the contents of `./linkables` to the user `HOME` path
- `./setup.sh shell` to set up ZSH as the default shell, and install Oh My Zsh
- `./setup.sh macos` to apply the OSX configs found in `./.osx`

## Personas

By default this repo is set up to act as me in an individual capacity (personal email, signing keys). When you want to use this for another persona, such as in a work capacity, branch off `main` and update the following files:

`./linkables/.gitconfig`

- `user.email` to the right email
- `user.signingkey` to the public key for an SSH Key item accessible in 1Password

`./linkables/.config/1Password/ssh/agent.toml`

- `item` to the name of the SSH Key item accessible in 1Password
