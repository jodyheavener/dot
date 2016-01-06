# Path to your oh-my-zsh installation.
export ZSH=/Users/jodyheavener/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
ZSH_THEME="robbyrussell"

# Enable command auto-correction.
ENABLE_CORRECTION="true"

# Display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load?
# Look in ~/.oh-my-zsh/plugins/
plugins=(git)

# User configuration

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export SSH_KEY_PATH="~/.ssh/dsa_id"

source $ZSH/oh-my-zsh.sh

eval "$(rbenv init -)"

MYSQL=/usr/local/mysql/bin
export PATH=$PATH:$MYSQL
export DYLD_LIBRARY_PATH=/usr/local/mysql/lib:$DYLD_LIBRARY_PATH

# Stop annoying corrections
unsetopt correct
unsetopt correct_all

# Keeping these aliases here
alias zshconfig="subl ~/.zshrc"
alias zshenv="subl ~/.zshenv"
