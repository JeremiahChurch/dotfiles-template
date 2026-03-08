# Global Claude Code Instructions

## Environment
- Always running inside WSL (Windows Subsystem for Linux). The `wsl-interop` skill has the full reference for path conversion, SSH agent interop, clipboard bridging, filesystem quirks, and other WSL-specific patterns.

## Output Formatting (WSL)

These rules apply to ALL responses — not just when the user asks about paths or WSL.

### Clickable file paths
- **WSL-native files** (`/home/...`, `/tmp/...`): Output a `file:` URI with **4 slashes** and forward slashes:
  `file:////wsl.localhost/Ubuntu<path-with-forward-slashes>`
- **Windows drive files** (`/mnt/c/...`): No clickable URI works. Show the Windows path (`C:\...`) and **offer to open it**:
  `cmd.exe /c start "" "$(wslpath -w /mnt/c/path/to/file)"`
- **When to do this**: files you create/modify, documents/artifacts to review, file locations the user asked about
- **When NOT to do this**: inline `file_path:line_number` code references, paths inside code/configs

### Clickable URLs
- Always use full URLs with a scheme (`https://`, `http://`) — never bare hostnames. The terminal auto-links `https://` but bare hostnames are not clickable.

### SSH
- Use `ssh.exe` (not `ssh`) — the SSH agent (1Password) runs on the Windows side. Same for `scp.exe`, `sftp.exe`.
