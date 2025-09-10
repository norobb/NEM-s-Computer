# Troubleshooting Guide

## Häufige Probleme und Lösungen

### 1. Desktop startet nicht

**Problem**: Schwarzer Bildschirm oder keine Verbindung möglich

**Lösungen**:
```bash
# Lösung 1: Services neu starten
vncserver -kill :1
bash /usr/local/bin/start-desktop.sh

# Lösung 2: Container neu starten (im VS Code Terminal)
sudo reboot

# Lösung 3: Manueller Start
export DISPLAY=:1
vncserver :1 -geometry 1920x1080 -depth 24
cd /opt/noVNC && python3 -m websockify --web . 6080 localhost:5901 &
```

### 2. Performance-Probleme

**Problem**: Langsame Reaktionszeiten oder hohe CPU-Last

**Lösungen**:
- Auflösung reduzieren: `VNC_RESOLUTION=1280x720`
- Browser-Tabs schließen
- Unnötige Anwendungen beenden
- Desktop-Effekte deaktivieren

### 3. Netzwerk-Verbindungsprobleme

**Problem**: Port 6080 nicht erreichbar

**Lösungen**:
```bash
# Port-Status prüfen
netstat -ln | grep 6080

# noVNC neu starten
pkill -f websockify
cd /opt/noVNC && python3 -m websockify --web . 6080 localhost:5901 &
```

### 4. VNC-Authentifizierung fehlgeschlagen

**Problem**: Passwort wird nicht akzeptiert

**Lösungen**:
```bash
# Neues Passwort setzen
echo "neues-passwort" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

# VNC neu starten
vncserver -kill :1
vncserver :1 -geometry 1920x1080 -depth 24
```

### 5. Audio-Probleme

**Problem**: Kein Ton im Browser

**Lösung**: Audio wird über noVNC nicht unterstützt. Für Audio-Anwendungen lokale VNC-Clients verwenden.

### 6. Zwischenablage funktioniert nicht

**Problem**: Copy/Paste zwischen Host und Container

**Lösung**: noVNC unterstützt grundlegende Zwischenablage-Funktionen über das noVNC-Interface.

## Log-Dateien

Wichtige Log-Dateien für Debugging:

```bash
# VNC Server Logs
ls ~/.vnc/*.log

# System Logs
journalctl -u docker
dmesg | tail
```

## Performance-Monitoring

```bash
# System-Ressourcen überwachen
htop

# Netzwerk-Verbindungen prüfen
netstat -tuln

# Festplatten-Nutzung
df -h
```