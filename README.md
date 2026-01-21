# OpenCode Setup Package

A curated OpenCode configuration with ZSH enhancements and Vision MCP Manager for WSL2.

## Fresh Windows Install (WSL2 from scratch)

Run this in **PowerShell** (as Administrator):

```powershell
# Download and run the setup script
irm https://raw.githubusercontent.com/JRedeker/dot-files/trunk/windows-setup.ps1 -OutFile ws.ps1; .\ws.ps1
```

The script runs in two phases:

**Phase 1** - Installs WSL2 and Ubuntu:
- If WSL isn't installed, you'll need to restart and run again
- Ubuntu opens in a new window - create your username/password there
- Once done, close the Ubuntu window

**Phase 2** - Run after Ubuntu setup:
```powershell
.\ws.ps1 -Phase2
```

This installs everything inside Ubuntu (ZSH, OpenCode, Vision, etc.)

### What gets installed
1. WSL2 with Ubuntu
2. ZSH with Powerlevel10k, autosuggestions, syntax highlighting
3. OpenCode AI coding assistant
4. Vision MCP Manager
5. Node.js, tmux, and dev tools

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

## What is OpenCode?

[OpenCode](https://opencode.ai) is an open-source AI coding assistant CLI that brings powerful AI models directly to your terminal. Think of it as a local, customizable alternative to cloud-based coding assistants.

### Key Features
- **Multiple AI providers** - Use Claude, GPT, Gemini, and more
- **MCP Support** - Connect to Model Context Protocol servers for extended capabilities
- **Customizable** - Full control over prompts, rules, and behavior
- **Terminal-native** - Works entirely in your shell, no browser needed

### Manual OpenCode Installation

If you just want OpenCode without the full setup:

```bash
# Install OpenCode
curl -fsSL https://opencode.ai/install | bash

# Add to PATH (add this to your .bashrc or .zshrc)
export PATH=$HOME/.opencode/bin:$PATH

# Launch
opencode
```

### First Run

When you first launch OpenCode, you'll need to authenticate with an AI provider:

1. **Run `opencode`** - Opens the TUI interface
2. **Press `Ctrl+L`** - Open provider login
3. **Select a provider** - Choose Claude, OpenAI, Google, etc.
4. **Authenticate** - Follow the OAuth flow in your browser

### Basic Usage

```bash
# Start OpenCode in current directory
opencode

# Start with a specific prompt
opencode "explain this codebase"

# Start in a specific directory
opencode --cwd /path/to/project
```

### Keybindings (in OpenCode TUI)

| Key | Action |
|-----|--------|
| `Enter` | Send message |
| `Shift+Enter` | New line |
| `Ctrl+C` | Cancel current operation |
| `Ctrl+L` | Provider login |
| `Ctrl+K` | Clear conversation |
| `Ctrl+O` | Open file picker |
| `?` | Show help |

## What's Included in This Setup

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

## Using OpenCode After Setup

### Quick Start

```bash
# Launch OpenCode (wrapped in tmux for crash isolation)
oc

# Or create a scratch folder and launch
cds
```

### First Time Authentication

1. Launch with `oc`
2. Press `Ctrl+L` to open provider login
3. Select your AI provider (Claude, OpenAI, Google, etc.)
4. Complete OAuth in your browser
5. Return to terminal - you're ready to code!

### Example Workflows

```bash
# Start a new project
mkdir ~/dev/my-project && cd ~/dev/my-project
oc
# Then ask: "Initialize a new TypeScript project with ESLint and Prettier"

# Debug an issue
cd ~/dev/existing-project
oc
# Then ask: "Why is the login function failing? Check src/auth/"

# Quick scratch work
cds
# Creates ~/scratch/2025-01-21/ and opens OpenCode
# Great for experiments and one-off scripts
```

### Tips

- **Use `oc` instead of `opencode`** - It wraps in tmux, preventing WSL2 crashes from killing your session
- **Session recovery** - If your terminal crashes, run `oc-list` to see running sessions, then `tmux attach -t <session>`
- **Kill stuck sessions** - Run `oc-killall` to terminate all OpenCode tmux sessions

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
