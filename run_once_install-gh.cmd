@echo off
REM Install GitHub CLI on Windows and authenticate

where gh >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [chezmoi] gh already installed
    gh --version
    goto :auth
)

echo [chezmoi] Installing GitHub CLI via winget...
winget install --id GitHub.cli --accept-source-agreements --accept-package-agreements

REM MSI installs to Program Files but PATH isn't refreshed in this session.
REM Add both possible locations so gh is available immediately.
set "PATH=%ProgramFiles%\GitHub CLI;%ProgramFiles(x86)%\GitHub CLI;%LOCALAPPDATA%\Programs\GitHub CLI;%PATH%"

where gh >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [chezmoi] gh installed but not found in PATH for this session.
    echo [chezmoi] Open a new terminal and run: gh auth login ^&^& gh auth setup-git
    exit /b 0
)

:auth
gh auth status >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [chezmoi] Logging in to GitHub CLI...
    gh auth login
    gh auth setup-git
) else (
    echo [chezmoi] gh already authenticated.
)
