Clear-Host
. ".\Psm1Build\build-psm1.ps1"
$psm1Path = "$PSScriptRoot\ps-migration.psm1"

if (-not (Test-Path -Path $psm1Path)) {
    $null = New-Item -ItemType File -Path $psm1Path -Force
}
Set-Content -Path $psm1Path -Value "" -Encoding utf8


Add-ToPsm1 $psm1Path (__import_enums)         # Enums first
Add-ToPsm1 $psm1Path (__import_dotsourcing)   # Dot-sourced scripts
Add-ToPsm1 $psm1Path (__import_classes)       # Class definitions
Add-ToPsm1 $psm1Path (__import_dotsourcing)   # Dot-sourced scripts again as a jank hack (thanks interpreter!)
Add-ToPsm1 $psm1Path (__exports)              # Module exports

Write-Host "PSM1 build completed successfully: $psm1Path" -ForegroundColor Green