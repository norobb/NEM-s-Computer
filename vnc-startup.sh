#!/bin/bash
# vnc-startup.sh - VNC session startup script

export XKL_XMODMAP_DISABLE=1
export XDG_CURRENT_DESKTOP="XFCE"
export XDG_SESSION_DESKTOP="xfce"
export XDG_SESSION_TYPE="x11"

# Start dbus session
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    export $(dbus-launch --sh-syntax --exit-with-session)
fi

# Set up X11 environment
xrdb $HOME/.Xresources 2>/dev/null || true
xsetroot -solid grey 2>/dev/null || true

# Start window manager
exec startxfce4
