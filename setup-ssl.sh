#!/bin/bash
#
# CCG Site - SSL Setup Script (Caddy)
# Usage: bash setup-ssl.sh yourdomain.com
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check for domain argument
if [ -z "$1" ]; then
  echo -e "${RED}Usage: bash setup-ssl.sh yourdomain.com${NC}"
  exit 1
fi

DOMAIN="$1"

echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════╗"
echo "║       CCG Site SSL Setup (Caddy)          ║"
echo "╚═══════════════════════════════════════════╝"
echo -e "${NC}"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run as root (use sudo)${NC}"
  exit 1
fi

# Install Caddy
echo -e "${YELLOW}[1/3] Installing Caddy...${NC}"
apt-get update -qq
apt-get install -y -qq debian-keyring debian-archive-keyring apt-transport-https curl

curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg 2>/dev/null || true
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list >/dev/null

apt-get update -qq
apt-get install -y -qq caddy
echo -e "${GREEN}Caddy installed${NC}"

# Stop container on port 80, restart on different port
echo -e "${YELLOW}[2/3] Reconfiguring container...${NC}"
docker stop ccg-site 2>/dev/null || true
docker rm ccg-site 2>/dev/null || true

docker run -d \
  -p 127.0.0.1:3000:3000 \
  --name ccg-site \
  --restart unless-stopped \
  ccg-site

echo -e "${GREEN}Container reconfigured${NC}"

# Configure Caddy
echo -e "${YELLOW}[3/3] Configuring Caddy for ${DOMAIN}...${NC}"
cat > /etc/caddy/Caddyfile << EOF
${DOMAIN} {
    reverse_proxy localhost:3000

    header {
        # Security headers
        X-Content-Type-Options nosniff
        X-Frame-Options DENY
        Referrer-Policy strict-origin-when-cross-origin
    }

    # Gzip compression
    encode gzip
}

# Redirect www to non-www
www.${DOMAIN} {
    redir https://${DOMAIN}{uri} permanent
}
EOF

# Restart Caddy
systemctl restart caddy
systemctl enable caddy

echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════╗"
echo "║           SSL Setup Complete!             ║"
echo "╚═══════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo "Your site is now available at: https://${DOMAIN}"
echo ""
echo "Caddy will automatically obtain and renew SSL certificates."
echo ""
echo "Useful commands:"
echo "  - Check Caddy status:  systemctl status caddy"
echo "  - View Caddy logs:     journalctl -u caddy -f"
echo "  - Reload config:       systemctl reload caddy"
echo ""
