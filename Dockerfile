FROM kalilinux/kali-rolling

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Set display
ENV DISPLAY=:0

# Set root password to 'kali'
RUN echo 'root:kali' | chpasswd

# Update and install desktop environment
RUN apt-get update && apt-get install -y \
    # Desktop environment
    kali-desktop-xfce \
    xfce4 \
    xfce4-terminal \
    # VNC and X11
    xvfb \
    x11vnc \
    dbus-x11 \
    # RDP
    xrdp \
    # noVNC dependencies
    python3 \
    git \
    net-tools \
    wget \
    curl \
    kali-linux-everything \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install noVNC
RUN git clone --depth 1 https://github.com/novnc/noVNC.git /usr/share/novnc \
    && git clone --depth 1 https://github.com/novnc/websockify /usr/share/novnc/utils/websockify \
    && ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# Configure xrdp to use VNC
RUN echo "startxfce4" > /root/.xsession \
    && chmod +x /root/.xsession

# Copy startup script
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Set working directory
WORKDIR /root

# Expose ports
EXPOSE 6080 3389

# Start container
CMD ["/usr/local/bin/start.sh"]
