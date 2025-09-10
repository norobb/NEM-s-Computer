# Elementary OS Codespace with noVNC

Dieses Repository stellt eine vollständige Elementary OS Desktop-Umgebung in GitHub Codespaces bereit, die über noVNC im Webbrowser zugänglich ist.

## 🚀 Schnellstart

1. Öffnen Sie dieses Repository in GitHub Codespaces
2. Warten Sie, bis der Container vollständig aufgebaut ist (ca. 3-5 Minuten)
3. Öffnen Sie den automatisch weitergeleiteten Port 6080
4. Genießen Sie Ihre Elementary OS Desktop-Erfahrung!

## 🔧 Technische Details

### Architektur
- **Base OS**: Ubuntu 22.04 LTS
- **Desktop Environment**: XFCE4 mit Elementary OS Theming
- **VNC Server**: TigerVNC
- **Web Interface**: noVNC
- **Container Runtime**: Docker/Podman

### Ports
- **6080**: noVNC Web Interface (HTTP)
- **5901**: VNC Server (nur localhost)

### Standard-Anmeldedaten
- **VNC Password**: `codespace`

## 📋 Enthaltene Software

### Development Tools
- Git
- Python 3 + pip
- Node.js + npm
- Build essentials (gcc, make, etc.)
- VS Code Server (automatisch verfügbar)

### Desktop Applications
- Firefox Web Browser
- Thunar File Manager
- XFCE Terminal
- Text Editor

### System Tools
- htop
- tree
- curl/wget
- SSH client

## ⚙️ Konfiguration

### Display-Auflösung ändern
Bearbeiten Sie die Umgebungsvariable `VNC_RESOLUTION` in der `devcontainer.json`:
```json
"containerEnv": {
  "VNC_RESOLUTION": "1280x720"
}
```

### VNC-Passwort ändern
Ändern Sie die Umgebungsvariable `VNC_PASSWORD`:
```json
"containerEnv": {
  "VNC_PASSWORD": "ihr-neues-passwort"
}
```

### Zusätzliche Software installieren
Fügen Sie Installationsbefehle in `scripts/setup-desktop.sh` hinzu oder erstellen Sie ein `postCreateCommand` in der `devcontainer.json`.

## 🔒 Sicherheit

- VNC Server ist standardmäßig nur über localhost erreichbar
- noVNC fungiert als sicherer Proxy
- Container läuft mit minimalen Privilegien
- Regelmäßige Updates der Base Images empfohlen

## 🐛 Troubleshooting

### Desktop startet nicht
```bash
# VNC Server neu starten
vncserver -kill :1
bash /usr/local/bin/start-desktop.sh
```

### noVNC zeigt schwarzen Bildschirm
```bash
# Services neu starten
sudo service dbus restart
vncserver -kill :1
bash /usr/local/bin/start-desktop.sh
```

### Performance-Probleme
- Reduzieren Sie die Bildschirmauflösung
- Schließen Sie ungenutzte Anwendungen
- Prüfen Sie die Codespace-Resource-Limits

## 📝 Entwicklung

### Lokale Entwicklung
```bash
# Repository klonen
git clone <ihr-repo-url>
cd <repo-name>

# Container lokal bauen und starten
make build
make run

# Desktop öffnen
open http://localhost:6080
```

### Anpassungen
- **Desktop Theme**: Bearbeiten Sie XFCE-Konfigurationsdateien
- **Software**: Fügen Sie Pakete zum Dockerfile hinzu
- **Startup**: Modifizieren Sie die Skripte in `scripts/`

## 🤝 Contributing

Beiträge sind willkommen! Bitte erstellen Sie Issues für Bugs oder Feature-Requests.

## 📄 Lizenz

MIT License - siehe LICENSE Datei für Details.

---

## 📞 Support

Bei Problemen oder Fragen:
1. Prüfen Sie die Troubleshooting-Sektion
2. Schauen Sie in die GitHub Issues
3. Erstellen Sie ein neues Issue mit detaillierter Beschreibung

**Viel Spaß mit Ihrer Elementary OS Codespace Umgebung!** 🎉
