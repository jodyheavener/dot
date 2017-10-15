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
plugins=(git osx node npm brew colorize dirpersist gem)

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

# Source relevent dotfiles
for file in ~/.{aliases,exports,functions}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# Load up a ruby version
rb230
export PATH="/usr/local/opt/elasticsearch@2.4/bin:$PATH"
export PKG_CONFIG_PATH="/opt/local/lib/pkgconfig:$PKG_CONFIG_PATH"
export PATH="/usr/local/opt/mysql@5.6/bin:$PATH"
