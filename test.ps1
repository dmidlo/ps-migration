Clear-Host
Import-Module .\ps-migration.psd1 -Force
Clear-Host
start-psMigration -Dev -Clear -ResetDatabase -Test