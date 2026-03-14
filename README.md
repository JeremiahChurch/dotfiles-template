# Chezmoi + Claude Code + WSL Dotfiles Template

A starter dotfiles repo for [chezmoi](https://www.chezmoi.io/) with Claude Code configuration and WSL interop baked in. Fork this and make it yours.

## What's included

### Both platforms

| File | Purpose |
|------|---------|
| `.claude/settings.json` | Claude Code account-level permissions, model pref, notification hooks |
| `.claude/CLAUDE.md` | Global Claude Code instructions (WSL awareness, MCP server management) |
| `.claude/skills/chezmoi/` | Skill that teaches Claude how to manage dotfiles through chezmoi |
| `.claude/skills/wsl-interop/` | Skill for WSL path conversion, clickable file URIs, SSH agent interop |
| `.bash_aliases` | Claude Code shell aliases (`cc`, `ccd`) |

### Windows only

| File | Purpose |
|------|---------|
| `install-burnttoast.cmd` (run_once) | Installs BurntToast PowerShell module for toast notifications |
| `install-gh.cmd` (run_once) | Installs GitHub CLI via winget + prompts `gh auth login` |

### WSL/Linux only

| File | Purpose |
|------|---------|
| `.bashrc` | Bash config — sources `.bashrc.local`, runs `chezmoi update` on startup |
| `~/.local/bin/install-gh` | Installs GitHub CLI + configures git credential helper + `gh auth login` |
| `~/.local/bin/install-devcontainer` | Installs devcontainer CLI via npm |
| `~/.local/bin/install-docker` | Installs Docker Engine natively in WSL (replaces Docker Desktop) |

### NOT managed (create manually per machine)

| File | Purpose | Why not |
|------|---------|---------|
| `.bashrc.local` | Machine-specific env vars, aliases, secrets | Contains secrets |
| `.claude/settings.local.json` | Machine-specific Claude Code overrides | Machine-specific |
| `.ssh/config` | SSH host configurations | Contains infrastructure details |
| `.ssh/id_*` | SSH private keys | Secrets |

## Setup

### 1. Fork this repo

Click **Fork** on GitHub, or:
```bash
gh repo create my-dotfiles --template YOUR_USERNAME/dotfiles --public
```

### 2. Install chezmoi

**Windows (PowerShell):**
```
winget install twpayne.chezmoi
```

**WSL/Linux:**
```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
```

### 3. Initialize

```bash
chezmoi init --apply https://github.com/YOUR_USERNAME/dotfiles.git
```

The `run_once` scripts run automatically on first apply:
- **Windows:** installs BurntToast + GitHub CLI
- **WSL/Linux:** `.bashrc` will warn about any missing tools on first login

### 4. Install tools (WSL)

On first login, `.bashrc` will prompt you. Run interactively:
```bash
install-gh            # GitHub CLI + git credential helper + gh auth login
install-devcontainer  # devcontainer CLI via npm
install-docker        # Docker Engine natively in WSL
```

### 5. Create `.bashrc.local`

Machine-specific config that should NOT be in version control:
```bash
cat > ~/.bashrc.local << 'EOF'
# 1Password SSH agent via Windows OpenSSH (if using 1Password for SSH keys)
alias ssh='ssh.exe'
alias ssh-add='ssh-add.exe'

# Example: Home Assistant token
# export HASS_SERVER="https://your-ha-instance.local:8123"
# export HASS_TOKEN="<token>"
EOF
```

## How syncing works

Configured in `chezmoi.toml`:
- **autoCommit**: any `chezmoi add` automatically commits
- **autoPush**: commits are automatically pushed to origin
- **pre-hook**: `git pull --ff-only` runs before reading source state

`.bashrc` also runs a sync on every new interactive shell (with a 5-second timeout), so changes made on any machine propagate automatically.

## Adding your own files

```bash
# Add a new dotfile to chezmoi management
chezmoi add ~/.gitconfig

# Add a new skill
chezmoi add ~/.claude/skills/my-skill

# Check what chezmoi manages
chezmoi managed
```

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

## CRLF handling

The `.gitattributes` forces LF everywhere except Windows scripts (`*.cmd`, `*.bat`, `*.ps1` get CRLF). This prevents shell scripts from breaking in WSL due to `\r` characters.

## Customizing for your setup

Things you'll likely want to add:
- **`.ssh/config`** — but keep it out of this repo if it has internal IPs/hostnames. Use a separate private repo or manage it manually.
- **`AppData/` configs** — 1Password SSH agent, FileZilla, etc. Same caveat about secrets.
- **`.gitconfig`** — safe to add if it doesn't contain tokens
- **More install scripts** — add to `dot_local/bin/` with the `executable_` prefix

## License

MIT
