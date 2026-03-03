# Chezmoi dotfiles

https://www.chezmoi.io/

## Quick reference

`chezmoi apply` - apply changes from source to home
`chezmoi update` - pull from remote + apply
`chezmoi add <file>` - add a file to chezmoi (auto-commits and pushes)

## What's managed

### Both platforms

| File | Purpose |
|------|---------|
| `.claude/settings.json` | Claude Code account-level permissions, model pref, notification hooks |

### Windows only

| File | Purpose |
|------|---------|
| `.ssh/config` + public keys | SSH config and keys for 1Password agent |
| `AppData/Local/1Password/config/ssh/agent.toml` | 1Password SSH agent config |
| `AppData/Roaming/FileZilla/sitemanager.xml` | FileZilla saved sites |
| `install-burnttoast.cmd` (run_once) | Installs BurntToast PowerShell module |
| `install-gh.cmd` (run_once) | Installs GitHub CLI via winget + prompts `gh auth login` |

### WSL/Linux only

| File | Purpose |
|------|---------|
| `.bashrc` | Canonical bash config — sources `.bashrc.local`, runs `chezmoi update` on startup |
| `install-gh.sh` (run_once) | Installs GitHub CLI via apt + configures git credential helper + prompts `gh auth login` |

### NOT managed (manual per machine)

| File | Purpose | Why not |
|------|---------|---------|
| `.bashrc.local` | HASS_TOKEN, SSH aliases, machine-specific env | Contains secrets |

## Setup new machine

### Windows

```
winget install twpayne.chezmoi
chezmoi init --apply https://github.com/JeremiahChurch/dotfiles.git
```

The run_once scripts run automatically on first apply:
- `install-burnttoast.cmd` — installs BurntToast PowerShell module
- `install-gh.cmd` — installs GitHub CLI and prompts for `gh auth login`

### WSL (on the same machine, or a Linux-only box)

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
chezmoi init --apply https://github.com/JeremiahChurch/dotfiles.git
```

This installs:
- `~/.bashrc` with `chezmoi update` auto-sync on shell startup
- `~/.claude/settings.json` with account-level Claude Code settings
- GitHub CLI (`gh`) with git credential helper configured
- Prompts for `gh auth login` so chezmoi auto-push works immediately

Then create `~/.bashrc.local` manually with machine-specific config:
```bash
cat > ~/.bashrc.local << 'EOF'
# 1Password SSH agent via Windows OpenSSH
alias ssh='ssh.exe'
alias ssh-add='ssh-add.exe'

# HA
export HASS_SERVER="https://ha.jeremiah.church"
export HASS_TOKEN="<token from 1Password or HA>"
EOF
```

## Update existing machines

For machines that already have Windows chezmoi but no WSL chezmoi:

```bash
# 1. Update Windows chezmoi first (picks up new .chezmoiignore, etc.)
chezmoi.exe update

# 2. Install chezmoi in WSL
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin

# 3. Init WSL chezmoi from the same dotfiles repo
chezmoi init --apply https://github.com/JeremiahChurch/dotfiles.git
```

After this, `.bashrc` includes the auto-update hook — future changes
to the dotfiles repo are applied automatically on every new shell.

For machines that already have both Windows and WSL chezmoi:

```bash
# Just update — pulls latest and applies
chezmoi update          # in WSL
chezmoi.exe update      # on Windows side
```

## Sync behavior

Configured in `chezmoi.toml`:
- **autoCommit**: any `chezmoi add` automatically commits
- **autoPush**: commits are automatically pushed to origin
- **pre-hook**: `git pull --ff-only` runs before reading source state

This means: changes made on any machine are pushed immediately, and any machine
that runs `chezmoi update` (or opens a new WSL shell) pulls the latest first.

## Claude Code settings architecture

Permissions are split across three levels:

| Level | File | Synced via |
|-------|------|-----------|
| Account | `~/.claude/settings.json` | chezmoi (this repo) |
| Project (shared) | `<project>/.claude/settings.json` | project git repo |
| Project (local) | `<project>/.claude/settings.local.json` | not synced (gitignored) |

Account settings contain general dev tools (git, gh, npm, python, etc.).
Project settings contain project-specific approvals (MCP tools, SSH, domains).
Local settings contain machine-specific overrides (Windows paths, etc.).
