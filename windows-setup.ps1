# =============================================================================
# WSL2 Ubuntu Setup Script for Windows
# Run this in PowerShell (Admin recommended)
# =============================================================================

param(
    [switch]$Phase2
)

$ErrorActionPreference = "Stop"

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  WSL2 Ubuntu + OpenCode Setup" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# PHASE 2: Run after Ubuntu user setup is complete
# =============================================================================
if ($Phase2) {
    Write-Host "[Phase 2] Continuing setup inside Ubuntu..." -ForegroundColor Yellow
    
    # Find Ubuntu distro
    $distros = wsl --list --quiet 2>$null | Where-Object { $_ -match "Ubuntu" -and $_ -ne "" }
    if (-not $distros) {
        Write-Host "ERROR: Ubuntu not found. Please run the script without -Phase2 first." -ForegroundColor Red
        exit 1
    }
    $ubuntuDistro = ($distros | Select-Object -First 1).Trim()
    Write-Host "Found distro: $ubuntuDistro" -ForegroundColor Green
    
    # Set as default
    wsl --set-default $ubuntuDistro
    
    Write-Host "Installing OpenCode and tools inside WSL..." -ForegroundColor Yellow
    Write-Host "(This will take several minutes)" -ForegroundColor Gray
    Write-Host ""

$installScript = @'
#!/bin/bash
set -e

echo "========================================"
echo "  Installing inside Ubuntu..."
echo "========================================"

echo ""
echo "[1/5] Updating system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

echo ""
echo "[2/5] Installing git..."
sudo apt-get install -y git

echo ""
echo "[3/5] Cloning dot-files repository..."
if [ -d "$HOME/dot-files" ]; then
    cd "$HOME/dot-files" && git pull
else
    git clone https://github.com/JRedeker/dot-files.git "$HOME/dot-files"
fi

echo ""
echo "[4/5] Running installer..."
cd "$HOME/dot-files"
chmod +x install.sh
./install.sh

echo ""
echo "[5/5] Setup complete!"
echo ""
'@

    # Run the install script in WSL
    $installScript | wsl -d $ubuntuDistro -- bash
    
    Write-Host ""
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "  Installation Complete!" -ForegroundColor Cyan  
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Open Windows Terminal and select 'Ubuntu'" -ForegroundColor White
    Write-Host "  2. Run: exec zsh" -ForegroundColor White
    Write-Host "  3. Run: p10k configure  (set up your prompt)" -ForegroundColor White
    Write-Host "  4. Run: vision daemon start -d  (start MCP servers)" -ForegroundColor White
    Write-Host "  5. Run: oc  (launch OpenCode)" -ForegroundColor White
    Write-Host ""
    exit 0
}

# =============================================================================
# PHASE 1: Install WSL and Ubuntu
# =============================================================================

# Check if WSL is available
Write-Host "[Phase 1] Checking WSL installation..." -ForegroundColor Yellow

$wslAvailable = $false
try {
    $wslVersion = wsl --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        $wslAvailable = $true
    }
} catch {}

if (-not $wslAvailable) {
    Write-Host "Installing WSL with Ubuntu..." -ForegroundColor Green
    wsl --install -d Ubuntu
    Write-Host ""
    Write-Host "=============================================" -ForegroundColor Yellow
    Write-Host "  WSL + Ubuntu installed - RESTART REQUIRED" -ForegroundColor Yellow
    Write-Host "=============================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please:" -ForegroundColor White
    Write-Host "  1. RESTART your computer" -ForegroundColor White
    Write-Host "  2. Ubuntu will auto-launch - create your username/password" -ForegroundColor White
    Write-Host "  3. After setup, open PowerShell and run:" -ForegroundColor White
    Write-Host ""
    Write-Host "     irm https://raw.githubusercontent.com/JRedeker/dot-files/trunk/windows-setup.ps1 -OutFile ws.ps1; .\ws.ps1 -Phase2" -ForegroundColor Cyan
    Write-Host ""
    exit 0
}

Write-Host "WSL is available" -ForegroundColor Green

# Ensure WSL2 is the default
wsl --set-default-version 2 2>$null

# Check if Ubuntu is already installed
Write-Host ""
Write-Host "Checking for Ubuntu..." -ForegroundColor Yellow

$distros = wsl --list --quiet 2>$null | Where-Object { $_ -match "Ubuntu" -and $_ -ne "" }

if ($distros) {
    Write-Host "Ubuntu is already installed" -ForegroundColor Green
    Write-Host ""
    Write-Host "Proceeding to Phase 2..." -ForegroundColor Yellow
    
    # Re-run with Phase2
    & $PSCommandPath -Phase2
    exit 0
}

# Install Ubuntu
Write-Host "Installing Ubuntu..." -ForegroundColor Green
Write-Host "(This will open a new window for initial setup)" -ForegroundColor Gray
Write-Host ""

wsl --install -d Ubuntu

Write-Host ""
Write-Host "=============================================" -ForegroundColor Yellow
Write-Host "  Ubuntu is installing..." -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "A new Ubuntu window should have opened." -ForegroundColor White
Write-Host ""
Write-Host "Please:" -ForegroundColor White
Write-Host "  1. Wait for Ubuntu to finish installing in the new window" -ForegroundColor White
Write-Host "  2. Create your username and password when prompted" -ForegroundColor White
Write-Host "  3. After you see the bash prompt, close that window" -ForegroundColor White
Write-Host "  4. Come back here and run:" -ForegroundColor White
Write-Host ""
Write-Host "     irm https://raw.githubusercontent.com/JRedeker/dot-files/trunk/windows-setup.ps1 -OutFile ws.ps1; .\ws.ps1 -Phase2" -ForegroundColor Cyan
Write-Host ""
Write-Host "Or if you saved this script:" -ForegroundColor Gray
Write-Host "     .\windows-setup.ps1 -Phase2" -ForegroundColor Gray
Write-Host ""
