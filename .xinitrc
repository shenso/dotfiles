#!/bin/sh

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# invoke global X session script
. /etc/X11/Xsession

# setup xsecurelock
if [ $(command -v xsecurelock) ]; then
    export XSECURELOCK_SAVER=saver_xscreensaver
    export XSECURELOCK_SHOW_DATETIME=1
    export XSECURELOCK_SINGLE_AUTH_WINDOW=1
    export XSECURELOCK_AUTH_TIMEOUT=30
    xfconf-query --channel xfce4-session --property /general/LockCommand --set "xsecurelock"
fi

if [ -n "${ERRFILE+exists}" ]; then
    [ -f $ERRFILE ] && mv $ERRFILE $ERRFILE.old
    exec startxfce4 > $ERRFILE 2>&1
else
    exec startxfce
fi

