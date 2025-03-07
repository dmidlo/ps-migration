Clear-Host
. ".\build.ps1"
Import-Module .\ps-migration.psd1 -Force
Clear-Host
Start-PsMigration -Dev -Clear -ResetDatabase