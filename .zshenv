_setup_user_zshenv() {
    # sanity check
    if [ $(id -u) -eq 0 ]; then
        echo "assertion failed: user should not be root" >> /dev/stderr
        exit;
    fi

    [[ $(uname) == "Linux" ]] && _setup_linux_user_zshenv
    [[ $(uname) == "Darwin" ]] && _setup_darwin_common_zshenv && _setup_darwin_user_zshenv
}

_setup_root_zshenv() {
    export ZDOTDIR=$HOME/.config/zsh
    export ZSH_CACHE_DIR=$HOME/.cache/zsh
    export ZSH_STATE_DIR=$HOME/.var/zsh

    [[ $(uname) == "Darwin" ]] && _setup_darwin_common_zshenv
}

_setup_darwin_common_zshenv() {
    local newpaths="$HOME/.local/bin:/usr/local/bin"
    if [[ "$(hostname)" == "work-macbook.local" ]]; then
        [ -d $HOME/.local/opt/flutter ] && newpaths="$newpaths:$HOME/.local/opt/flutter/bin"
        [ -d $HOME/.local/opt/google-cloud-sdk ] && newpaths="$newpaths:$HOME/.local/opt/flutter/bin"
    fi
    [ -d /opt/homebrew/opt/openjdk ] && newpaths="$newpaths:/opt/homebrew/opt/openjdk/bin"
    [ -d $HOME/.pyenv/shims ] && newpaths="$newpaths:$HOME/.pyenv/shims"
    [ -d /opt/homebrew ] && newpaths="$newpaths:/opt/homebrew/bin:/opt/homebrew/sbin"
    export PATH="$newpaths:$PATH"
}

_setup_darwin_user_zshenv() {
    export ZDOTDIR=$HOME/.config/zsh
    export ZSH_CACHE_DIR=$HOME/.cache/zsh
    export ZSH_STATE_DIR=$HOME/.var/zsh
}

_setup_linux_user_zshenv() {
    ### XDG Setup
    # Load XDG config paths
    if [ -f $HOME/.config/user-dirs.dirs ]; then
        set -o allexport
        source $HOME/.config/user-dirs.dirs
        set +o allexport
    fi
    
    # Set default values for any required XDG path variables
    [[ -v XDG_CONFIG_HOME ]] || export XDG_CONFIG_HOME=$HOME/.config
    # XDG_STATE_HOME is not yet supported by xdg-user-dir
    [[ -v XDG_STATE_HOME ]] || export XDG_STATE_HOME=$HOME/.var
    # set other missing XDG variables
    [[ -v XDG_DATA_HOME ]] || export XDG_DATA_HOME=$HOME/.local/share
    [[ -v XDG_CACHE_HOME ]] || export XDG_CACHE_HOME=$HOME/.local/cache
    # not an xdg path, but similar and needed
    [[ -v LOCAL_SOURCES_HOME ]] || export LOCAL_SOURCES_HOME=$HOME/.local/src
    
    # create any missing XDG dir dependencies
    mkdir -p $XDG_CONFIG_HOME
    mkdir -p $XDG_STATE_HOME
    mkdir -p $XDG_DATA_HOME
    mkdir -p $XDG_CACHE_HOME
    mkdir -p $LOCAL_SOURCES_HOME
    
    ### ~/.config/zsh should be default resting place for zsh files
    export ZDOTDIR=$XDG_CONFIG_HOME/zsh
    export ZSH_CACHE_DIR=$XDG_CACHE_HOME/zsh
    export ZSH_STATE_DIR=$XDG_STATE_HOME/zsh
    
    ### other env vars to move crap out of $HOME
    export LESSHISTFILE=$XDG_STATE_HOME/less/history
    export PYTHON_HISTORY=$XDG_STATE_HOME/python/history
    export PYTHONPYCACHEPREFIX=$XDG_CACHE_HOME/python
    export PYTHONUSERBASE=$XDG_DATA_HOME/python
    alias svn="svn --config-dir \"$XDG_CONFIG_HOME\"/subversion"
    export ICEAUTHORITY=$XDG_CACHE_HOME/ICEauthority
}

[ $(id -u) -eq 0 ] && _setup_root_zshenv || _setup_user_zshenv

mkdir -p $ZDOTDIR
mkdir -p $ZSH_CACHE_DIR
mkdir -p $ZSH_STATE_DIR
