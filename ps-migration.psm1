enum dbComponentType {
    Component
    Chassis
    Module
    Interface
}

# Module Utilities
$utilitiesFolders = @("private")
foreach ($utilitiesFolder in $utilitiesFolders) {
    Get-ChildItem -Recurse "$PSScriptRoot\$utilitiesFolder\*.ps1" -File | ForEach-Object {
        . $_.FullName
    }
}

# Exported Functions
$exportFolders = @("public")
foreach ($exportFolder in $exportFolders) {
    Get-ChildItem -Recurse "$PSScriptRoot\$exportFolder\*.ps1" -File | ForEach-Object {
        . $_.FullName
    }
}

# Export public functions from this module
Export-ModuleMember -Function * -Alias *
