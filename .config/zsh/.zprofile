if [ $(id -u) -eq 0 ]; then
    exit
fi

SHENSO_XINIT_HOSTS=( "plato" )
SHENSO_WILL_XINIT=0

for target in "$SHENSO_XINIT_HOSTS[@]"; do
    [[ $(hostname 2>/dev/null) == $target || $HOST == $target ]] && SHENSO_WILL_XINIT=1
done

if [ $(command -v emacs) ] && [[ "$(uname)" == "Linux" ]]; then
    emacs --daemon > /dev/null
fi

if [ $SHENSO_WILL_XINIT -eq 1 ] && [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
    if [ $(command -v xsecurelock) ]; then
        export XSECURELOCK_XSCREENSAVER_PATH=/usr/libexec/xscreensaver
        export XSECURELOCK_SAVER=saver_xscreensaver
        export XSECURELOCK_SHOW_DATETIME=1
        export XSECURELOCK_SINGLE_AUTH_WINDOW=1
        export XSECURELOCK_AUTH_TIMEOUT=30
    fi

    exec startx
fi
