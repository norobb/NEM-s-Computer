FROM manjarolinux/base:latest

# System vorbereiten
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm sudo base-devel git wget tigervnc xorg-server xorg-xinit xf86-video-vesa

# Cutefish installieren
RUN pacman -S --noconfirm cutefish cutefish-core cutefish-dock cutefish-filemanager cutefish-settings

# noVNC + websockify installieren (über GitHub, nicht pacman)
USER root
RUN pacman -S --noconfirm python python-pip

# noVNC
RUN git clone https://github.com/novnc/noVNC.git /opt/novnc && \
    ln -s /opt/novnc/vnc.html /opt/novnc/index.html

# websockify
RUN git clone https://github.com/novnc/websockify /opt/websockify && \
    pip install --break-system-packages -r /opt/websockify/requirements.txt


# Benutzer "norobb" anlegen mit Passwort "2510"
RUN useradd -m -s /bin/bash norobb && echo "norobb:2510" | chpasswd && \
    echo "norobb ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER norobb
WORKDIR /home/norobb

# Startup-Skript kopieren
COPY startup.sh /setup/startup.sh
RUN chmod +x /setup/startup.sh
