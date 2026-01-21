# OpenCode Setup Package

A curated OpenCode configuration with ZSH enhancements and Vision MCP Manager for WSL2.

## Fresh Windows Install (WSL2 from scratch)

Run this in **PowerShell** (as Administrator):

```powershell
# One-liner: Download and run the Windows setup script
irm https://raw.githubusercontent.com/JRedeker/dot-files/trunk/windows-setup.ps1 | iex
```

Or step-by-step:
```powershell
# Download the script
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/JRedeker/dot-files/trunk/windows-setup.ps1" -OutFile "windows-setup.ps1"

# Run it
.\windows-setup.ps1
```

This will:
1. Install/enable WSL2
2. Install Ubuntu
3. Clone this repo and run the full installer
4. Set up ZSH, OpenCode, Vision, and all tools

## Quick Install (existing WSL2/Linux)

```bash
# Clone the repo
git clone https://github.com/JRedeker/dot-files.git
cd dot-files

# Run the installer
chmod +x install.sh
./install.sh

# Restart your shell
exec zsh

# Configure your prompt (first time)
p10k configure

# Start Vision MCP daemon
vision daemon start -d

# Generate OpenCode MCP config
vision init --global
```

## What's Included

### OpenCode Configuration
- **opencode.json** - Main config with model definitions and MCP server placeholders
- **rules.yaml** - Agent behavior rules (TDD, security, collaboration)
- **shell_strategy.md** - Non-interactive shell patterns for AI agents
- **identity.md** - Agent identity clarification
- **mcp-tools.md** - MCP tool selection guide
- **goost_instructions.md** - Contract-based task persistence
- **MORPH_INSTRUCTIONS.md** - Fast code editing with Morph AI

### Vision MCP Manager
[Vision](https://github.com/Sharper-Flow/Vision-MCP-Manager) is a Go-native daemon that centralizes MCP server management:
- Single YAML config for all MCP servers
- Automatic process supervision with restarts
- stdio-to-HTTP bridging on dedicated ports
- One command to generate client configs

### ZSH Enhancements
- Powerlevel10k theme
- zsh-autosuggestions (ghost text)
- fast-syntax-highlighting
- History optimization (500k entries)
- Useful aliases (`gs`, `ll`, `cds`, etc.)

### OpenCode Helpers
- `oc` - Launch opencode in tmux (crash isolation for WSL2)
- `oc-list` - List running opencode sessions
- `oc-killall` - Kill all opencode sessions
- `cds` - Create dated scratch folder and open opencode

## MCP Server Setup with Vision

Vision manages all your MCP servers from `~/.config/vision/servers.yaml`. The installer creates a default config with the time server enabled.

### Managing Servers

```bash
# Start the daemon (background)
vision daemon start -d

# Check daemon status
vision daemon status

# List servers
vision server list

# Add a new server
vision server add context7 --command npx --args "-y @upstash/context7-mcp@latest" --port 6276

# Generate OpenCode config
vision init --global
```

### Adding API Keys

Edit `~/.config/vision/env` to add your API keys:

```bash
CONTEXT7_API_KEY=ctx7_xxxxxxxxxxxx
KAGI_API_KEY=xxxxxxxxxxxxxxxx
FIRECRAWL_API_KEY=fc-xxxxxxxxxxxxxxxx
```

Then uncomment the corresponding servers in `~/.config/vision/servers.yaml`.

### Example servers.yaml

```yaml
servers:
  # Time - No API key required
  time:
    port: 6282
    command: uvx
    args: ["mcp-server-time", "--local-timezone=America/New_York"]
    autostart: true

  # Context7 - Library documentation
  context7:
    port: 6276
    command: npx
    args: ["-y", "@upstash/context7-mcp@latest"]
    env:
      CONTEXT7_API_KEY: "${CONTEXT7_API_KEY}"
    autostart: true

  # Kagi - Web search
  kagimcp:
    port: 6279
    command: uvx
    args: ["kagimcp"]
    env:
      KAGI_API_KEY: "${KAGI_API_KEY}"
    autostart: true
```

### Running Vision as a Service

For always-on operation:

```bash
# Install systemd user service
mkdir -p ~/.config/systemd/user
curl -fsSL https://raw.githubusercontent.com/Sharper-Flow/Vision-MCP-Manager/trunk/scripts/vision-user.service \
  -o ~/.config/systemd/user/vision.service
systemctl --user daemon-reload
systemctl --user enable --now vision

# Check status
systemctl --user status vision
```

## Optional: Morph API Key

For fast code editing with Morph AI, get an API key from morph.ai and add to your config:

```bash
# Edit ~/.config/opencode/zshrc-additions.sh
export MORPH_API_KEY="your-morph-api-key"
```

## File Locations After Install

```
~/.config/opencode/
  opencode.json        # Main config
  rules.yaml           # Agent rules
  shell_strategy.md    # Shell patterns
  identity.md          # Agent identity
  mcp-tools.md         # Tool selection
  goost_instructions.md
  MORPH_INSTRUCTIONS.md
  zshrc-additions.sh   # ZSH config

~/.config/vision/
  servers.yaml         # MCP server registry
  env                  # API keys (gitignored)

~/.zsh/plugins/
  powerlevel10k/
  zsh-autosuggestions/
  fast-syntax-highlighting/
```

## Troubleshooting

### OpenCode not found
```bash
export PATH=$HOME/.opencode/bin:$PATH
```

### Vision not found
```bash
# Reinstall Vision
curl -fsSL https://raw.githubusercontent.com/Sharper-Flow/Vision-MCP-Manager/trunk/scripts/install.sh | bash
```

### MCP servers not connecting
```bash
# Check Vision daemon status
vision daemon status

# Restart daemon
vision daemon stop
vision daemon start -d

# Check server logs
vision server info <server-name>
```

### ZSH plugins not loading
```bash
# Reinstall plugins
rm -rf ~/.zsh/plugins
./install.sh
```

### tmux sessions piling up
```bash
oc-killall
```

### Reset to defaults
```bash
rm -rf ~/.config/opencode ~/.config/vision
./install.sh
```
