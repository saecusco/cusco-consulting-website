#!/bin/bash
#
# CCG Site - Update Script
# Run this on your VPS after pushing changes to GitHub
# Usage: bash /opt/ccg-site/update.sh
#

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

APP_DIR="/opt/ccg-site"
CONTAINER_NAME="ccg-site"
IMAGE_NAME="ccg-site"

echo -e "${YELLOW}Updating CCG Site...${NC}"

cd "$APP_DIR"

# Pull latest changes
echo "Pulling latest code..."
git pull origin main

# Rebuild and restart
echo "Rebuilding Docker image..."
docker build -t "$IMAGE_NAME" .

echo "Restarting container..."
docker stop "$CONTAINER_NAME" 2>/dev/null || true
docker rm "$CONTAINER_NAME" 2>/dev/null || true

# Check if Caddy is running (SSL mode)
if systemctl is-active --quiet caddy; then
  # SSL mode - bind to localhost only
  docker run -d \
    -p 127.0.0.1:3000:3000 \
    --name "$CONTAINER_NAME" \
    --restart unless-stopped \
    "$IMAGE_NAME"
else
  # Direct mode - bind to all interfaces
  docker run -d \
    -p 80:3000 \
    --name "$CONTAINER_NAME" \
    --restart unless-stopped \
    "$IMAGE_NAME"
fi

echo -e "${GREEN}Update complete!${NC}"
docker ps | grep "$CONTAINER_NAME"
