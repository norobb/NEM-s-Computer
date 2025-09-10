# Elementary OS with noVNC for GitHub Codespaces
FROM ubuntu:22.04

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Set up timezone
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install base system and Elementary OS components
RUN apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:elementary-os/stable -y && \
    apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    unzip \
    sudo \
    locales \
    tzdata \
    ca-certificates \
    apt-transport-https \
    gnupg \
    lsb-release \
    xorg \
    x11-xserver-utils \
    x11-utils \
    x11-apps \
    tigervnc-standalone-server \
    tigervnc-common \
    xfce4 \
    xfce4-goodies \
    elementary-icon-theme \
    firefox \
    build-essential \
    python3 \
    python3-pip \
    nodejs \
    npm \
    vim \
    nano \
    openssh-client \
    net-tools \
    htop \
    tree \
    file \
    dbus-x11 \
    at-spi2-core \
    && rm -rf /var/lib/apt/lists/*

# Set up locales
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Create norobb user with sudo privileges
RUN useradd -m -s /bin/bash norobb && \
    usermod -aG sudo norobb && \
    echo "norobb ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install noVNC and websockify
WORKDIR /opt
RUN git clone https://github.com/novnc/noVNC.git && \
    git clone https://github.com/novnc/websockify.git && \
    ln -s /opt/noVNC/vnc.html /opt/noVNC/index.html

# Install Python dependencies for websockify
RUN pip3 install websockify

# Set up VNC directory and configuration (now with correct user reference)
RUN mkdir -p /home/norobb/.vnc && \
    chown -R norobb:norobb /home/norobb/.vnc

# Set up desktop environment configuration
RUN mkdir -p /home/norobb/.config && \
    chown -R norobb:norobb /home/norobb/.config

# Configure X11 for VNC
RUN mkdir -p /tmp/.X11-unix && \
    chmod 1777 /tmp/.X11-unix

# Copy configuration files and scripts and ensure correct ownership
COPY scripts/setup-desktop.sh /usr/local/bin/setup-desktop.sh
COPY scripts/start-desktop.sh /usr/local/bin/start-desktop.sh
COPY scripts/vnc-startup.sh /usr/local/bin/vnc-startup.sh
COPY config/xstartup /home/norobb/.vnc/xstartup
COPY config/vnc-config /home/norobb/.vnc/config

# Set ownership of copied files (this is a separate, clear step)
RUN chown -R norobb:norobb /home/norobb/.vnc && \
    chmod +x /usr/local/bin/*.sh && \
    chmod +x /home/norobb/.vnc/xstartup

# Expose VNC and noVNC ports
EXPOSE 5901 6080

# Set environment variables
ENV DISPLAY=:1
ENV VNC_RESOLUTION=1920x1080
ENV VNC_COLOR_DEPTH=24
ENV VNC_PASSWORD=codespace
ENV NOVNC_PATH="/opt/noVNC"

# Switch to norobb user to configure VNC
USER norobb
WORKDIR /home/norobb

# Set VNC password
RUN vncpasswd -f > ~/.vnc/passwd && \
    echo "codespace" | vncpasswd -f > ~/.vnc/passwd && \
    chmod 600 ~/.vnc/passwd

# Final user and directory setup
USER root
WORKDIR /workspace

# Create startup script
RUN echo '#!/bin/bash\n\
export DISPLAY=:1\n\
export PULSE_SERVER="unix:${XDG_RUNTIME_DIR}/pulse/native"\n\
# Start dbus\n\
dbus-launch --sh-syntax --exit-with-session &\n\
# Start VNC server as the correct user\n\
vncserver :1 -geometry $VNC_RESOLUTION -depth $VNC_COLOR_DEPTH -localhost no\n\
# Start noVNC\n\
cd /opt/noVNC && python3 -m websockify --web . 6080 localhost:5901 &\n\
# Keep container running\n\
tail -f /dev/null\n\
' > /start-services.sh && chmod +x /start-services.sh

# Start services as norobb by default
USER norobb
CMD ["/start-services.sh"]
