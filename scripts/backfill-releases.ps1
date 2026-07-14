#requires -Version 7
<#
.SYNOPSIS
    One-time backfill of the historical GitHub Release for Sprintware.

.DESCRIPTION
    Sprintware shipped v1.0.0 on Nexus (mods/29163) long before this repo was public, so GitHub has
    no release to show for it. This creates one from the zip that was actually published, in
    _release_archive/.

    The release is GitHub-only: its body carries an invisible "<!-- skip-nexus -->" marker, so
    .github/workflows/release.yml skips the Nexus upload step. That version is ALREADY on Nexus, and
    re-uploading it would archive the live file and replace it with a rebuild. The historical zip is
    attached directly rather than rebuilt from source.

    UNLIKE the checklist mods' backfill, this one is created as LATEST (--latest=true). There: the
    backfilled versions were superseded by a newer real release, so stealing "Latest" would have been
    wrong. Here v1.0.0 IS the current release, and marking it latest is simply accurate.

    Idempotent: an existing tag is skipped.

    Run from the repo root, after the repo is on GitHub and `gh` is authenticated.

.PARAMETER DryRun
    Show what would be created without calling gh.

.EXAMPLE
    pwsh ./scripts/backfill-releases.ps1 -DryRun
    pwsh ./scripts/backfill-releases.ps1
#>
param(
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$repoRoot    = Split-Path $PSScriptRoot -Parent
$archiveRoot = Join-Path $repoRoot '_release_archive'
$changelog   = Join-Path $repoRoot 'nexus_changelog.md'
$marker      = '<!-- skip-nexus -->'

# Only versions actually published on Nexus. Sprintware has exactly one.
$releases = @(
    @{ artifact = 'sprintware'; version = '1.0.0'; zip = 'Sprintware_v1.0.0.zip'; changelog = $changelog }
)

# Pull a "## vX" / "### vX" section out of a changelog file; '' if not found.
function Get-ChangelogSection([string]$file, [string]$version) {
    if (-not $file -or -not (Test-Path $file)) { return '' }
    $lines = Get-Content -LiteralPath $file
    $out = [System.Collections.Generic.List[string]]::new()
    $inSection = $false
    foreach ($line in $lines) {
        if ($line -match '^\s*#{2,3}\s') {
            if ($inSection) { break }                      # next heading ends the section
            if ($line -match ("(?i)v?" + [regex]::Escape($version) + '\b')) { $inSection = $true }
            continue
        }
        if ($inSection) { $out.Add($line) }
    }
    return ($out -join "`n").Trim()
}

$manifest = Get-Content -LiteralPath (Join-Path $repoRoot 'release-manifest.json') -Raw | ConvertFrom-Json

$created = 0; $skipped = 0; $missing = 0
foreach ($r in $releases) {
    $tag   = "$($r.artifact)-v$($r.version)"
    $zip   = Join-Path $archiveRoot $r.zip
    $name  = $manifest.artifacts.($r.artifact).displayName
    $title = "$name v$($r.version)"

    if (-not (Test-Path $zip)) {
        Write-Warning "MISSING zip for $tag : $zip  (skipping)"
        $missing++; continue
    }

    & gh release view $tag *> $null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "exists  $tag  (skip)" -ForegroundColor DarkGray
        $skipped++; continue
    }

    $section = Get-ChangelogSection $r.changelog $r.version
    $body = if ($section) { $section } else { "Archived release of $name v$($r.version)." }
    $body = "$body`n`nPublished on Nexus: https://www.nexusmods.com/cyberpunk2077/mods/29163`n`n$marker"

    if ($DryRun) {
        Write-Host "DRYRUN  would create $tag  <- $($r.zip)" -ForegroundColor Cyan
        Write-Host "--- body ---" -ForegroundColor DarkGray
        Write-Host $body -ForegroundColor DarkGray
        Write-Host "------------" -ForegroundColor DarkGray
        continue
    }

    $notesFile = New-TemporaryFile
    Set-Content -LiteralPath $notesFile -Value $body -Encoding utf8
    try {
        & gh release create $tag $zip --title $title --notes-file $notesFile --target main --latest
        if ($LASTEXITCODE -ne 0) { throw "gh release create failed for $tag" }
        Write-Host "created $tag" -ForegroundColor Green
        $created++
    }
    finally {
        Remove-Item -LiteralPath $notesFile -ErrorAction SilentlyContinue
    }
}

Write-Host ""
Write-Host "Done. created=$created skipped=$skipped missing=$missing" -ForegroundColor Yellow
if ($DryRun) { Write-Host "(dry run - nothing was created)" -ForegroundColor Cyan }

if ($missing -gt 0) { exit 1 } else { exit 0 }
