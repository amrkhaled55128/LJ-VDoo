# Kali Linux Desktop - Docker Container

Complete Kali Linux desktop environment with remote access via noVNC (browser) and RDP, deployable on Fly.io or any Docker platform.

## 🎯 Features

- **Kali Linux**: Full Kali Rolling with Xfce desktop
- **Security Tools**: Pre-installed Kali top 10 tools
- **Browser Access**: noVNC web interface (no VNC client needed)
- **RDP Access**: Connect via Remote Desktop Protocol
- **Cloud-Ready**: One-command deployment to Fly.io
- **Persistent Storage**: Data survives restarts

## 📋 Prerequisites

- **Docker**: For local testing
- **Fly.io CLI** (optional): For cloud deployment

## 🚀 Quick Start

### Local Testing with Docker

1. **Build the image**:
   ```bash
   docker build -t kali-desktop .
   ```

2. **Run the container**:
   ```bash
   docker run -d -p 6080:6080 -p 3389:3389 --name kali kali-desktop
   ```

3. **Access the desktop**:
   - **Browser (noVNC)**: http://localhost:6080
   - **RDP Client**: localhost:3389
     - Username: `root`
     - Password: `kali`

4. **View logs**:
   ```bash
   docker logs kali
   ```

5. **Stop and cleanup**:
   ```bash
   docker stop kali && docker rm kali
   ```

### Deploy to Fly.io

1. **Install Fly CLI**:
   ```bash
   # Windows (PowerShell)
   iwr https://fly.io/install.ps1 -useb | iex
   ```

2. **Login to Fly.io**:
   ```bash
   fly auth login
   ```

3. **Create persistent volume** (20GB recommended):
   ```bash
   fly volumes create kali_data --size 20 --region iad
   ```

4. **Launch and deploy**:
   ```bash
   fly launch --no-deploy
   fly deploy
   ```

5. **Get access URLs**:
   ```bash
   fly status
   fly ips list
   ```

6. **Access your Kali desktop**:
   - **Browser**: `https://your-app-name.fly.dev`
   - **RDP**: Use the IPv4 address from `fly ips list` on port 3389

## 🔐 Security & Credentials

**Default Credentials:**
- Username: `root`
- Password: `kali`

**Important:**
- Change the root password after first login: `passwd`
- The VNC interface has no password (only accessible via noVNC proxy)
- RDP is password-protected

## 🛠️ Pre-installed Tools

Kali includes these security tools:
- Nmap (network scanner)
- Metasploit Framework
- Burp Suite
- Wireshark
- Aircrack-ng
- John the Ripper
- Hydra
- SQLMap
- Nikto
- And many more...

Install additional tools:
```bash
apt update
apt install kali-linux-large  # More tools
apt install <tool-name>        # Specific tool
```

## ⚙️ Customization

### Change Screen Resolution

Edit `start.sh`, line 33:
```bash
Xvfb :0 -screen 0 1920x1080x24 &  # Change from 1280x720
```

### Increase Storage

**For Kali Linux Large, recommended minimum: 50GB**

#### Create New Volume (First Time)
```bash
fly volumes create kali_data --size 50 --region iad
```

#### Extend Existing Volume
If you already created a smaller volume and want to increase it:
```bash
# List your volumes to get the volume ID
fly volumes list

# Extend the volume (change vol_xxx to your actual volume ID)
fly volumes extend vol_xxx --size 50
```

**Note:** You can only **increase** volume size, not decrease it. The app will automatically use the new space after extending.

### Increase RAM/CPU

Edit `fly.toml` to add VM configuration:
```toml
[[vm]]
  cpu_kind = "shared"
  cpus = 2
  memory_mb = 4096
```

## 🔧 Troubleshooting

### Desktop doesn't load
- Wait 15-20 seconds for full startup
- Check logs: `docker logs kali` or `fly logs`

### RDP connection refused
- Ensure port 3389 is properly exposed
- For Fly.io, verify the TCP service is configured
- Check firewall settings

### Can't install tools
- Update package list: `apt update`
- Kali repos may require: `apt install kali-archive-keyring`

## 📁 Project Structure

```
.
├── Dockerfile          # Kali Linux image definition
├── start.sh           # Container startup script
├── fly.toml           # Fly.io configuration
├── .dockerignore      # Docker build ignore patterns
└── README.md          # This file
```

## 🏗️ Architecture

```
Browser/RDP Client
    ↓
noVNC (6080) / xrdp (3389)
    ↓
x11vnc (localhost:5900)
    ↓
Xfce Desktop
    ↓
Xvfb Virtual Display (:0)
    ↓
Kali Linux Rolling
```

## 📝 Notes

- Kali is designed for security professionals and ethical hackers
- Use responsibly and legally
- Large image size (~2-3GB) - first build takes time
- Tools require configuration before use

## ⚠️ Legal Disclaimer

This container includes penetration testing tools. Use only on systems you own or have explicit permission to test. Unauthorized access to computer systems is illegal.

## 🔄 Updates

**Docker**:
```bash
docker stop kali && docker rm kali
docker build -t kali-desktop .
docker run -d -p 6080:6080 -p 3389:3389 --name kali kali-desktop
```

**Fly.io**:
```bash
fly deploy
```

## 📄 License

Based on official Kali Linux Docker image. Use at your own risk.
