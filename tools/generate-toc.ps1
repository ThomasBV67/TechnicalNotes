param(
    [string]$ReadmePath = "README.md"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$targetReadme = Join-Path $repoRoot $ReadmePath

if (-not (Test-Path -LiteralPath $targetReadme)) {
    throw "README not found at path: $targetReadme"
}

$sections = @(
    @{ Name = "Frontend"; Path = "frontend/frontend-notes.md" },
    @{ Name = "Backend"; Path = "backend/backend-notes.md" },
    @{ Name = "Tools"; Path = "tools/tools-notes.md" },
    @{ Name = "DevOps"; Path = "devops/devops-notes.md" },
    @{ Name = "Database"; Path = "database/database-notes.md" },
    @{ Name = "Architecture"; Path = "architecture/architecture-notes.md" },
    @{ Name = "Microsoft"; Path = "microsoft/microsoft-notes.md" }
)

$startMarker = "<!-- TOC:START -->"
$endMarker = "<!-- TOC:END -->"

$tocLines = @($startMarker)
$tocLines += "## Sections"
$tocLines += ""
foreach ($section in $sections) {
    $tocLines += "- [$($section.Name)]($($section.Path))"
}
$tocLines += $endMarker

$readmeContent = Get-Content -LiteralPath $targetReadme -Raw

$hasStart = $readmeContent.Contains($startMarker)
$hasEnd = $readmeContent.Contains($endMarker)

if ($hasStart -and $hasEnd) {
    $pattern = [regex]::Escape($startMarker) + ".*?" + [regex]::Escape($endMarker)
    $replacement = ($tocLines -join [Environment]::NewLine)
    $updated = [regex]::Replace(
        $readmeContent,
        $pattern,
        [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $replacement },
        [System.Text.RegularExpressions.RegexOptions]::Singleline
    )
} else {
    $appendBlock = [Environment]::NewLine + [Environment]::NewLine + ($tocLines -join [Environment]::NewLine) + [Environment]::NewLine
    $updated = $readmeContent.TrimEnd() + $appendBlock
}

Set-Content -LiteralPath $targetReadme -Value $updated -Encoding UTF8
Write-Output "TOC updated in $targetReadme"
