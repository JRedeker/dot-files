# OpenCode Setup Package

A curated OpenCode configuration with ZSH enhancements for WSL2.

## Quick Install

```bash
# Extract the package
tar -xzf opencode-setup.tar.gz
cd opencode-setup

# Run the installer
chmod +x install.sh
./install.sh

# Restart your shell
exec zsh

# Configure your prompt (first time)
p10k configure
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

## Optional: MCP Server Setup

The config includes MCP server definitions (disabled by default). To enable them:

### Context7 (Library Documentation)
```bash
npx @anthropic/context7-mcp --port 6276
```
Then set `"enabled": true` in opencode.json for context7.

### Kagi Search (requires API key)
```bash
# Get API key from https://kagi.com/settings?p=api
export KAGI_API_KEY="your-key"
npx @anthropic/kagi-mcp --port 6279
```

### arXiv (Academic Papers)
```bash
npx @anthropic/arxiv-mcp --port 6280
```

### Firecrawl (Web Scraping - requires API key)
```bash
# Get API key from https://firecrawl.dev
export FIRECRAWL_API_KEY="your-key"
npx @anthropic/firecrawl-mcp --port 6281
```

### Time Server
```bash
npx @anthropic/time-mcp --port 6282
```

### Fetch MCP (Simple URL fetching)
```bash
npx @anthropic/fetch-mcp --port 6283
```

### Running MCP Servers Persistently

For persistent MCP servers, consider using PM2:

```bash
npm install -g pm2

# Start servers
pm2 start "npx @anthropic/context7-mcp --port 6276" --name context7
pm2 start "npx @anthropic/time-mcp --port 6282" --name time-mcp

# Save configuration
pm2 save

# Auto-start on boot
pm2 startup
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
rm -rf ~/.config/opencode
./install.sh
```
