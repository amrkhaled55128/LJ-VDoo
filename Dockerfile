FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set display environment variable
ENV DISPLAY=:0

# Install system dependencies and desktop environment
RUN apt-get update && apt-get install -y \
    # Basic utilities
    curl \
    wget \
    ca-certificates \
    supervisor \
    # X11 and VNC components
    xvfb \
    x11vnc \
    # KDE Plasma Desktop
    kde-plasma-desktop \
    breeze-icon-theme \
    dolphin \
    konsole \
    dbus-x11 \
    # noVNC dependencies
    python3 \
    python3-pip \
    git \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

# Install Google Chrome
RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get update \
    && apt-get install -y ./google-chrome-stable_current_amd64.deb \
    && rm google-chrome-stable_current_amd64.deb

# Install noVNC and websockify
RUN git clone --depth 1 https://github.com/novnc/noVNC.git /usr/share/novnc \
    && git clone --depth 1 https://github.com/novnc/websockify /usr/share/novnc/utils/websockify \
    && ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# Copy startup script
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Set working directory
WORKDIR /root

# Expose noVNC port
EXPOSE 3389
EXPOSE 6080

# Start the container
CMD ["/usr/local/bin/start.sh"]

