FROM manjarolinux/base:latest

# System vorbereiten
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm sudo base-devel git wget tigervnc xorg-server xorg-xinit xf86-video-vesa

# Cutefish installieren
RUN pacman -S --noconfirm cutefish cutefish-core cutefish-dock cutefish-filemanager cutefish-settings

# noVNC + Websockify
RUN pacman -S --noconfirm novnc websockify

# Benutzer "norobb" anlegen mit Passwort "2510"
RUN useradd -m -s /bin/bash norobb && echo "norobb:2510" | chpasswd && \
    echo "norobb ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER norobb
WORKDIR /home/norobb

# Startup-Skript kopieren
COPY startup.sh /setup/startup.sh
RUN chmod +x /setup/startup.sh
