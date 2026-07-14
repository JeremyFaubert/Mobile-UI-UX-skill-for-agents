param(
    [ValidateSet("Project", "User")]
    [string]$Scope = "Project",

    [ValidateSet("Codex", "Claude", "Both")]
    [string]$Target = "Both",

    [string]$ProjectPath = (Get-Location).Path
)

$ErrorActionPreference = "Stop"
$Source = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillName = "mobile-ui-ux-designer"
$Items = @("SKILL.md", "README.md", "NOTICE.md", "references", "assets", "scripts", "evals")

function Install-Skill([string]$Destination) {
    $ResolvedSource = [System.IO.Path]::GetFullPath($Source).TrimEnd("\")
    $ResolvedDestination = [System.IO.Path]::GetFullPath($Destination).TrimEnd("\")
    if ($ResolvedSource -eq $ResolvedDestination) { throw "Refusing to replace the source directory: $Source" }
    if (Test-Path $Destination) { Remove-Item -Recurse -Force $Destination }
    New-Item -ItemType Directory -Force -Path $Destination | Out-Null
    foreach ($Item in $Items) {
        $From = Join-Path $Source $Item
        if (Test-Path $From) {
            Copy-Item -Path $From -Destination $Destination -Recurse -Force
        }
    }
    Write-Host "Installed $SkillName -> $Destination"
}

$InstallCodex = $Target -in @("Codex", "Both")
$InstallClaude = $Target -in @("Claude", "Both")

if ($Scope -eq "Project") {
    $Base = (Resolve-Path $ProjectPath).Path
    if ($InstallCodex) {
        Install-Skill (Join-Path $Base ".agents\skills\$SkillName")
    }
    if ($InstallClaude) {
        Install-Skill (Join-Path $Base ".claude\skills\$SkillName")
    }
} else {
    if (-not $HOME) { throw "HOME is not available." }
    if ($InstallCodex) {
        Install-Skill (Join-Path $HOME ".agents\skills\$SkillName")
    }
    if ($InstallClaude) {
        Install-Skill (Join-Path $HOME ".claude\skills\$SkillName")
    }
}

Write-Host "Done. Restart the coding agent if the skill does not appear automatically."
