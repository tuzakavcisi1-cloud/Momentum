#requires -Version 5.1
<#
    Momentum verify chain (ADR 0001 K-H1, GOREV slice-1 D13).
    Runs from the repo root against Momentum.sln:
        1) dotnet build -warnaserror   (0 warnings / 0 errors; BannedApiAnalyzers + analyzers)
        2) dotnet test                 (arch rules + health + ping + problem+json + openapi + scalar)
        3) CVE gate (D12)              (dotnet list package --vulnerable, JSON-parsed; raw exit is unreliable)
    Any failure -> exit code != 0.
#>

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# StrictMode-safe property read: `dotnet list --vulnerable` omits (not nulls) `frameworks`
# when a project has no advisories, and StrictMode throws on missing-property access.
function Get-Prop {
    param($Object, [string]$Name)
    if ($null -ne $Object -and $Object.PSObject.Properties.Match($Name).Count -gt 0) {
        return $Object.$Name
    }
    return $null
}

# --- locate a .NET SDK (prefer the 64-bit install; the machine may have an SDK-less x86 first on PATH) ---
$dotnet = 'dotnet'
$preferred = Join-Path -Path $(if ($env:ProgramFiles) { $env:ProgramFiles } else { $PSScriptRoot }) -ChildPath 'dotnet\dotnet.exe'
if (Test-Path $preferred) {
    $hasSdk = & $preferred --list-sdks 2>$null
    if ($hasSdk) { $dotnet = $preferred }
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$solution = Join-Path $repoRoot 'Momentum.sln'
Write-Host "== Momentum verify ==" -ForegroundColor Cyan
Write-Host "dotnet   : $dotnet"
Write-Host "solution : $solution"
Write-Host ("sdk      : {0}" -f ((& $dotnet --version) 2>$null))

function Invoke-Step {
    param([string]$Name, [scriptblock]$Action)
    Write-Host "`n--- $Name ---" -ForegroundColor Yellow
    & $Action
    if ($LASTEXITCODE -ne 0) {
        Write-Host "FAILED: $Name (exit $LASTEXITCODE)" -ForegroundColor Red
        exit $LASTEXITCODE
    }
}

# 1) Build (warnings are errors).
Invoke-Step 'build -warnaserror' { & $dotnet build $solution -warnaserror --nologo }

# slice-3d D9OwnerIdVisibilityTests: fail-loud yerine sessizce atlamayi ONLEMEK icin
# MOMENTUM_KANIT_DIZIN zorunludur (8.2). verify.ps1 -- otomatik regresyon kapisi --
# ayarlanmamissa makul bir varsayilan verir; elle `dotnet test` cagiran biri icin
# degisken hala zorunlu kalir (test kendi basina firlatir).
if (-not $env:MOMENTUM_KANIT_DIZIN) {
    $env:MOMENTUM_KANIT_DIZIN = Join-Path (Join-Path (Join-Path $repoRoot 'KANIT') 'slice-3d') '07-G7-backend-zorlama'
}
New-Item -ItemType Directory -Force -Path $env:MOMENTUM_KANIT_DIZIN | Out-Null

# 2) Test (reuse the build output).
Invoke-Step 'test' { & $dotnet test $solution --no-build --nologo }

# 3) CVE gate — parse JSON; `dotnet list --vulnerable` returns exit 0 even WITH advisories.
Write-Host "`n--- CVE gate (dotnet list package --vulnerable) ---" -ForegroundColor Yellow
$raw = & $dotnet list $solution package --vulnerable --include-transitive --format json 2>$null | Out-String
$vulnCount = 0
try {
    $report = $raw | ConvertFrom-Json
    foreach ($project in @(Get-Prop $report 'projects')) {
        foreach ($fw in @(Get-Prop $project 'frameworks')) {
            foreach ($bucket in @('topLevelPackages', 'transitivePackages')) {
                foreach ($pkg in @(Get-Prop $fw $bucket)) {
                    $vulns = Get-Prop $pkg 'vulnerabilities'
                    if ($vulns) { $vulnCount += @($vulns).Count }
                }
            }
        }
    }
}
catch {
    Write-Host "FAILED: could not parse vulnerability JSON: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

if ($vulnCount -gt 0) {
    Write-Host "FAILED: $vulnCount vulnerable package(s) reported." -ForegroundColor Red
    Write-Host $raw
    exit 1
}
Write-Host "CVE gate clean: 0 vulnerable packages." -ForegroundColor Green

Write-Host "`n== VERIFY PASSED ==" -ForegroundColor Green
exit 0
