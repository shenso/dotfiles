#!/bin/sh

if [ ! "$(id -u)" -eq "0" ]; then
    echo "Must be root to run this script!" >> /dev/stderr
    exit 1
fi

if [ ! -n "${SUDO_USER+exists}" ]; then
    echo "Root access must be via sudo!" >> /dev/stderr
    exit 2
fi

_acknowledge_danger() {
    local acknowledgement_file=$HOME/.install_zsh_config_to_root_acknowledgement
    local confirm
    if [ ! -f "$acknowledgement_file" ]; then
        echo "WARNING! Your .zshrc, anything it calls, and your themes will all have root access."
        read -p "Are you sure you want to continue? [y/n]: " confirm
        if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
            read -p "Ignore this warning in the future? [y/n]: " confirm
            [ "$confirm" = "y" ] \
                || [ "$confirm" = "Y" ] \
                && touch $acknowledgement_file
        else
            unset confirm;
            exit 0;
        fi;
    fi
}
_acknowledge_danger; unset -f _acknowledge_danger


_install_zsh_config_to_root() {
    local user_zdotdir=$(su - $SUDO_USER -c 'echo $ZDOTDIR')
    local root_zdotdir="$HOME/.config/zsh"

    if [ "$user_zdotdir" = "" ]; then
        echo "\$ZDOTDIR not defined for $SUDO_USER" >> /dev/stderr
        echo "1"
    else
        mkdir -p "$root_zdotdir"
        err_msg=$( { cp "$(eval echo ~$SUDO_USER)/.zshenv" "$HOME/.zshenv" \
                         && cp "$user_zdotdir/.zshrc" "$root_zdotdir/.zshrc" \
                         && cp -r "$user_zdotdir/themes" "/etc/zsh/"; } \
                       2>&1)
        success=$?
        if [ ! "$success" -eq "0" ]; then
            echo "Failed to copy files! Errors\n:" >> /dev/stderr
            echo $err_msg | awk '{print "\t" $0}'
        fi;
        echo $success;
    fi
}
ret_val=$(_install_zsh_config_to_root)
unset -f _install_zsh_config_to_root
exit $ret_val
