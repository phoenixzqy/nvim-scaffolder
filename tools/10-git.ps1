#Requires -Version 5.1
. "$PSScriptRoot\..\lib\common.ps1"
Write-Banner "Git"
Install-WingetPackage -Id "Git.Git" -DisplayName "Git"
