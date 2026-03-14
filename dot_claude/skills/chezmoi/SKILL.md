---
name: chezmoi
description: >
  Dotfile management with chezmoi. Use this skill whenever modifying, creating, or
  discussing dotfiles in the home directory — including ~/.bashrc, ~/.claude/*, ~/.ssh/config,
  ~/.gitconfig, or any config file under ~/. Also trigger when the user mentions chezmoi
  directly, asks about syncing dotfiles across machines, or when you notice a home-directory
  file being edited that might need to be persisted. This skill ensures changes are tracked
  in the chezmoi source repo and handles WSL/Windows CRLF issues correctly.
---

# Chezmoi Dotfile Management

## Why This Matters

Dotfiles edited directly in `~/` are ephemeral — they don't survive a fresh machine setup.
Chezmoi is the system of record. Any change to a managed file (or a file that *should* be
managed) needs to flow through chezmoi, or it will be lost.

## Current Setup

| Setting | Value |
|---------|-------|
| Source repo | `~/.local/share/chezmoi/` (git: `YOUR_USERNAME/dotfiles`) |
| Config | `~/.config/chezmoi/chezmoi.toml` |
| Auto-commit | Yes (`autoCommit = true`) |
| Auto-push | Yes (`autoPush = true`) |
| Pre-read hook | `git pull --ff-only --autostash --rebase` (auto-syncs before apply) |

Because auto-commit and auto-push are enabled, `chezmoi add` immediately commits and pushes
to the dotfiles repo. No manual git steps needed.

## Currently Managed Files

```
~/.bashrc
~/.claude/CLAUDE.md
~/.claude/settings.json
~/.claude/skills/wsl-interop/    (SKILL.md, LICENSE, README.md, evals/)
~/.local/bin/install-devcontainer
~/.local/bin/install-docker
~/.local/bin/install-gh
~/.config/chezmoi/chezmoi.toml
```

**Update this list** when adding new files to chezmoi. Run `chezmoi managed` for the
current truth.

## Decision: Should This File Be in Chezmoi?

When you see a home-directory dotfile being created or modified, ask:

1. **Is it under `~/` (home directory)?** If it's in a project repo, it belongs in that
   repo's git, not chezmoi.
2. **Is it machine-specific?** Things like `.claude/settings.local.json` or machine-specific
   SSH keys should NOT be in chezmoi.
3. **Does it contain secrets?** API keys, tokens, passwords → do NOT add. Use `!secret`
   patterns or keep them out of version control entirely.
4. **Would losing it hurt on a fresh machine?** If yes, add it to chezmoi.
5. **Is it auto-generated?** Things like `.bash_history`, `__pycache__`, lock files → skip.

**Examples of what belongs in chezmoi:**
- `~/.bashrc`, `~/.profile`, shell customizations
- `~/.claude/CLAUDE.md` (global Claude Code instructions)
- `~/.claude/settings.json` (global Claude Code settings)
- `~/.claude/skills/<skill>/` (user-level skills, but NOT their `.git/` internals)
- `~/.gitconfig` (if it exists)
- Helper scripts in `~/.local/bin/`

**Examples of what does NOT belong:**
- `~/.claude/settings.local.json` (machine-specific overrides)
- `~/.ssh/id_*` (private keys — secrets)
- Project-level `.claude/skills/` (belong in project repo)
- External skill clones' `.git/` directories (bloat, use `.chezmoiignore`)

## Operations

### Adding a new file
```bash
chezmoi add ~/.path/to/file
```
Auto-commits and pushes. Check the output for CRLF warnings (see below).

### Adding a new skill to chezmoi
```bash
chezmoi add ~/.claude/skills/<skill-name>
```
The `.chezmoiignore` already excludes `.git/**` and `.claude-plugin/**` inside skills,
so git internals won't be pulled in.

### Editing a managed file
Two approaches:
1. **Edit in place, then update chezmoi:**
   ```bash
   # Edit ~/.bashrc directly, then:
   chezmoi add ~/.bashrc    # re-adds with changes, auto-commits+pushes
   ```
2. **Edit through chezmoi** (ensures source stays in sync):
   ```bash
   chezmoi edit ~/.bashrc   # opens in $EDITOR, auto-applies on save
   ```

### Checking what would change
```bash
chezmoi diff          # show what chezmoi would change
chezmoi status        # show which files differ
chezmoi managed       # list all managed files
```

### Applying on a new machine
```bash
chezmoi init --apply YOUR_USERNAME/dotfiles
```

## CRLF / Line Ending Handling

This is the most common footgun in a WSL environment. The dotfiles repo has `.gitattributes`
that forces LF everywhere except Windows scripts:

```
* text eol=lf                    # Everything: LF (Linux/WSL)
*.cmd text eol=crlf              # Windows batch: CRLF
*.bat text eol=crlf              # Windows batch: CRLF
*.ps1 text eol=crlf              # PowerShell: CRLF
```

**If you see CRLF warnings during `chezmoi add`:**
- For Linux/WSL files: the `.gitattributes` will auto-convert to LF on commit. The warning
  is informational — the stored file will be correct.
- For files that genuinely need CRLF (Windows scripts): add a `*.ext text eol=crlf` rule
  to `.gitattributes` in the chezmoi source repo.
- If a file has mixed line endings causing issues, normalize it:
  ```bash
  dos2unix ~/.path/to/file
  chezmoi add ~/.path/to/file
  ```

## Templates (`.tmpl` files)

For files that need to differ between OS/machine, chezmoi uses Go templates:

```
{{ if eq .chezmoi.os "linux" }}
# Linux-specific config
{{ end }}
{{ if eq .chezmoi.os "windows" }}
# Windows-specific config
{{ end }}
```

Current templates in use:
- `.chezmoiignore.tmpl` — skips Windows paths on Linux and vice versa
- `chezmoi.toml.tmpl` — config file itself

Create a template by naming the source file with `.tmpl` suffix in the chezmoi source dir.

## .chezmoiignore

Located at `~/.local/share/chezmoi/.chezmoiignore.tmpl`. Controls what chezmoi skips
during `apply`. Current rules:
- Linux: skips `AppData/**`, `.ssh/**`, Windows install scripts
- Windows: skips `.bashrc`, `.local/**`
- All platforms: skips `.git/**` and `.claude-plugin/**` inside skills

Edit this when adding files that should only exist on certain platforms.
