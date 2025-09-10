#!/bin/bash
# start-desktop.sh - Start desktop services

set -e

echo "Starting Elementary OS Desktop Environment..."

# Function to check if a process is running
is_running() {
    pgrep -f "$1" > /dev/null
}

# Function to wait for a service to start
wait_for_service() {
    local service_name="$1"
    local check_command="$2"
    local max_attempts=30
    local attempt=0
    
    echo "Waiting for $service_name to start..."
    while [ $attempt -lt $max_attempts ]; do
        if eval "$check_command"; then
            echo "$service_name started successfully"
            return 0
        fi
        sleep 1
        attempt=$((attempt + 1))
    done
    
    echo "Failed to start $service_name after $max_attempts attempts"
    return 1
}

# Kill existing VNC sessions
echo "Cleaning up existing sessions..."
vncserver -kill :1 2>/dev/null || true
pkill -f "websockify" 2>/dev/null || true
pkill -f "Xvnc" 2>/dev/null || true

# Wait a moment for processes to terminate
sleep 2

# Start VNC server
echo "Starting VNC server..."
export DISPLAY=:1
vncserver :1 -geometry ${VNC_RESOLUTION:-1920x1080} -depth ${VNC_COLOR_DEPTH:-24} -localhost

# Wait for VNC server to start
wait_for_service "VNC Server" "netstat -ln | grep ':5901' > /dev/null"

# Start noVNC web server
echo "Starting noVNC web interface..."
cd /opt/noVNC
python3 -m websockify --web . 6080 localhost:5901 &

# Wait for noVNC to start
wait_for_service "noVNC" "netstat -ln | grep ':6080' > /dev/null"

# Create desktop shortcuts
echo "Creating desktop shortcuts..."
mkdir -p ~/Desktop

# Terminal shortcut
cat > ~/Desktop/Terminal.desktop << 'TERMINAL_EOF'
[Desktop Entry]
Version=1.0
Name=Terminal
Comment=Use the command line
GenericName=Terminal
Exec=xfce4-terminal
Icon=utilities-terminal
Type=Application
Categories=System;TerminalEmulator;
StartupNotify=true
TERMINAL_EOF

# Firefox shortcut
cat > ~/Desktop/Firefox.desktop << 'FIREFOX_EOF'
[Desktop Entry]
Version=1.0
Name=Firefox
Comment=Browse the World Wide Web
GenericName=Web Browser
Exec=firefox %u
Icon=firefox
Type=Application
Categories=Network;WebBrowser;
StartupNotify=true
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;
FIREFOX_EOF

# File Manager shortcut
cat > ~/Desktop/Files.desktop << 'FILES_EOF'
[Desktop Entry]
Version=1.0
Name=Files
Comment=Access and organize files
GenericName=File Manager
Exec=thunar %F
Icon=system-file-manager
Type=Application
Categories=System;FileTools;FileManager;
StartupNotify=true
MimeType=inode/directory;
FILES_EOF

chmod +x ~/Desktop/*.desktop

echo "Desktop services started successfully!"
echo ""
echo "Access your desktop environment via noVNC at:"
echo "http://localhost:6080/vnc.html"
echo ""
echo "VNC connection details:"
echo "Host: localhost"
echo "Port: 5901"
echo "Password: ${VNC_PASSWORD:-codespace}"
