#!/bin/bash
set -e

# colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
NC="\033[0m"

DISPLAY_NUM=":1"
VNC_PORT="5901"
NOVNC_PORT="6080"
CERT_FILE="$HOME/.vnc/novnc.pem"
CHROME_DIR="$HOME/chrome/chrome-linux"

# kill old VNC sessions if any
echo -e "${YELLOW}Killing old VNC sessions...${NC}"
vncserver -kill $DISPLAY_NUM >/dev/null 2>&1 || true

# start VNC server
echo -e "${YELLOW}Starting VNC server...${NC}"
vncserver $DISPLAY_NUM -geometry 1920x1080 -depth 24

# start noVNC
echo -e "${YELLOW}Starting noVNC server on port $NOVNC_PORT...${NC}"
websockify -D --web=/usr/share/novnc/ --cert=$CERT_FILE $NOVNC_PORT localhost:$VNC_PORT

# launch Chromium in background
if [ -d "$CHROME_DIR" ]; then
    echo -e "${YELLOW}Launching Chromium...${NC}"
    export DISPLAY=$DISPLAY_NUM
    $CHROME_DIR/chrome --no-sandbox &
else
    echo -e "${RED}Chromium not found in $CHROME_DIR${NC}"
fi

echo -e "${GREEN}VNC + noVNC + Chromium started!${NC}"
echo -e "${GREEN}Open your browser to the exposed port $NOVNC_PORT to see the desktop.${NC}"
