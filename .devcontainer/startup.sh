#!/bin/bash

# VNC-Passwort setzen (hier gleich wie Benutzerpasswort: 2510)
mkdir -p ~/.vnc
echo "2510" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

# VNC-Server starten (Display :1, Cutefish)
vncserver :1 -geometry 1280x800 -depth 24
export DISPLAY=:1
cutefish-session &

# noVNC starten auf Port 6080
websockify --web=/usr/share/novnc/ 6080 localhost:5901
