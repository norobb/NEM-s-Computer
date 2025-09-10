# Elementary OS with noVNC for GitHub Codespaces
# --- REVISED VERSION ---
FROM ubuntu:22.04

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Set up timezone
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# === OPTIMIZATION: Combine all package installations into a single layer ===
# This improves caching and reduces image size.
RUN apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common ca-certificates && \
    add-apt-repository ppa:elementary-os/stable -y && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    # System essentials
    curl wget git unzip sudo locales tzdata apt-transport-https gnupg lsb-release \
    # X11 and display components
    xorg x11-xserver-utils x11-utils x11-apps \
    # VNC server
    tigervnc-standalone-server tigervnc-common \
    # Desktop environment (XFCE with Elementary theme)
    xfce4 xfce4-goodies elementary-icon-theme \
    # Web browser & tools
    firefox dbus-x11 at-spi2-core \
    # Development tools
    build-essential python3 python3-pip nodejs npm vim nano \
    # Network & utility tools
    openssh-client net-tools htop tree file \
    # Clean up apt cache
    && rm -rf /var/lib/apt/lists/*

# Set up locales
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# === BEST PRACTICE: Create user and add sudo rights via /etc/sudoers.d ===
RUN useradd -m -s /bin/bash norobb && \
    usermod -aG sudo norobb && \
    echo "norobb ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/norobb-nopasswd && \
    chmod 0440 /etc/sudoers.d/norobb-nopasswd

# === REPRODUCIBILITY: Install specific versions of noVNC and websockify ===
ENV NOVNC_VERSION=v1.4.0
WORKDIR /opt
RUN git clone --depth 1 --branch ${NOVNC_VERSION} https://github.com/novnc/noVNC.git && \
    ln -s /opt/noVNC/vnc.html /opt/noVNC/index.html && \
    # Install websockify via pip, no need to clone its repository
    pip3 install websockify

# Copy user configuration files
# Assumes you have a 'config' and 'scripts' directory next to your Dockerfile
COPY config/xstartup /home/norobb/.vnc/xstartup
COPY config/vnc-config /home/norobb/.vnc/config
COPY scripts/start-vnc.sh /usr/local/bin/start-vnc.sh

# Set up permissions
RUN chmod +x /usr/local/bin/start-vnc.sh /home/norobb/.vnc/xstartup && \
    chown -R norobb:norobb /home/norobb

# Expose VNC and noVNC ports
EXPOSE 5901 6080

# Set environment variables for the VNC session
ENV DISPLAY=:1
ENV VNC_RESOLUTION=1920x1080
ENV VNC_COLOR_DEPTH=24
ENV VNC_PASSWORD=codespace

# Switch to norobb user to set the VNC password
USER norobb
WORKDIR /home/norobb
RUN mkdir -p ~/.vnc && \
    echo "${VNC_PASSWORD}" | vncpasswd -f > ~/.vnc/passwd && \
    chmod 600 ~/.vnc/passwd

# Final WORKDIR for the Codespace session
WORKDIR /workspace

CMD ["/start-services.sh"]
