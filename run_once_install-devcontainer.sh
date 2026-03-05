#!/bin/bash
# Install devcontainer CLI (for building/running dev containers from the command line)

set -e

# Skip if devcontainer is already installed
if command -v devcontainer &>/dev/null; then
    echo "[chezmoi] devcontainer already installed: $(devcontainer --version)"
    exit 0
fi

# Ensure a recent enough Node.js is available (need >= 18 for devcontainer CLI)
install_node=false
if ! command -v node &>/dev/null; then
    install_node=true
elif [ "$(node -e 'console.log(process.versions.node.split(".")[0])')" -lt 18 ] 2>/dev/null; then
    echo "[chezmoi] Node.js $(node --version) is too old for devcontainer CLI (need >= 18)"
    install_node=true
fi

if [ "$install_node" = true ]; then
    echo "[chezmoi] Installing Node.js LTS via nodesource..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
    echo "[chezmoi] Node.js installed: $(node --version)"
fi

echo "[chezmoi] Installing devcontainer CLI..."
sudo npm install -g @devcontainers/cli
echo "[chezmoi] devcontainer installed: $(devcontainer --version)"
