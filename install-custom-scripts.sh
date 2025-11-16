#!/bin/bash
#
# install-custom-scripts.sh - Install custom CCR management scripts
#
# This script installs the custom CCR scripts and configurations
# for enhanced model management and DashScope integration.
#

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
echo -e "${CYAN}  CCR Custom Scripts Installation${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "${YELLOW}Note: Not running as root. Installing to user scripts directory.${NC}"
  SCRIPTS_DIR="$HOME/scripts"
  CONFIG_DIR="$HOME/.claude-code-router"
else
  SCRIPTS_DIR="/root/scripts"
  CONFIG_DIR="/root/.claude-code-router"
fi

echo "Installation directories:"
echo "  Scripts: $SCRIPTS_DIR"
echo "  Config:  $CONFIG_DIR"
echo ""

# Create directories
mkdir -p "$SCRIPTS_DIR"
mkdir -p "$CONFIG_DIR"

# Install scripts
echo -e "${YELLOW}Installing custom scripts...${NC}"
for script in custom-scripts/*; do
  if [ -f "$script" ] && [ "$script" != "custom-scripts/.gitignore" ]; then
    cp -v "$script" "$SCRIPTS_DIR/"
    chmod +x "$SCRIPTS_DIR/$(basename $script)"
  fi
done

echo ""
echo -e "${YELLOW}Installing configuration templates...${NC}"

# Copy provider templates (only if doesn't exist or user confirms)
if [ -f "$CONFIG_DIR/provider-templates.json" ]; then
  echo -e "${YELLOW}provider-templates.json already exists.${NC}"
  read -p "Overwrite? [y/N]: " overwrite
  if [[ "$overwrite" == "y" ]] || [[ "$overwrite" == "Y" ]]; then
    cp -v custom-configs/provider-templates.json "$CONFIG_DIR/"
  else
    echo "  Skipped provider-templates.json"
  fi
else
  cp -v custom-configs/provider-templates.json "$CONFIG_DIR/"
fi

# Copy routes as example (don't overwrite existing)
if [ -f "$CONFIG_DIR/routes.json" ]; then
  echo "  routes.json already exists (keeping your configuration)"
  cp -v custom-configs/routes.json "$CONFIG_DIR/routes.json.example"
  echo "  Installed as routes.json.example for reference"
else
  cp -v custom-configs/routes.json "$CONFIG_DIR/"
fi

echo ""
echo -e "${GREEN}✓ Installation complete!${NC}"
echo ""
echo -e "${CYAN}Next steps:${NC}"
echo "  1. Add your DashScope API key to /root/.env:"
echo "     echo 'DASHSCOPE_API_KEY=sk-your-key-here' >> /root/.env"
echo ""
echo "  2. Run smart config to set up models:"
echo "     $SCRIPTS_DIR/ccr-smart-config"
echo ""
echo "  3. Test the installation:"
echo "     ccr-model-helper"
echo ""
echo -e "${YELLOW}Installed scripts:${NC}"
ls -1 "$SCRIPTS_DIR"/ccr-* | while read -r file; do
  echo "  • $(basename $file)"
done
echo ""
