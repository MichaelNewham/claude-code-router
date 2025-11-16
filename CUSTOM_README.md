# Claude Code Router - Custom Extensions

> **Fork Maintained By:** Michael Newham
> **Upstream:** [musistudio/claude-code-router](https://github.com/musistudio/claude-code-router)
> **Purpose:** Enhanced CCR with DashScope/Qwen integration and management utilities

---

## 🎯 Custom Features

This fork extends the official Claude Code Router with:

### 1. **DashScope (Alibaba Qwen) Integration**
- Full support for Qwen cloud models (qwen-turbo, qwen-plus, qwen-max, qwen-coder, qwen-vl)
- International endpoint support (`dashscope-intl.aliyuncs.com`)
- 62+ Qwen models accessible via API
- Cost-effective cloud inference ($0.30-2.50 per 1M tokens)

### 2. **Enhanced Management Scripts**

Located in [`custom-scripts/`](custom-scripts/):

#### **ccr-smart-config** (12KB)
Smart configuration tool with:
- Auto-discovery of local GGUF, Ollama cloud, and DashScope models
- Auto-pull of Ollama cloud models (no manual setup needed)
- Intelligent task-type labeling (💬 default, 💻 coding, 🧠 thinking, 👁️ image, 📚 longContext, ⚡ background)
- DashScope pricing display (~$0.30/1M to ~$2.50/1M)
- Quick setup with recommended models
- SSH-friendly exit handling (q to quit, CTRL+D support)

**Usage:**
```bash
/root/scripts/ccr-smart-config
```

**Features:**
- Discovers 6 local GGUF + 10 Ollama cloud + 11 DashScope models
- Auto-pulls unpulled Ollama models
- Shows capability icons for each model
- Displays pricing for DashScope models
- One-command configuration

#### **ccr-model-helper** (3KB)
SSH-friendly wrapper for `ccr model`:
- Safer exit handling for remote connections
- View-only mode for quick config checks
- Manual JSON editing option
- Emergency exit instructions

**Usage:**
```bash
/root/scripts/ccr-model-helper
```

**Why?** Solves CTRL+C issues over SSH tunnels (Cloudflare/Git Bash)

#### **ccr-list-models.sh** (2.1KB)
Comprehensive model listing from all sources:
- Local GGUF models (llama.cpp)
- Ollama cloud models
- Active cloud providers (DashScope, etc.)

#### **ccr-regenerate-config.sh** (5KB)
Automated configuration regeneration:
- Loads environment variables from `/root/.env`
- Expands provider templates with actual API keys
- Generates final `config.json`
- Backs up existing configuration

#### **ccr-service.sh** (1.4KB)
Simple service management wrapper.

### 3. **Provider Templates**

Enhanced [`provider-templates.json`](custom-configs/provider-templates.json):
- DashScope with international endpoint
- Pre-configured for 65536 max tokens
- Enhanced tool support transformers

### 4. **Example Routing Configuration**

See [`routes.json.example`](custom-configs/routes.json.example) for recommended setup:
- Default: DashScope qwen-plus (balanced)
- Coding: DashScope qwen3-coder-plus (advanced)
- Thinking: Ollama deepseek-v3.1:671b-cloud (free, best reasoning)
- Image: DashScope qwen3-vl-plus (vision)
- Background: Local GGUF (fast, no cost)

---

## 📦 Installation

### Prerequisites
- Existing CCR installation from upstream
- API keys for cloud providers (stored in `/root/.env`)

### Setup Custom Scripts

```bash
# Clone this fork
git clone https://github.com/YourUsername/claude-code-router.git
cd claude-code-router

# Install custom scripts
cp custom-scripts/* /root/scripts/
chmod +x /root/scripts/ccr-*

# Copy configuration templates
mkdir -p ~/.claude-code-router
cp custom-configs/provider-templates.json ~/.claude-code-router/
cp custom-configs/routes.json.example ~/.claude-code-router/routes.json

# Add DashScope API key to .env
echo "DASHSCOPE_API_KEY=sk-your-key-here" >> /root/.env

# Run smart config to set up models
/root/scripts/ccr-smart-config
```

---

## 🔄 Maintaining Fork with Upstream Updates

### Sync from Upstream

```bash
# Add upstream if not already added
git remote add upstream https://github.com/musistudio/claude-code-router.git

# Fetch latest from upstream
git fetch upstream

# Merge upstream changes into main
git checkout main
git merge upstream/main

# Update your custom branch
git checkout custom-scripts
git rebase main
```

### Keep Custom Scripts Separate

```
.
├── custom-scripts/          # Your custom management scripts
├── custom-configs/          # Your configuration templates
├── CUSTOM_README.md         # This file
└── (upstream files)         # Original CCR codebase
```

**Philosophy:** Keep customizations isolated so upstream updates don't conflict.

---

## 🌟 Recommended Model Routing

Based on testing with Proxmox VE + Container 100 (AMD Radeon 780M):

| Task Type | Provider | Model | Cost | Why |
|-----------|----------|-------|------|-----|
| **default** | DashScope | qwen-plus | $0.60/1M | Balanced quality/cost |
| **background** | Local | gpt-oss-20b | Free | Fast, no latency |
| **coding** | DashScope | qwen3-coder-plus | $0.60/1M | Best coding quality |
| **thinking** | Ollama Cloud | deepseek-v3.1:671b | Free | Superior reasoning |
| **longContext** | DashScope | qwen3-coder-plus | $0.60/1M | 128k+ context |
| **image** | DashScope | qwen3-vl-plus | $1.00/1M | Advanced vision |

**Total models available:** 27+ (6 local GGUF + 10 Ollama cloud + 11 DashScope)

---

## 🛠️ Configuration Files

### Provider Templates
[`custom-configs/provider-templates.json`](custom-configs/provider-templates.json)

Key additions:
- **DashScope** with international endpoint
- Pre-configured transformers for tool enhancement
- 65536 max token support

### Routes Configuration
[`custom-configs/routes.json.example`](custom-configs/routes.json.example)

Smart routing based on task detection.

### Environment Variables
Required in `/root/.env`:
```bash
DASHSCOPE_API_KEY=sk-your-key-here
LLM_INFERENCE_LLAMACPP_URL=http://192.168.1.205:8080/v1
LLM_INFERENCE_OLLAMA_URL=http://192.168.1.205:11434/v1
```

---

## 🐛 Known Issues & Solutions

### 1. **SSH CTRL+C Kills Tunnel**
**Problem:** CTRL+C in Git Bash over Cloudflare tunnel disconnects entire session.

**Solutions:**
- Use `ccr-model-helper` instead of `ccr model`
- Press CTRL+D (EOF) instead of CTRL+C
- Type 'q' to quit in interactive prompts
- Use tmux for persistent sessions

### 2. **Ollama Cloud Models Not Showing**
**Problem:** `ccr-smart-config` shows 0 Ollama cloud models.

**Solution:** Script now auto-pulls models. Just run `ccr-smart-config` again.

### 3. **DashScope API Key Invalid**
**Problem:** Beijing endpoint rejects international API keys.

**Solution:** This fork uses international endpoint (`dashscope-intl.aliyuncs.com`).

---

## 📚 Documentation

- **Original README:** See [README.md](README.md) for core CCR features
- **DashScope Integration:** [/root/docs/llm-inference/](../../docs/llm-inference/)
- **LLM Scripts:** [llm-scripts repository](https://github.com/YourUsername/llm-scripts)

---

## 🤝 Contributing

This is a personal fork for custom infrastructure. For contributions to the core CCR:
- Submit PRs to [musistudio/claude-code-router](https://github.com/musistudio/claude-code-router)

For DashScope integration or custom scripts:
- Submit PRs to this fork

---

## 📝 Changelog

### v1.0.0-custom (2025-11-16)
- ✨ Added DashScope (Alibaba Qwen) provider support
- ✨ Created ccr-smart-config with auto-discovery
- ✨ Added intelligent task-type labeling
- ✨ Created ccr-model-helper for SSH-friendly management
- ✨ Added pricing display for DashScope models
- ✨ Auto-pull Ollama cloud models
- 🐛 Fixed SSH tunnel exit issues
- 📚 Enhanced documentation

---

## 📄 License

Same as upstream: [LICENSE](LICENSE)

Core CCR by [musistudio](https://github.com/musistudio)
Custom extensions by Michael Newham

---

## 🔗 Links

- **Upstream:** [musistudio/claude-code-router](https://github.com/musistudio/claude-code-router)
- **Discord:** [Join CCR Community](https://discord.gg/rdftVMaUcS)
- **DashScope:** [Alibaba Cloud Model Studio](https://dashscope.aliyun.com)
- **Related:** [llm-scripts](https://github.com/YourUsername/llm-scripts) | [llm-browser-extension](https://github.com/YourUsername/llm-browser-extension)
