#!/usr/bin/env bash
set -e

export DISPLAY=:0

echo "=========================================="
echo "Starting Kali Linux Desktop Environment"
echo "=========================================="

# Setup DBus and XDG
echo "Setting up DBus and XDG environment..."
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
chmod 700 $XDG_RUNTIME_DIR

# Start DBus
mkdir -p /var/run/dbus
dbus-daemon --system --fork
export DBUS_SESSION_BUS_ADDRESS=$(dbus-daemon --fork --config-file=/usr/share/dbus-1/session.conf --print-address)

# Disable screen locker
echo "Disabling screen locker..."
mkdir -p /root/.config
cat > /root/.config/kscreenlockerrc <<EOL
[Daemon]
Autolock=false
LockOnResume=false
EOL

# Start Xvfb
echo "Starting Xvfb virtual display..."
Xvfb :0 -screen 0 1280x720x24 &
XVFB_PID=$!
sleep 3

if ! ps -p $XVFB_PID > /dev/null; then
    echo "ERROR: Xvfb failed to start"
    exit 1
fi
echo "Xvfb started (PID: $XVFB_PID)"

# Disable power management
xset s off 2>/dev/null || true
xset s noblank 2>/dev/null || true

# Start Xfce desktop
echo "Starting Xfce desktop..."
startxfce4 &
sleep 5

# Start x11vnc (no password)
echo "Starting x11vnc on localhost:5900..."
x11vnc \
    -display :0 \
    -forever \
    -shared \
    -rfbport 5900 \
    -nopw \
    &
X11VNC_PID=$!
sleep 2

if ! ps -p $X11VNC_PID > /dev/null; then
    echo "ERROR: x11vnc failed to start"
    exit 1
fi
echo "x11vnc started (PID: $X11VNC_PID)"

# Configure and start xrdp
echo "Configuring xrdp..."
# Use color depth 24
sed -i 's/max_bpp=32/max_bpp=24/g' /etc/xrdp/xrdp.ini 2>/dev/null || true

# Start xrdp service
echo "Starting xrdp on port 3389..."
service xrdp start
sleep 2

# Start noVNC
echo "Starting noVNC on 0.0.0.0:6080..."
echo "=========================================="
echo "Kali Linux Desktop Ready!"
echo "Browser Access: http://your-server:6080"
echo "RDP Access: your-server:3389"
echo "Username: root"
echo "Password: kali"
echo "=========================================="

# Keep container alive with websockify in foreground
exec /usr/share/novnc/utils/websockify/run \
    --web=/usr/share/novnc/ \
    0.0.0.0:6080 \
    localhost:5900
