#!/bin/bash
#
# CCG Site - Hostinger VPS Deployment Script
# Usage: curl -fsSL https://raw.githubusercontent.com/saecusco/cusco-consulting-website/main/deploy.sh | bash
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════╗"
echo "║       CCG Site Deployment Script          ║"
echo "╚═══════════════════════════════════════════╝"
echo -e "${NC}"

# Configuration
REPO_URL="https://github.com/saecusco/cusco-consulting-website.git"
APP_DIR="/opt/ccg-site"
CONTAINER_NAME="ccg-site"
IMAGE_NAME="ccg-site"
PORT="3000"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run as root (use sudo)${NC}"
  exit 1
fi

# Function to check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Install Docker if not present
echo -e "${YELLOW}[1/5] Checking Docker...${NC}"
if ! command_exists docker; then
  echo "Installing Docker..."
  curl -fsSL https://get.docker.com | sh
  systemctl enable docker
  systemctl start docker
  echo -e "${GREEN}Docker installed successfully${NC}"
else
  echo -e "${GREEN}Docker already installed${NC}"
fi

# Clone or update repository
echo -e "${YELLOW}[2/5] Setting up repository...${NC}"
if [ -d "$APP_DIR" ]; then
  echo "Updating existing repository..."
  cd "$APP_DIR"
  git pull origin main
else
  echo "Cloning repository..."
  git clone "$REPO_URL" "$APP_DIR"
  cd "$APP_DIR"
fi
echo -e "${GREEN}Repository ready${NC}"

# Stop and remove existing container if running
echo -e "${YELLOW}[3/5] Cleaning up old containers...${NC}"
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  docker stop "$CONTAINER_NAME" 2>/dev/null || true
  docker rm "$CONTAINER_NAME" 2>/dev/null || true
  echo -e "${GREEN}Old container removed${NC}"
else
  echo "No existing container found"
fi

# Build Docker image
echo -e "${YELLOW}[4/5] Building Docker image...${NC}"
docker build -t "$IMAGE_NAME" .
echo -e "${GREEN}Image built successfully${NC}"

# Run container
echo -e "${YELLOW}[5/5] Starting container...${NC}"
docker run -d \
  -p 80:$PORT \
  --name "$CONTAINER_NAME" \
  --restart unless-stopped \
  "$IMAGE_NAME"

echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════╗"
echo "║         Deployment Complete!              ║"
echo "╚═══════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo "Your site is now running at: http://$(curl -s ifconfig.me)"
echo ""
echo "Next steps:"
echo "  1. Point your domain's A record to this server's IP"
echo "  2. Run: bash /opt/ccg-site/setup-ssl.sh yourdomain.com"
echo ""
