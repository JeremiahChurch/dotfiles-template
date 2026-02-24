# Chezmoi dotfiles

https://www.chezmoi.io/

## Quick reference

`chezmoi apply` - apply changes from source to home
`chezmoi update` - pull from remote + apply
`chezmoi add <file>` - add a file to chezmoi (auto-commits and pushes)

## What's managed

| File | Purpose |
|------|---------|
| `.ssh/config` + public keys | SSH config and keys for 1Password agent |
| `AppData/Local/1Password/config/ssh/agent.toml` | 1Password SSH agent config |
| `.claude/settings.json` | Claude Code settings (model, BurntToast notification hooks) |
| `AppData/Roaming/FileZilla/sitemanager.xml` | FileZilla saved sites |

### run_once scripts

| Script | Purpose |
|--------|---------|
| `run_once_install-burnttoast.ps1` | Installs BurntToast PowerShell module (requires admin) |

## Setup new machine

### 1. Install chezmoi

Windows: `winget install twpayne.chezmoi`
Anywhere else: `sh -c "$(curl -fsLS get.chezmoi.io)"`

### 2. Init and apply

```
chezmoi init --apply https://github.com/JeremiahChurch/dotfiles.git
```

The `run_once_install-burnttoast.ps1` script runs automatically on first apply.
If it fails (needs admin), run manually in an elevated PowerShell:
```powershell
Install-Module -Name BurntToast -Repository PSGallery -Force -Scope AllUsers
```

### 3. WSL setup (manual steps)

These live in WSL and aren't managed by chezmoi (Windows-side only):

**Symlink Claude settings from Windows into WSL:**
```bash
mkdir -p ~/.claude
ln -sf /mnt/c/Users/$(powershell.exe -Command '$env:USERNAME' | tr -d '\r')/.claude/settings.json ~/.claude/settings.json
```

**Add to `~/.bashrc` (aliases for 1Password SSH agent via Windows OpenSSH):**
```bash
# 1pass CLI WSL integration
alias ssh='ssh.exe'
alias ssh-add='ssh-add.exe'
```

**Optional: auto-sync chezmoi on shell start (add to `~/.bashrc`):**
```bash
# Keep chezmoi dotfiles in sync on shell start
chezmoi.exe apply --no-tty 2>/dev/null &
```

## Sync behavior

Configured in `chezmoi.toml`:
- **autoCommit**: any `chezmoi add` automatically commits
- **autoPush**: commits are automatically pushed to origin
- **pre-hook**: `git pull --ff-only` runs before reading source state

This means: changes made on any machine are pushed immediately, and any machine
that runs `chezmoi apply` (or opens a WSL shell with the auto-sync line) pulls
the latest first.

## What doesn't belong in run_once

Keep `run_once_` scripts for simple, idempotent installs (like BurntToast).
Put these in the README instead:
- Anything requiring interactive decisions or manual verification
- Complex multi-step processes with conditional logic
- One-time configuration that varies per machine (IP addresses, hostnames)
- WSL-side setup (chezmoi runs on Windows, can't reliably reach into WSL)
