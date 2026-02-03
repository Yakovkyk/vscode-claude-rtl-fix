# RTL for Claude Code - Installation Script
# Run: powershell -ExecutionPolicy Bypass -File install.ps1
# Use -Force to reinstall (restore from backup first, then inject fresh)

param(
    [switch]$Force
)

Write-Host "RTL for Claude Code - Installer" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
if ($Force) { Write-Host "(Force mode - will reinstall even if already present)" -ForegroundColor Yellow }
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Find Claude Code extensions
$ExtPath = "$env:USERPROFILE\.vscode\extensions"
$ClaudeExts = Get-ChildItem -Path $ExtPath -Filter "anthropic.claude-code-*" -Directory -ErrorAction SilentlyContinue

if ($ClaudeExts.Count -eq 0) {
    Write-Host "Claude Code extension not found!" -ForegroundColor Red
    exit 1
}

foreach ($ext in $ClaudeExts) {
    $IndexJs = Join-Path $ext.FullName "webview\index.js"

    if (Test-Path $IndexJs) {
        Write-Host "Found: $($ext.Name)" -ForegroundColor Green

        # Create backup
        $BackupPath = "$IndexJs.backup"
        if (-not (Test-Path $BackupPath)) {
            Copy-Item $IndexJs $BackupPath
            Write-Host "  Backup created" -ForegroundColor Green
        } else {
            Write-Host "  Backup already exists" -ForegroundColor Yellow
        }

        # Check if already installed
        $Content = Get-Content $IndexJs -Raw
        if ($Content -match "RTL Support for Claude Code") {
            if ($Force) {
                # Restore from backup and re-inject
                Write-Host "  RTL found, restoring from backup for fresh install..." -ForegroundColor Yellow
                Copy-Item $BackupPath $IndexJs -Force
            } else {
                Write-Host "  RTL already installed, skipping (use -Force to reinstall)" -ForegroundColor Yellow
                continue
            }
        }

        # Inject RTL script
        $RtlScript = Get-Content (Join-Path $ScriptDir "rtl-claude-code.js") -Raw
        Add-Content -Path $IndexJs -Value "`n$RtlScript"
        Write-Host "  RTL script injected!" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Done! Restart VS Code to apply changes." -ForegroundColor Cyan
