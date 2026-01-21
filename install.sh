#!/bin/bash
# =============================================================================
# OpenCode Setup Installer for Fresh WSL2
# Run: chmod +x install.sh && ./install.sh
# =============================================================================

set -e  # Exit on error

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# 1. SYSTEM DEPENDENCIES
# =============================================================================
log_info "Updating package lists..."
sudo apt-get update -y

log_info "Installing essential packages..."
sudo apt-get install -y \
    git \
    curl \
    wget \
    zsh \
    tmux \
    fd-find \
    ripgrep \
    fzf \
    build-essential \
    jq

# fd is installed as fdfind on Ubuntu/Debian
if ! command -v fd &>/dev/null && command -v fdfind &>/dev/null; then
    log_info "Creating fd symlink..."
    sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
fi

# =============================================================================
# 2. NVM & NODE.JS
# =============================================================================
if [ ! -d "$HOME/.nvm" ]; then
    log_info "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
else
    log_info "NVM already installed"
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

log_info "Installing Node.js LTS..."
nvm install --lts
nvm use --lts

# =============================================================================
# 3. ZSH PLUGINS
# =============================================================================
log_info "Setting up ZSH plugins directory..."
mkdir -p ~/.zsh/plugins ~/.zsh/completions ~/.cache/zsh

# Powerlevel10k
if [ ! -d "$HOME/.zsh/plugins/powerlevel10k" ]; then
    log_info "Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.zsh/plugins/powerlevel10k
else
    log_info "Powerlevel10k already installed"
fi

# zsh-autosuggestions
if [ ! -d "$HOME/.zsh/plugins/zsh-autosuggestions" ]; then
    log_info "Installing zsh-autosuggestions..."
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/plugins/zsh-autosuggestions
else
    log_info "zsh-autosuggestions already installed"
fi

# fast-syntax-highlighting
if [ ! -d "$HOME/.zsh/plugins/fast-syntax-highlighting" ]; then
    log_info "Installing fast-syntax-highlighting..."
    git clone --depth=1 https://github.com/zdharma-continuum/fast-syntax-highlighting ~/.zsh/plugins/fast-syntax-highlighting
else
    log_info "fast-syntax-highlighting already installed"
fi

# =============================================================================
# 4. OPENCODE
# =============================================================================
if ! command -v opencode &>/dev/null; then
    log_info "Installing OpenCode..."
    curl -fsSL https://opencode.ai/install | bash
else
    log_info "OpenCode already installed"
fi

# =============================================================================
# 5. VISION MCP MANAGER
# =============================================================================
if ! command -v vision &>/dev/null; then
    log_info "Installing Vision MCP Manager..."
    curl -fsSL https://raw.githubusercontent.com/Sharper-Flow/Vision-MCP-Manager/trunk/scripts/install.sh | bash
else
    log_info "Vision MCP Manager already installed"
fi

# Create default Vision config directory
mkdir -p ~/.config/vision

# Copy Vision servers config if it doesn't exist
if [ ! -f ~/.config/vision/servers.yaml ]; then
    log_info "Creating default Vision servers.yaml..."
    cat > ~/.config/vision/servers.yaml << 'VISION_EOF'
# Vision MCP Server Registry
# See: https://github.com/Sharper-Flow/Vision-MCP-Manager

servers:
  # Time - Timezone and scheduling utilities (no API key required)
  time:
    port: 6282
    command: uvx
    args: ["mcp-server-time", "--local-timezone=America/New_York"]
    autostart: true

  # Context7 - Library documentation lookup (optional API key)
  # context7:
  #   port: 6276
  #   command: npx
  #   args: ["-y", "@upstash/context7-mcp@latest"]
  #   env:
  #     CONTEXT7_API_KEY: "${CONTEXT7_API_KEY}"
  #   autostart: true

  # Kagi - Web search and summarization (requires API key)
  # kagimcp:
  #   port: 6279
  #   command: uvx
  #   args: ["kagimcp"]
  #   env:
  #     KAGI_API_KEY: "${KAGI_API_KEY}"
  #   autostart: true

  # Firecrawl - Web scraping and extraction (requires API key)
  # firecrawl:
  #   port: 6281
  #   command: npx
  #   args: ["-y", "firecrawl-mcp"]
  #   env:
  #     FIRECRAWL_API_KEY: "${FIRECRAWL_API_KEY}"
  #   autostart: true
VISION_EOF
fi

# Create env file placeholder
if [ ! -f ~/.config/vision/env ]; then
    log_info "Creating Vision env file placeholder..."
    cat > ~/.config/vision/env << 'ENV_EOF'
# Vision MCP Manager - Environment Variables
# Add your API keys here (this file is gitignored)

# CONTEXT7_API_KEY=ctx7_xxxxxxxxxxxx
# KAGI_API_KEY=xxxxxxxxxxxxxxxx
# FIRECRAWL_API_KEY=fc-xxxxxxxxxxxxxxxx
ENV_EOF
fi

# =============================================================================
# 6. OPENCODE CONFIG
# =============================================================================
log_info "Setting up OpenCode configuration..."
mkdir -p ~/.config/opencode

# Copy config files
cp -v "$SCRIPT_DIR/config/opencode/"* ~/.config/opencode/

log_info "OpenCode config installed to ~/.config/opencode/"

# =============================================================================
# 7. ZSHRC SETUP
# =============================================================================
ZSHRC_MARKER="# >>> opencode-setup >>>"
if ! grep -q "$ZSHRC_MARKER" ~/.zshrc 2>/dev/null; then
    log_info "Adding opencode configuration to .zshrc..."
    
    # Backup existing .zshrc
    if [ -f ~/.zshrc ]; then
        cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d%H%M%S)
        log_info "Backed up existing .zshrc"
    fi
    
    cat >> ~/.zshrc << 'ZSHRC_EOF'

# >>> opencode-setup >>>
# Source the opencode zsh additions
if [ -f ~/.config/opencode/zshrc-additions.sh ]; then
    source ~/.config/opencode/zshrc-additions.sh
fi
# <<< opencode-setup <<<
ZSHRC_EOF
    
    # Also copy the additions file
    cp "$SCRIPT_DIR/zshrc-additions.sh" ~/.config/opencode/
    log_info "ZSH configuration added"
else
    log_warn ".zshrc already contains opencode-setup marker, skipping"
fi

# =============================================================================
# 8. SET DEFAULT SHELL
# =============================================================================
if [ "$SHELL" != "$(which zsh)" ]; then
    log_info "Setting ZSH as default shell..."
    chsh -s "$(which zsh)"
    log_warn "Shell changed to ZSH. Log out and back in to use it."
else
    log_info "ZSH is already the default shell"
fi

# =============================================================================
# 9. SCRATCH DIRECTORY
# =============================================================================
log_info "Creating scratch directory..."
mkdir -p ~/scratch ~/dev

# =============================================================================
# DONE
# =============================================================================
echo ""
echo "=============================================="
echo -e "${GREEN}Installation Complete!${NC}"
echo "=============================================="
echo ""
echo "Next steps:"
echo "  1. Log out and back in (or run: exec zsh)"
echo "  2. Run 'p10k configure' to set up your prompt theme"
echo "  3. Start Vision daemon: vision daemon start -d"
echo "  4. Generate OpenCode MCP config: vision init --global"
echo "  5. (Optional) Add API keys to ~/.config/vision/env"
echo ""
echo "Quick start:"
echo "  - Type 'oc' to launch opencode (wrapped in tmux)"
echo "  - Type 'cds' to create a dated scratch folder and open opencode"
echo "  - Type 'vision server list' to see MCP servers"
echo ""
