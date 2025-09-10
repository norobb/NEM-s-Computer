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
    # System essentials
    curl \
    wget \
    git \
    unzip \
    sudo \
    locales \
    tzdata \
    ca-certificates \
    software-properties-common \
    apt-transport-https \
    gnupg \
    lsb-release \
    # X11 and display components
    xorg \
    x11-xserver-utils \
    x11-utils \
    x11-apps \
    # VNC server
    tigervnc-standalone-server \
    tigervnc-common \
    # Desktop environment (lightweight alternatives to full Pantheon)
    xfce4 \
    xfce4-goodies \
    elementary-icon-theme \
    elementary-wallpapers-extra \
    # Elementary OS specific packages
    elementary-tweaks \
    # Web browser
    firefox \
    # Development tools
    build-essential \
    python3 \
    python3-pip \
    nodejs \
    npm \
    vim \
    nano \
    # Network tools
    openssh-client \
    net-tools \
    # Additional utilities
    htop \
    tree \
    file \
    && rm -rf /var/lib/apt/lists/*

# Set up locales
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Create vscode user with sudo privileges
RUN useradd -m -s /bin/bash vscode && \
    echo "norobb:2510" | chpasswd && \
    usermod -aG sudo vscode && \
    echo "norobb ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install noVNC and websockify
WORKDIR /opt
RUN git clone https://github.com/novnc/noVNC.git && \
    git clone https://github.com/novnc/websockify.git && \
    ln -s /opt/noVNC/vnc.html /opt/noVNC/index.html

# Install Python dependencies for websockify
RUN pip3 install websockify

# Set up VNC directory and configuration
RUN mkdir -p /home/vscode/.vnc && \
    chown -R vscode:vscode /home/vscode/.vnc

# Copy configuration files and scripts
COPY scripts/setup-desktop.sh /usr/local/bin/setup-desktop.sh
COPY scripts/start-desktop.sh /usr/local/bin/start-desktop.sh
COPY scripts/vnc-startup.sh /usr/local/bin/vnc-startup.sh
COPY config/xstartup /home/vscode/.vnc/xstartup
COPY config/vnc-config /home/vscode/.vnc/config

# Make scripts executable
RUN chmod +x /usr/local/bin/*.sh && \
    chmod +x /home/vscode/.vnc/xstartup && \
    chown -R vscode:vscode /home/vscode/.vnc

# Set up desktop environment configuration
RUN mkdir -p /home/vscode/.config && \
    chown -R vscode:vscode /home/vscode/.config

# Configure X11 for VNC
RUN mkdir -p /tmp/.X11-unix && \
    chmod 1777 /tmp/.X11-unix

# Expose VNC and noVNC ports
EXPOSE 5901 6080

# Set environment variables
ENV DISPLAY=:1
ENV VNC_RESOLUTION=1920x1080
ENV VNC_COLOR_DEPTH=24
ENV VNC_PASSWORD=codespace
ENV NOVNC_PATH="/opt/noVNC"

# Switch to vscode user
USER vscode
WORKDIR /home/vscode

# Set VNC password
RUN mkdir -p ~/.vnc && \
    echo "codespace" | vncpasswd -f > ~/.vnc/passwd && \
    chmod 600 ~/.vnc/passwd

# Final setup
USER root
RUN apt-get update && apt-get install -y \
    dbus-x11 \
    at-spi2-core \
    && rm -rf /var/lib/apt/lists/*

# Create startup script
RUN echo '#!/bin/bash\n\
export DISPLAY=:1\n\
export PULSE_SERVER="unix:${XDG_RUNTIME_DIR}/pulse/native"\n\
# Start dbus\n\
dbus-launch --sh-syntax --exit-with-session &\n\
# Start VNC server\n\
su - vscode -c "vncserver :1 -geometry $VNC_RESOLUTION -depth $VNC_COLOR_DEPTH -localhost no"\n\
# Start noVNC\n\
cd /opt/noVNC && python3 -m websockify --web . 6080 localhost:5901 &\n\
# Keep container running\n\
tail -f /dev/null\n\
' > /start-services.sh && chmod +x /start-services.sh

USER vscode
WORKDIR /workspace

# Start services by default
CMD ["/start-services.sh"]
