#!/bin/bash

# VNC-Passwort setzen
mkdir -p ~/.vnc
echo "2510" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

# VNC-Server starten (Display :1)
vncserver :1 -geometry 1280x800 -depth 24
export DISPLAY=:1
cutefish-session &

# noVNC starten (läuft jetzt auf 6080)
cd /opt/websockify
python3 run --web=/opt/novnc 6080 localhost:5901
