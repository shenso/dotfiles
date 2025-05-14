if [ $(id -u) -eq 0 ]; then
    exit
fi

SHENSO_XINIT_HOSTS=( "plato" )
SHENSO_WILL_XINIT=0

for target in "$SHENSO_XINIT_HOSTS[@]"; do
    [[ $(hostname 2>/dev/null) == $target || $HOST == $target ]] && SHENSO_WILL_XINIT=1
done

if [ $SHENSO_WILL_XINIT -eq 1 ] && [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
    exec startx
fi
