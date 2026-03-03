#!/bin/bash
# Install GitHub CLI, authenticate, and configure as git credential helper

set -e

# Skip if gh is already installed
if command -v gh &>/dev/null; then
    echo "[chezmoi] gh already installed: $(gh --version | head -1)"
else
    echo "[chezmoi] Installing GitHub CLI..."
    (type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
        && sudo mkdir -p -m 755 /etc/apt/keyrings \
        && out=$(mktemp) && wget -nv -O"$out" https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        && cat "$out" | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
        && rm -f "$out" \
        && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
        && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
        && sudo apt update \
        && sudo apt install gh -y
    echo "[chezmoi] gh installed: $(gh --version | head -1)"
fi

# Configure git to use gh as credential helper for GitHub (works before auth)
gh_path="$(which gh)"
needs_config=false

if ! git config --global --get 'credential.https://github.com.helper' | grep -q 'gh auth git-credential' 2>/dev/null; then
    needs_config=true
fi

if [ "$needs_config" = true ]; then
    echo "[chezmoi] Configuring git to use gh as credential helper for GitHub..."
    git config --global --add 'credential.https://github.com.helper' ''
    git config --global --add 'credential.https://github.com.helper' "!${gh_path} auth git-credential"
    git config --global --add 'credential.https://gist.github.com.helper' ''
    git config --global --add 'credential.https://gist.github.com.helper' "!${gh_path} auth git-credential"
    echo "[chezmoi] Git credential helper configured."
else
    echo "[chezmoi] Git credential helper already configured for gh."
fi

# Authenticate if not already logged in
if gh auth status &>/dev/null; then
    echo "[chezmoi] gh already authenticated."
else
    echo ""
    echo "[chezmoi] Logging in to GitHub CLI..."
    gh auth login
    # Set up git credential helper via gh (in case manual config above missed anything)
    gh auth setup-git
fi
