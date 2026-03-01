@echo off
REM Install BurntToast PowerShell module for Windows toast notifications
REM Used by Claude Code hooks for permission/idle prompt alerts
powershell.exe -ExecutionPolicy Bypass -Command "Install-Module -Name BurntToast -Repository PSGallery -Force -Scope CurrentUser"
