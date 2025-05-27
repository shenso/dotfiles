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
if [ $(command -v xsecurelock) ] && [ -f "/usr/local/bin/xfce4-xsecurelock" ]; then
    xfconf-query --channel xfce4-session --property /general/LockCommand --set "xfce4-xsecurelock"
fi

exec startxfce4
