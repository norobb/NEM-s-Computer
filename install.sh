#!/bin/bash
# install.sh - Repository Setup Script

set -e

echo "🔧 Setting up Elementary OS Codespace Repository..."

# Prüfe ob Git installiert ist
if ! command -v git &> /dev/null; then
    echo "❌ Git ist nicht installiert. Bitte installieren Sie Git zuerst."
    exit 1
fi

# Setze Berechtigungen für Skripte
echo "📋 Setting permissions for scripts..."
chmod +x scripts/*.sh
chmod +x config/xstartup
chmod +x install.sh

echo "✅ Setup completed successfully!"
echo ""
echo "📋 Nächste Schritte:"
echo "1. Git Repository initialisieren: git init"
echo "2. Dateien hinzufügen: git add ."
echo "3. Ersten Commit erstellen: git commit -m 'Initial Elementary OS Codespace setup'"
echo "4. Zu GitHub pushen: git remote add origin <your-repo-url> && git push -u origin main"
echo "5. Repository in GitHub Codespaces öffnen"
echo ""
echo "🌐 Für lokale Entwicklung:"
echo "   make build && make run"
echo "   Dann öffnen Sie: http://localhost:6080"
