#!/bin/bash
set -e

# colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
NC="\033[0m"

echo -e "${YELLOW}Updating system and installing dependencies...${NC}"
sudo apt update
sudo apt install -y xfce4 xfce4-goodies dbus-x11 x11-xserver-utils wget unzip python3 python3-pip tightvncserver novnc python3-websockify

# setup VNC xstartup
echo -e "${YELLOW}Setting up VNC xstartup...${NC}"
mkdir -p ~/.vnc
cat <<EOL > ~/.vnc/xstartup
#!/bin/sh
xrdb \$HOME/.Xresources
startxfce4 &
EOL
chmod +x ~/.vnc/xstartup

# kill old VNC sessions if any
vncserver -kill :1 >/dev/null 2>&1 || true

# start VNC server
echo -e "${YELLOW}Starting VNC server...${NC}"
vncserver :1 -geometry 1920x1080 -depth 24

# setup noVNC certificate
echo -e "${YELLOW}Generating SSL certificate for noVNC...${NC}"
CERT_FILE="$HOME/.vnc/novnc.pem"
if [ ! -f "$CERT_FILE" ]; then
    openssl req -x509 -nodes -newkey rsa:3072 -keyout $CERT_FILE -out $CERT_FILE -days 3650 -subj "/C=US/ST=State/L=City/O=Org/OU=Dev/CN=localhost"
fi

# setup portable chromium
echo -e "${YELLOW}Downloading portable Chromium...${NC}"
mkdir -p ~/chrome && cd ~/chrome
wget -q https://commondatastorage.googleapis.com/chromium-browser-snapshots/Linux_x64/120000/chrome-linux.zip
unzip -qq chrome-linux.zip

echo -e "${GREEN}Setup complete!${NC}"
echo -e "${GREEN}Use start.sh to launch VNC + noVNC + Chromium.${NC}"
