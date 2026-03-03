@echo off
REM Install GitHub CLI on Windows and authenticate

where gh >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [chezmoi] gh already installed
    gh --version
) else (
    echo [chezmoi] Installing GitHub CLI via winget...
    winget install --id GitHub.cli --accept-source-agreements --accept-package-agreements
    REM Refresh PATH so gh is available in this session
    set "PATH=%LOCALAPPDATA%\Programs\GitHub CLI;%PATH%"
)

REM Authenticate if not already logged in
gh auth status >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [chezmoi] Logging in to GitHub CLI...
    gh auth login
    gh auth setup-git
) else (
    echo [chezmoi] gh already authenticated.
)
