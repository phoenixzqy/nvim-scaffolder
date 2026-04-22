#Requires -Version 5.1
. "$PSScriptRoot\..\lib\common.ps1"
Write-Banner "Node.js (LTS)"

Install-WingetPackage -Id "OpenJS.NodeJS.LTS" -DisplayName "Node.js LTS"
Refresh-Path

if (Test-Command npm) {
    Write-Step "Installing global npm packages (neovim provider, pnpm)…"
    foreach ($pkg in @("neovim", "pnpm")) {
        try { & npm install -g $pkg --silent | Out-Null; Write-Ok "npm -g $pkg" }
        catch { Write-Warn2 "npm install -g $pkg failed: $_" }
    }
} else {
    Write-Warn2 "npm not on PATH yet; open a new shell and re-run tools/20-node.ps1"
}
