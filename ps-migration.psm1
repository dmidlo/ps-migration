# Import Pode-related stuff:

# ## Import Pode-Related Stuff
# ## ...Pages, Widgets and Workflows I guess are views, and tasks are controllers... 
# ##      seperating as much as possible; this obviously a very "in-line" framework, not to mention language.
# $viewFolders = @("pages", "widgets", "workflows")
# foreach ($viewFolder in $viewFolders) {
#     Get-ChildItem -Recurse ".\$viewFolder\*.ps1" -File | ForEach-Object {
#         . $_.FullName
#     }
# }

# $controllerFolders = @("tasks")
# foreach ($controllerFolder in $controllerFolders) {
#     Get-ChildItem -Recurse ".\$controllerFolder\*.ps1" -File | ForEach-Object {
#         . $_.FullName
#     }
# }


# # Server stuff
# ## bin is for stand-alone scripts and binaries
# $scriptsFolders = @("bin")
# foreach ($scriptsFolder in $scriptsFolders) {
#     Get-ChildItem -Recurse ".\$scriptsFolder\*.ps1" -File | ForEach-Object {
#         . $_.FullName
#     }
# }

# ## Database - LiteDB furnished by PSLiteDB
# $dbFolders = @("db")
# foreach ($dbFolder in $dbFolders) {
#     Get-ChildItem -Recurse ".\$dbFolder\*.ps1" -File | ForEach-Object {
#         . $_.FullName
#     }
# }

# Module Utilities
$utilitiesFolders = @("private")
foreach ($utilitiesFolder in $utilitiesFolders) {
    Get-ChildItem -Recurse ".\$utilitiesFolder\*.ps1" -File | ForEach-Object {
        . $_.FullName
    }
}

# Exported Functions
$exportFolders = @("public")
foreach ($exportFolder in $exportFolders) {
    Get-ChildItem -Recurse ".\$exportFolder\*.ps1" -File | ForEach-Object {
        . $_.FullName
    }
}

# lol
$testFolders = @("tests")
foreach ($testFolder in $testFolders) {
    Get-ChildItem -Recurse ".\$testFolder\*.ps1" -File | ForEach-Object {
        . $_.FullName
    }
}


# If you have a vendored EXE in bin, you can reference it like:
# $vendoredPath = Join-Path . 'bin/your-vendored.exe'

# You can also have module-level initialization code here if needed

# Export public functions from this module
Export-ModuleMember -Function * -Alias *
