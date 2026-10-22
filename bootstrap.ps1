# One command for a clean Windows: Git, GitHub CLI, Claude Code, GitHub login, then e314q/claude-config
# (rules, settings, memory, own skills and everything they need). Paste into PowerShell:
#   irm https://raw.githubusercontent.com/e314q/bootstrap/main/bootstrap.ps1 | iex
# Safe to run again. The only things done by hand: the GitHub login in the browser, and the Claude login on first `claude`.
& {
    $ErrorActionPreference = "Stop"
    function Refresh-Path {
        $env:Path = (@([Environment]::GetEnvironmentVariable("Path", "Machine"), [Environment]::GetEnvironmentVariable("Path", "User"),
                      (Join-Path $env:USERPROFILE ".local\bin"), $env:Path) | Where-Object { $_ }) -join ";"
    }
    function Has($cmd) { [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }
    function Winget($id) {
        Write-Host "== install $id"
        winget install -e --id $id --source winget --accept-source-agreements --accept-package-agreements --silent
        Refresh-Path
    }

    Refresh-Path
    if (-not (Has winget)) { throw "winget not found: install 'App Installer' from Microsoft Store and run again" }
    if (-not (Has git)) { Winget Git.Git }
    if (-not (Has gh)) { Winget GitHub.cli }
    if (-not (Has claude)) { Write-Host "== install Claude Code"; Invoke-RestMethod https://claude.ai/install.ps1 | Invoke-Expression; Refresh-Path }

    cmd /c "gh auth status >nul 2>&1"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "== GitHub login: a code is shown, the browser opens - enter the code and allow access"
        gh auth login --web --git-protocol https --hostname github.com
        if ($LASTEXITCODE -ne 0) { throw "GitHub login failed" }
    }
    gh auth setup-git  # git push/pull to private repos via gh's login

    $cfg = Join-Path $env:USERPROFILE ".claude"
    if (Test-Path (Join-Path $cfg ".git")) {
        Write-Host "== update claude-config"; git -C $cfg pull --ff-only; $restore = Join-Path $cfg "restore.ps1"
    } else {
        $tmp = Join-Path $env:TEMP ("claude-config-" + (Get-Date -Format "yyyyMMddHHmmss"))
        Write-Host "== download claude-config"; gh repo clone e314q/claude-config $tmp; $restore = Join-Path $tmp "restore.ps1"
    }
    if ($LASTEXITCODE -ne 0) { throw "could not get e314q/claude-config" }
    powershell -ExecutionPolicy Bypass -File $restore
    if ($LASTEXITCODE -ne 0) { throw "restore.ps1 failed" }

    Write-Host ""
    Write-Host "Ready. Open a NEW PowerShell window and run: claude"
}
