# Skill: Add a New Windows Tool

Use this skill when adding a new tool to the Windows scaffolder.

## Steps

1. **Create the tool script** at `windows/tools/NN-<name>.ps1` where NN is the
   next available number in sort order. The script must:

   ```powershell
   #Requires -Version 5.1
   . "$PSScriptRoot\..\lib\common.ps1"
   Write-Banner "<Tool Display Name>"

   # Install the tool (pick one):
   Install-WingetPackage -Id "<publisher.package>" -DisplayName "<name>"
   # OR
   Install-ScoopPackage -Name "<name>" -Bucket "<bucket>"

   # Deploy config if needed:
   $src = Join-Path (Get-ScaffolderRoot) "configs\<tool>\<file>"
   $dst = "<target path>"
   Deploy-Config -Source $src -Target $dst
   ```

2. **Add config files** (if any) to `windows/configs/<tool>/`. These should be
   real, diffable files — never templates with placeholders.

3. **Update `windows/capture.ps1`** to snapshot the live config back into the
   repo (add a `Snap` call for the new tool's config location).

4. **Update tests** — the `orchestrator.Tests.ps1` "Captured configs exist"
   section should list new config files. The dry-run test should include the
   new tool name.

5. **Verify**:
   - The script parses: `[System.Management.Automation.PSParser]::Tokenize(...)` returns 0 errors.
   - Dry run lists the tool: `windows/install-all.ps1 -DryRun`
   - Standalone run works: `windows/tools/NN-<name>.ps1`
   - Re-run is idempotent (prints "already present").

## Template

```powershell
#Requires -Version 5.1
. "$PSScriptRoot\..\lib\common.ps1"
Write-Banner "TODO_TOOL_NAME"

Install-WingetPackage -Id "TODO_WINGET_ID" -DisplayName "TODO_TOOL_NAME"

# Optional: deploy config
# $src = Join-Path (Get-ScaffolderRoot) "configs\TODO_TOOL\TODO_FILE"
# $dst = "TODO_TARGET_PATH"
# Deploy-Config -Source $src -Target $dst
```
