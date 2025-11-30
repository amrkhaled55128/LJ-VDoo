#!/usr/bin/env bash
set -e

# VNC password configuration
VNC_PASSWORD="${VNC_PASSWORD:-ChangeMe123!}"
export DISPLAY=:0

echo "=========================================="
echo "Starting noVNC Desktop Environment"
echo "=========================================="

# Create VNC directory and password file
echo "Setting up VNC password..."
mkdir -p /root/.vnc
x11vnc -storepasswd "$VNC_PASSWORD" /root/.vnc/passwd

# Start Xvfb (virtual X server)
echo "Starting Xvfb virtual display..."
Xvfb :0 -screen 0 1024x768x24 &
XVFB_PID=$!
sleep 3

# Verify Xvfb is running
if ! ps -p $XVFB_PID > /dev/null; then
    echo "ERROR: Xvfb failed to start"
    exit 1
fi
echo "Xvfb started successfully (PID: $XVFB_PID)"

# Setup DBus and XDG environment (Required for KDE)
echo "Setting up DBus and XDG environment..."
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
chmod 700 $XDG_RUNTIME_DIR

# Start DBus
mkdir -p /var/run/dbus
dbus-daemon --system --fork
export DBUS_SESSION_BUS_ADDRESS=`dbus-daemon --fork --config-file=/usr/share/dbus-1/session.conf --print-address`

# Start KDE Plasma desktop environment
echo "Starting KDE Plasma desktop environment..."
dbus-launch --exit-with-session /usr/bin/startplasma-x11 &
sleep 10

# Start x11vnc VNC server
echo "Starting x11vnc server on localhost:5900..."
x11vnc \
    -display :0 \
    -rfbauth /root/.vnc/passwd \
    -forever \
    -shared \
    -rfbport 5900 \
    -localhost \
    &
X11VNC_PID=$!
sleep 2

# Verify x11vnc is running
if ! ps -p $X11VNC_PID > /dev/null; then
    echo "ERROR: x11vnc failed to start"
    exit 1
fi
echo "x11vnc started successfully (PID: $X11VNC_PID)"

# Start noVNC/websockify
echo "Starting noVNC on 0.0.0.0:6080..."
echo "=========================================="
echo "noVNC Desktop Ready!"
echo "Connect via browser to access the desktop"
echo "VNC Password: $VNC_PASSWORD"
echo "=========================================="

# Start websockify in foreground (this becomes PID 1)
exec /usr/share/novnc/utils/websockify/run \
    --web=/usr/share/novnc/ \
    0.0.0.0:3389 \
    localhost:5900
