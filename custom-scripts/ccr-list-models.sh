#!/bin/bash
#
# ccr-list-models.sh - Dynamically discover available models from all sources
# Queries llama.cpp, Ollama, and any configured cloud providers
#

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

echo "=== Available LLM Models ==="
echo ""

# Local GGUF Models (llama.cpp)
echo -e "${GREEN}LOCAL GGUF MODELS (llama.cpp)${NC}"
echo "Provider: llamacpp-local"
echo ""

if /root/scripts/llm-list-models 2>/dev/null; then
    :
else
    echo "  (Unable to query local models)"
fi

echo ""

# Cloud Models (Ollama)
echo -e "${CYAN}CLOUD MODELS (Ollama)${NC}"
echo "Provider: ollama-local"
echo ""

if /root/scripts/llm-cloud-catalog 2>/dev/null; then
    :
else
    echo "  (Unable to query cloud models)"
fi

echo ""

# Check for additional active providers
echo -e "${MAGENTA}CONFIGURED PROVIDERS${NC}"
echo ""

python3 << 'PYTHON_SCRIPT'
import json
import os
import sys

try:
    providers_file = os.path.expanduser('~/.claude-code-router/providers.json')
    with open(providers_file, 'r') as f:
        data = json.load(f)
        active = data.get('active_providers', [])

    # Filter out local providers (already shown above)
    cloud_providers = [p for p in active if not p.endswith('-local')]

    if cloud_providers:
        print("Additional cloud providers:")
        for provider in cloud_providers:
            print(f"  • {provider}")
        print("\nNote: To see models from these providers, they must have valid API keys")
        print("configured in /root/.env")
    else:
        print("No additional cloud providers configured")
        print("\nAdd providers with:")
        print("  /llm-add-provider <provider-name> <api-key>")
        print("\nAvailable providers:")
        print("  ccr-manage-provider.sh list")

except Exception as e:
    print(f"Error reading providers: {e}", file=sys.stderr)
PYTHON_SCRIPT

echo ""
echo -e "${YELLOW}Configuration:${NC}"
echo "  Regular 'claude': /llm list  # Informational only"
echo "  CCR routing: ccr-smart-config # Configure task-based routing"
