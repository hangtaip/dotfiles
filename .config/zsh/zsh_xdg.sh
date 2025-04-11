# export ZDOTDIR=~/.config/zsh; [ -f /.zshenv ] && . /.zshenv

# Assign xdg only if they don't have value yet.
: ${XDG_LOCAL_HOME:=$HOME/.local}
: ${XDG_STATE_HOME:=$HOME/.local/state}
: ${XDG_DATA_HOME=$HOME/.local/share}
: ${XDG_CACHE_HOME:=$HOME/.cache}
: ${XDG_CONFIG_HOME:=$HOME/.config}

export XDG_LOCAL_HOME
export XDG_STATE_HOME
export XDG_DATA_HOME
export XDG_CACHE_HOME
export XDG_CONFIG_HOME

# export ZDOTDIR=${${(%):-%x}:P:h}
# export ZDOTDIR=$XDG_CONFIG_HOME/zsh
