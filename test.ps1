Clear-Host
. ".\build.ps1"
Import-Module ps-migration -Force
Clear-Host
Start-PsMigration -Dev -Clear -ResetDatabase -Test