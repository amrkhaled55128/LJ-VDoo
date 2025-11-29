# Docker noVNC Linux Desktop

A complete, minimal Docker container that runs a lightweight Linux desktop environment (Xfce4) accessible via web browser using noVNC. Deployable on Fly.io or any Docker-compatible platform.

## 🎯 Features

- **Lightweight Desktop**: Xfce4 desktop environment
- **Browser Access**: Access via noVNC web interface (no VNC client needed)
- **Secure**: Password-protected VNC access
- **Cloud-Ready**: One-command deployment to Fly.io
- **Minimal**: Small footprint, fast startup

## 📋 Prerequisites

- **Docker**: For local testing
- **Fly.io CLI** (optional): For cloud deployment - [Install](https://fly.io/docs/hands-on/install-flyctl/)

## 🚀 Quick Start

### Local Testing with Docker

1. **Build the image**:
   ```bash
   docker build -t novnc-desktop .
   ```

2. **Run the container**:
   ```bash
   docker run -d -p 6080:6080 -e VNC_PASSWORD="MySecurePassword123" --name desktop novnc-desktop
   ```

3. **Access the desktop**:
   - Open your browser: http://localhost:6080
   - Click "Connect"
   - Enter your VNC password when prompted

4. **View logs**:
   ```bash
   docker logs desktop
   ```

5. **Stop and cleanup**:
   ```bash
   docker stop desktop
   docker rm desktop
   ```

### Deploy to Fly.io

1. **Install Fly CLI** (if not already installed):
   ```bash
   # Windows (PowerShell)
   iwr https://fly.io/install.ps1 -useb | iex
   
   # macOS/Linux
   curl -L https://fly.io/install.sh | sh
   ```

2. **Login to Fly.io**:
   ```bash
   fly auth login
   ```

3. **Launch your app** (first time):
   ```bash
   fly launch
   ```
   - Follow the prompts to choose an app name and region
   - When asked to deploy, say **Yes**

4. **Set VNC password** (recommended):
   ```bash
   fly secrets set VNC_PASSWORD="YourSecurePassword123!"
   ```

5. **Deploy updates**:
   ```bash
   fly deploy
   ```

6. **Open your app**:
   ```bash
   fly open
   ```
   Your desktop will be available at: `https://your-app-name.fly.dev`

7. **View logs**:
   ```bash
   fly logs
   ```

## 🔐 Security

- VNC is bound to `localhost` only - not exposed directly to the internet
- Only the noVNC web interface (port 6080) is exposed
- Default password is `ChangeMe123!` - **CHANGE THIS** via:
  - Environment variable: `-e VNC_PASSWORD="YourPassword"`
  - Fly.io secrets: `fly secrets set VNC_PASSWORD="YourPassword"`

## ⚙️ Customization

### Change Screen Resolution

Edit `start.sh` and modify the Xvfb line:
```bash
Xvfb :0 -screen 0 1280x720x24 &  # Change 1024x768 to desired resolution
```

### Use Different Desktop Environment

In `Dockerfile`, replace `xfce4` with:
- `lxde` - Even lighter weight
- `lxqt` - Modern Qt-based lightweight desktop

### Resource Allocation (Fly.io)

Edit `fly.toml` to adjust resources:
```toml
[[vm]]
  cpu_kind = "shared"
  cpus = 1
  memory_mb = 2048  # Increase for better performance
```

## 🛠️ Troubleshooting

### Desktop doesn't load
- Check logs: `docker logs desktop` or `fly logs`
- Ensure port 6080 is not already in use
- Verify Xvfb started successfully in logs

### Black screen in browser
- Wait 10-15 seconds for desktop environment to fully initialize
- Check that VNC password is correct
- Refresh the browser page

### Performance issues
- Increase memory allocation in `fly.toml`
- Use a lighter desktop environment (LXDE)
- Reduce screen resolution in `start.sh`

### Connection refused
- Verify container is running: `docker ps` or `fly status`
- Check that port 6080 is exposed
- For Fly.io, ensure health checks are passing

## 📁 Project Structure

```
.
├── Dockerfile          # Container image definition
├── start.sh           # Container startup script
├── fly.toml           # Fly.io configuration
├── .dockerignore      # Docker build ignore patterns
└── README.md          # This file
```

## 🏗️ Architecture

```
Browser (HTTPS)
    ↓
noVNC/websockify (0.0.0.0:6080)
    ↓
x11vnc (localhost:5900)
    ↓
Xfce4 Desktop
    ↓
Xvfb Virtual Display (:0)
```

## 📝 Notes

- The container runs all services as root (suitable for personal use)
- Xvfb creates a virtual display (no physical GPU required)
- noVNC provides the web-based VNC client
- websockify proxies WebSocket connections to VNC

## 🔄 Updates

To update the deployment after making changes:

**Docker**:
```bash
docker stop desktop && docker rm desktop
docker build -t novnc-desktop .
docker run -d -p 6080:6080 -e VNC_PASSWORD="MyPassword" --name desktop novnc-desktop
```

**Fly.io**:
```bash
fly deploy
```

## 📄 License

This project is provided as-is for educational and personal use.

## 🤝 Contributing

Feel free to customize and extend this project for your needs!
