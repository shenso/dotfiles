_setup_user_zshenv() {
    # sanity check
    if [ $(id -u) -eq 0 ]; then
        exit;
    fi

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
    [[ $(uname) == "Linux" ]] && export ICEAUTHORITY=$XDG_CACHE_HOME/ICEauthority
    alias svn="svn --config-dir \"$XDG_CONFIG_HOME\"/subversion"
}

_setup_root_zshenv() {
    export ZDOTDIR=$HOME/.config/zsh
    export ZSH_CACHE_DIR=$HOME/.cache/zsh
    export ZSH_STATE_DIR=$HOME/.var/zsh
}

[ $(id -u) -eq 0 ] && _setup_root_zshenv || _setup_user_zshenv

mkdir -p $ZDOTDIR
mkdir -p $ZSH_CACHE_DIR
mkdir -p $ZSH_STATE_DIR
