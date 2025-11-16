#!/bin/bash
#
# ccr-regenerate-config.sh - Regenerate Claude Code Router config from source files
# Reads providers.json, routes.json, provider-templates.json, and .env
# Generates ~/.claude-code-router/config.json
#

set -e

# Directories
CCR_DIR="$HOME/.claude-code-router"
ENV_FILE="$HOME/.env"
TEMPLATES_FILE="$CCR_DIR/provider-templates.json"
PROVIDERS_FILE="$CCR_DIR/providers.json"
ROUTES_FILE="$CCR_DIR/routes.json"
CONFIG_FILE="$CCR_DIR/config.json"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "=== CCR Config Regeneration ==="
echo ""

# Check required files exist
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${RED}✗ Error: .env file not found at $ENV_FILE${NC}"
    exit 1
fi

if [ ! -f "$TEMPLATES_FILE" ]; then
    echo -e "${RED}✗ Error: provider-templates.json not found${NC}"
    exit 1
fi

if [ ! -f "$PROVIDERS_FILE" ]; then
    echo -e "${RED}✗ Error: providers.json not found${NC}"
    exit 1
fi

if [ ! -f "$ROUTES_FILE" ]; then
    echo -e "${RED}✗ Error: routes.json not found${NC}"
    exit 1
fi

# Load .env file
echo "Loading environment variables..."
set -a
source "$ENV_FILE"
set +a

# Backup existing config if it exists
if [ -f "$CONFIG_FILE" ]; then
    BACKUP_FILE="$CONFIG_FILE.backup.$(date +%Y%m%d-%H%M%S)"
    cp "$CONFIG_FILE" "$BACKUP_FILE"
    echo -e "${GREEN}✓ Backed up existing config to ${BACKUP_FILE}${NC}"
fi

# Start building config
echo "Generating configuration..."

# Read active providers list
ACTIVE_PROVIDERS=$(python3 -c "
import json
with open('$PROVIDERS_FILE', 'r') as f:
    data = json.load(f)
    print(' '.join(data.get('active_providers', [])))
")

if [ -z "$ACTIVE_PROVIDERS" ]; then
    echo -e "${RED}✗ Error: No active providers found in providers.json${NC}"
    exit 1
fi

echo "Active providers: ${BLUE}${ACTIVE_PROVIDERS}${NC}"

# Generate Providers array
TEMPLATES_FILE="$TEMPLATES_FILE" PROVIDERS_FILE="$PROVIDERS_FILE" ROUTES_FILE="$ROUTES_FILE" CONFIG_FILE="$CONFIG_FILE" python3 << 'PYTHON_SCRIPT'
import json
import os
import sys

# Load templates
with open(os.environ['TEMPLATES_FILE'], 'r') as f:
    templates = json.load(f)

# Load active providers
with open(os.environ['PROVIDERS_FILE'], 'r') as f:
    active_data = json.load(f)
    active_providers = active_data.get('active_providers', [])

# Load routes
with open(os.environ['ROUTES_FILE'], 'r') as f:
    routes = json.load(f)

# Build providers array
providers = []
for provider_name in active_providers:
    if provider_name not in templates:
        print(f"Warning: Provider '{provider_name}' not found in templates", file=sys.stderr)
        continue

    template = templates[provider_name]
    provider_config = {
        "name": provider_name
    }

    # Handle API base URL (may contain env vars)
    api_base_url = template.get('api_base_url', '')
    # Expand environment variables
    for key, value in os.environ.items():
        api_base_url = api_base_url.replace(f'${key}', value)
    provider_config['api_base_url'] = api_base_url

    # Handle API key
    if 'api_key' in template:
        # Direct API key (like "ollama" or "not-needed")
        provider_config['api_key'] = template['api_key']
    elif 'api_key_var' in template:
        # API key from environment variable
        api_key_var = template['api_key_var']
        api_key = os.environ.get(api_key_var, '')
        if api_key:
            provider_config['api_key'] = api_key
        else:
            print(f"Warning: API key variable '{api_key_var}' not set for provider '{provider_name}'", file=sys.stderr)
            provider_config['api_key'] = ''
    else:
        provider_config['api_key'] = ''

    # Add transformer if present
    if 'transformer' in template:
        provider_config['transformer'] = template['transformer']

    providers.append(provider_config)

# Build router config (remove description field)
router = {k: v for k, v in routes.items() if k != 'description'}

# Build final config
config = {
    "PORT": 3456,
    "LOG": True,
    "LOG_LEVEL": "info",
    "API_TIMEOUT_MS": 600000,
    "NON_INTERACTIVE_MODE": False,
    "Providers": providers,
    "Router": router
}

# Write config
with open(os.environ['CONFIG_FILE'], 'w') as f:
    json.dump(config, f, indent=2)

print("Configuration generated successfully")
PYTHON_SCRIPT

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Configuration generated: $CONFIG_FILE${NC}"
    echo ""

    # Show summary
    echo "Configuration Summary:"
    echo "  Providers: $ACTIVE_PROVIDERS"

    DEFAULT_ROUTE=$(python3 -c "
import json
with open('$ROUTES_FILE', 'r') as f:
    routes = json.load(f)
    print(routes.get('default', 'Not set'))
")
    echo "  Default route: ${BLUE}$DEFAULT_ROUTE${NC}"

    echo ""
    echo -e "${YELLOW}To apply changes, restart CCR:${NC}"
    echo "  systemctl restart ccr   # (systemd service)"
    echo "  ccr restart             # (alternative)"
else
    echo -e "${RED}✗ Error generating configuration${NC}"
    exit 1
fi
