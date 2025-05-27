_setup_zsh_theme() {
    local preferred_theme='shenso'
    local fallback_theme='walters'
    
    if [ -d $ZDOTDIR/themes/$preferred_theme ]; then
        local theme_dir=$ZDOTDIR/themes/$preferred_theme
    elif [ -d /etc/zsh/themes/$preferred_theme ]; then
        local theme_dir=/etc/zsh/themes/$preferred_theme
    fi
    
    if [ -v theme_dir ]; then
        fpath+=($theme_dir)
        local target_theme=$preferred_theme
    else
        local target_theme=$fallback_theme
    fi
    
    autoload -U promptinit \
        && promptinit \
        && prompt $target_theme
}



_setup_zsh_history() {
    setopt histignorealldups share_history
    # Use XDG_STATE_HOME for history file
    export HISTFILE=$ZSH_STATE_DIR/history
    export HISTSIZE=1000
    export SAVEHIST=1000
}



_setup_zsh_completions() {
    # enable compsys and dump in cache
    autoload -Uz compinit && \
        compinit -d "$ZSH_CACHE_DIR"/zcompdump-$ZSH_VERSION
    
    _comp_options+=(globdots)
    
    # cache away from home 
    zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR"/zcompcache
    # completion settings
    zstyle ':completion:*' completer _expand _complete
    zstyle ':completion:*' menu select=2
    zstyle ':completion:*' history-words
    zstyle ':completion:*' verbose true
}



_setup_zsh_bindings() {
    if [[ $(uname) == "Darwin" ]]; then
        local upkey="\e[A"
        local downkey="\e[B"
    else
        local upkey="$terminfo[kcuu1]"
        local downkey="$terminfo[kcud1]"
    fi

    bindkey -v # vi mode
    # emacs bindings, because im a degenerate who mixes the two
    bindkey "^F" forward-char
    bindkey "^B" backward-char
    bindkey "^A" beginning-of-line
    bindkey "^E" end-of-line
    bindkey "^K" kill-line
    bindkey "^L" clear-screen
    bindkey "^R" history-incremental-search-backward
    bindkey "^U" kill-whole-line
    bindkey "^W" backward-kill-word
    bindkey "^Y" yank
    # meta key commands
    bindkey "^[f" emacs-forward-word
    bindkey "^[b" emacs-backward-word

    bindkey $upkey history-beginning-search-backward
    bindkey $downkey history-beginning-search-forward
    export KEYTIMEOUT=1
}



_setup_zsh_preferences() {
    if [[ $(command -v emacs) ]]; then
        export EDITOR="emacsclient -nw -a 'emacs -nw'"
    elif [[ $(command -v vim.tiny) ]]; then
        export EDITOR=vim.tiny
    elif [[ $(command -v vi) ]]; then
        export EDITOR=vi
    elif [[ $(command -v vim) ]]; then
        export EDITOR=vim
    else
        export EDITOR=nano
    fi
}



_setup_aliases() {
    alias ls="ls --color=auto"
    alias ll="ls -l"
    alias emacs="emacsclient -nw -a 'emacs -nw'"

    if [[ ! $(command -v vim) ]] && [[ $(command -v vim.tiny) ]]; then
        alias vim="vim.tiny"
    fi
}



_setup_dotfiles_command() {
    alias dotfiles="git --git-dir=\"$HOME/.local/src/shenso-dotfiles\" --work-tree=\"$HOME\""
    mkdir -p "$HOME/.local/src"
    if [ ! -d "$HOME/.local/src/shenso-dotfiles" ]; then
        git init --quiet --bare "$HOME/.local/src/shenso-dotfiles"
        git --git-dir="$HOME/.local/src/shenso-dotfiles" \
            --work-tree="$HOME" \
            config --local status.showUntrackedFiles no
    fi
}

_setup_emacs_cfg_command() {
    if [ -d $HOME/.emacs.d ]; then
        local emacs_dir=$HOME/.emacs.d
    elif [[ -v XDG_CONFIG_HOME && -d $XDG_CONFIG_HOME/emacs ]]; then
        local emacs_dir=$XDG_CONFIG_HOME/emacs
    elif [ -d $HOME/.config/emacs ]; then
        local emacs_dir=$HOME/.config/emacs
    fi

    if [[ -v emacs_dir ]]; then
        local git_dir=$HOME/.local/src/emacs.d

        alias emacs-cfg="git --git-dir=\"$git_dir\" --work-tree=\"$emacs_dir\""
        mkdir -p "$HOME/.local/src"

        if [ ! -d $git_dir ]; then
            git init --quiet --bare $git_dir
            git --git-dir="$git_dir" \
                --work-tree="$emacs_dir" \
                config --local status.showUntrackedFiles no
            git --git-dir="$git_dir" --work-tree="$emacs_dir" \
                remote add origin git@github.com:shenso/.emacs.d.git
        fi
    fi
}



_setup_common_zshrc() {
    _setup_zsh_theme
    _setup_zsh_history
    _setup_zsh_completions
    _setup_zsh_bindings
    _setup_zsh_preferences
    _setup_aliases
}

_setup_user_zshrc() {
    _setup_common_zshrc
    _setup_dotfiles_command
    _setup_emacs_cfg_command

    . $ZDOTDIR/commands.sh
}

_setup_root_zshrc() {
    _setup_common_zshrc
}

[ $(id -u) -eq 0 ] && _setup_root_zshrc || _setup_user_zshrc
