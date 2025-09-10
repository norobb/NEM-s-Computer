#!/bin/bash
# setup-desktop.sh - Initial desktop environment setup

set -e

echo "Setting up Elementary OS Desktop Environment..."

# Create necessary directories
mkdir -p ~/.vnc
mkdir -p ~/.config
mkdir -p ~/Desktop
mkdir -p ~/Documents
mkdir -p ~/Downloads

# Set up VNC password if not already set
if [ ! -f ~/.vnc/passwd ]; then
    echo "Setting up VNC password..."
    echo "${VNC_PASSWORD:-codespace}" | vncpasswd -f > ~/.vnc/passwd
    chmod 600 ~/.vnc/passwd
fi

# Create xstartup script for VNC
cat > ~/.vnc/xstartup << 'XSTARTUP_EOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

# Start dbus
export $(dbus-launch)

# Set up environment
export XKL_XMODMAP_DISABLE=1
export XDG_CURRENT_DESKTOP="XFCE"
export XDG_SESSION_DESKTOP="xfce"
export XDG_SESSION_TYPE="x11"

# Start window manager
startxfce4 &

# Keep session alive
exec /bin/bash
XSTARTUP_EOF

chmod +x ~/.vnc/xstartup

# Create VNC config
cat > ~/.vnc/config << 'VNC_CONFIG_EOF'
geometry=1920x1080
dpi=96
depth=24
desktop=Elementary OS Desktop
VNC_CONFIG_EOF

# Configure XFCE to look more like Elementary OS
mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml

# Window Manager settings
cat > ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml << 'XFWM4_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="theme" type="string" value="elementary"/>
    <property name="title_font" type="string" value="Open Sans 9"/>
    <property name="button_layout" type="string" value="CHM|"/>
    <property name="show_frame_shadow" type="bool" value="true"/>
    <property name="show_popup_shadow" type="bool" value="true"/>
  </property>
</channel>
XFWM4_EOF

# Desktop settings
cat > ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml << 'DESKTOP_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitor0" type="empty">
        <property name="image-path" type="string" value="/usr/share/pixmaps/elementary-wallpaper-default.jpg"/>
        <property name="image-style" type="int" value="5"/>
        <property name="rgba1" type="array">
          <value type="double" value="0.2"/>
          <value type="double" value="0.2"/>
          <value type="double" value="0.2"/>
          <value type="double" value="1"/>
        </array>
      </property>
    </property>
  </property>
</channel>
DESKTOP_EOF

echo "Desktop setup completed successfully!"
