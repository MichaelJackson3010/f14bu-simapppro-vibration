# F-14B(U) Tomcat vibration support installer for WinWing SimAppPro
# https://github.com/MichaelJackson3010/f14bu-simapppro-vibration
#
# What it does (see README.md for details):
#   1. Adds the F-14B(U) to SimAppPro's aircraft list (one file in Program
#      Files - a backup named app.asar.bak is created first if none exists).
#   2. Creates F-14B(U) vibration curves for pilot AND RIO seats by copying
#      WinWing's own F-14B profile already in YOUR SimAppPro installation.
#   3. If you tuned custom F-14B curves, carries them over to the F-14B(U).
#
# Run:  Right-click -> "Run with PowerShell", or from a terminal:
#       powershell -ExecutionPolicy Bypass -File .\install.ps1

$ErrorActionPreference = 'Stop'

# ---- tell the user what is about to happen, and ask first --------------------
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host ""
    Write-Host "F-14B(U) Tomcat - WinWing SimAppPro vibration setup" -ForegroundColor Cyan
    Write-Host "===================================================="
    Write-Host "This script will:"
    Write-Host "  1. Close SimAppPro."
    Write-Host "  2. Add 'F-14B(U)' to SimAppPro's aircraft list (one file in Program"
    Write-Host "     Files - a backup named app.asar.bak is created first)."
    Write-Host "  3. Create F-14B(U) vibration curves (pilot and RIO seats) from the"
    Write-Host "     F-14B profile already in your SimAppPro installation."
    Write-Host "  4. Carry over your own tuned F-14B curves, if you have any."
    Write-Host "  5. Restart SimAppPro."
    Write-Host ""
    Write-Host "It downloads nothing, sends nothing, and everything is reversible"
    Write-Host "(see README.md). Feel free to read this script before continuing."
    Write-Host ""
    Read-Host "Press Enter to continue (or close this window to cancel)"
    # app.asar lives in Program Files, so re-launch ourselves elevated
    Write-Host "Requesting administrator rights (needed for step 2)..."
    Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -NoExit -File `"$PSCommandPath`""
    exit
}

$sap = 'C:\Program Files (x86)\SimAppPro'
if (-not (Test-Path "$sap\SimAppPro.exe")) {
    $sap = Read-Host "SimAppPro not found in the default location. Enter its install folder"
    if (-not (Test-Path "$sap\SimAppPro.exe")) { throw "SimAppPro.exe not found in '$sap'" }
}
$asar   = "$sap\resources\app.asar"
$events = "$sap\resources\app.asar.unpacked\Events\DynamicVibrationMotor\DCS"
$shake  = "$env:APPDATA\SimAppPro\ShakeEffect"
$donor  = 'F-14B'   # WinWing's own Tomcat profile - the ideal starting point
$units  = @('F-14BU', 'F-14BU_RIO')

Write-Host "Closing SimAppPro..."
Stop-Process -Name SimAppPro, SimLogic, WWTMap -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 4
Stop-Process -Name SimAppPro, SimLogic, WWTMap -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# ---- 1. patch the aircraft list inside app.asar -----------------------------
# The replaced entry ("MiG-29", bare) maps a module folder name that modern DCS
# installs no longer use - "MiG-29A", "MiG-29-Fulcrum" and "Flaming Cliffs"
# all have their own separate entries and are untouched. The replacement is
# byte-length identical, so the asar file index stays valid.
$oldStr = '"MiG-29":["MiG-29"]'
$newStr = '"F14BU": ["F-14BU"]'
if ($oldStr.Length -ne $newStr.Length) { throw "internal error: patch strings differ in length" }

$enc   = [Text.Encoding]::GetEncoding(28591)  # Latin-1: 1 char == 1 byte
$bytes = [IO.File]::ReadAllBytes($asar)
$text  = $enc.GetString($bytes)

if ($text.Contains('"F14BU"')) {
    Write-Host "app.asar already lists the F-14B(U) - skipping patch."
} elseif (-not $text.Contains($oldStr)) {
    Write-Warning "Aircraft map not found in app.asar (SimAppPro update changed it?). Skipping patch - the F-14B(U) tile may not appear, but in-game vibration will still work."
} else {
    if (-not (Test-Path "$asar.bak")) {
        Write-Host "Backing up app.asar -> app.asar.bak (this can take a moment)..."
        Copy-Item $asar "$asar.bak"
    }
    $newBytes = $enc.GetBytes($newStr)
    $count = 0
    $idx = $text.IndexOf($oldStr, [StringComparison]::Ordinal)
    while ($idx -ge 0) {
        [Array]::Copy($newBytes, 0, $bytes, $idx, $newBytes.Length)
        $count++
        $idx = $text.IndexOf($oldStr, $idx + 1, [StringComparison]::Ordinal)
    }
    [IO.File]::WriteAllBytes($asar, $bytes)
    Write-Host "Patched app.asar ($count occurrence(s)). Backup: app.asar.bak"
}
$bytes = $null; $text = $null

# ---- 2. default vibration curves for both seats ------------------------------
if (-not (Test-Path "$events\$donor")) {
    Write-Warning "F-14B donor profile not found in SimAppPro - is your SimAppPro up to date?"
} else {
    foreach ($unit in $units) {
        if (-not (Test-Path "$events\$unit")) {
            Copy-Item "$events\$donor" "$events\$unit" -Recurse
            Write-Host "Created default profile: Events\...\DCS\$unit (from $donor)"
        }
        if ((Test-Path "$shake\default\DCS") -and -not (Test-Path "$shake\default\DCS\$unit")) {
            Copy-Item "$shake\default\DCS\$donor" "$shake\default\DCS\$unit" -Recurse -ErrorAction SilentlyContinue
        }
    }
}

# ---- 3. carry over the user's own tuned F-14B curves -------------------------
if (Test-Path "$shake\active\DCS\$donor") {
    foreach ($unit in $units) {
        if (-not (Test-Path "$shake\active\DCS\$unit")) {
            Copy-Item "$shake\active\DCS\$donor" "$shake\active\DCS\$unit" -Recurse
            Write-Host "Carried over your tuned F-14B curves -> $unit"
        } else {
            Write-Host "Keeping your existing $unit curves."
        }
    }
}

Write-Host "Starting SimAppPro..."
Start-Process "$sap\SimAppPro.exe"
Write-Host ""
Write-Host "Done! Select DCS on the vibration page - the F-14B(U) tile should now be there." -ForegroundColor Green
Write-Host "To undo the app.asar patch: restore resources\app.asar.bak over app.asar."
