# bootstrap

One command to set up Claude Code on a clean Windows with my private config (`e314q/claude-config`).
Paste into PowerShell:

```powershell
irm https://raw.githubusercontent.com/e314q/bootstrap/main/bootstrap.ps1 | iex
```

Installs Git, GitHub CLI and Claude Code via winget/official installer, asks to log in to GitHub in the browser,
then downloads the private config and runs its `restore.ps1`. Contains no data; without access to the private
repositories it stops after the login.
