# =============================================================================
# WSL2 Ubuntu Setup Script for Windows
# Run this in PowerShell (Admin recommended)
# =============================================================================

param(
    [string]$DistroName = "Ubuntu-Dev",
    [switch]$SkipWSLInstall
)

$ErrorActionPreference = "Stop"

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  WSL2 Ubuntu + OpenCode Setup" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# 1. Check/Install WSL
# =============================================================================
if (-not $SkipWSLInstall) {
    Write-Host "[1/4] Checking WSL installation..." -ForegroundColor Yellow
    
    $wslInstalled = Get-Command wsl -ErrorAction SilentlyContinue
    if (-not $wslInstalled) {
        Write-Host "Installing WSL..." -ForegroundColor Green
        wsl --install --no-distribution
        Write-Host ""
        Write-Host "WSL installed. Please RESTART your computer and run this script again." -ForegroundColor Red
        Write-Host "Run: .\windows-setup.ps1 -SkipWSLInstall" -ForegroundColor Yellow
        exit 0
    }
    
    # Ensure WSL2 is the default
    wsl --set-default-version 2
    Write-Host "WSL2 is ready" -ForegroundColor Green
}

# =============================================================================
# 2. Install Ubuntu
# =============================================================================
Write-Host ""
Write-Host "[2/4] Setting up Ubuntu..." -ForegroundColor Yellow

# Check if Ubuntu is already installed
$existingDistros = wsl --list --quiet 2>$null
if ($existingDistros -match "Ubuntu") {
    Write-Host "Ubuntu is already installed" -ForegroundColor Green
    $ubuntuDistro = ($existingDistros | Where-Object { $_ -match "Ubuntu" } | Select-Object -First 1).Trim()
} else {
    Write-Host "Installing Ubuntu (this may take a few minutes)..." -ForegroundColor Green
    wsl --install -d Ubuntu
    $ubuntuDistro = "Ubuntu"
    
    Write-Host ""
    Write-Host "Ubuntu installed. Complete the initial user setup in the Ubuntu window that opened." -ForegroundColor Yellow
    Write-Host "Create your username and password, then come back here and press Enter to continue." -ForegroundColor Yellow
    Read-Host "Press Enter when ready"
}

# Set as default
wsl --set-default $ubuntuDistro
Write-Host "Set $ubuntuDistro as default WSL distro" -ForegroundColor Green

# =============================================================================
# 3. Run the dot-files installer inside WSL
# =============================================================================
Write-Host ""
Write-Host "[3/4] Installing OpenCode and tools inside WSL..." -ForegroundColor Yellow

$installScript = @'
set -e

echo "Updating system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

echo "Installing git..."
sudo apt-get install -y git

echo "Cloning dot-files repository..."
if [ -d "$HOME/dot-files" ]; then
    cd "$HOME/dot-files" && git pull
else
    git clone https://github.com/JRedeker/dot-files.git "$HOME/dot-files"
fi

echo "Running installer..."
cd "$HOME/dot-files"
chmod +x install.sh
./install.sh

echo ""
echo "============================================="
echo "  WSL Setup Complete!"
echo "============================================="
'@

# Run the install script in WSL
wsl -d $ubuntuDistro -- bash -c $installScript

# =============================================================================
# 4. Add Windows Terminal profile (optional)
# =============================================================================
Write-Host ""
Write-Host "[4/4] Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Installation Complete!" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Open Windows Terminal and select '$ubuntuDistro'" -ForegroundColor White
Write-Host "  2. Run: exec zsh" -ForegroundColor White
Write-Host "  3. Run: p10k configure  (to set up your prompt)" -ForegroundColor White
Write-Host "  4. Run: vision daemon start -d  (to start MCP servers)" -ForegroundColor White
Write-Host "  5. Run: oc  (to launch OpenCode)" -ForegroundColor White
Write-Host ""
Write-Host "Quick commands:" -ForegroundColor Yellow
Write-Host "  oc        - Launch OpenCode (in tmux)" -ForegroundColor White
Write-Host "  cds       - Create scratch folder and open OpenCode" -ForegroundColor White
Write-Host "  vision server list  - See MCP servers" -ForegroundColor White
Write-Host ""
