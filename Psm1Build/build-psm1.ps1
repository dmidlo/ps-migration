function __import_enums {
    $enums = @(
        "private\bin\powershell\Networking\GetMacAddressAnalysis\Types\MacAddressType.ps1"
        "private\bin\powershell\Networking\GetMacAddressAnalysis\Types\MacAddressOriginType.ps1"
        "private\db\core\AppendOnlyStore\Types\dbVersionSteps.ps1",
        "private\db\models\Types\ComponentType.ps1",
        "private\db\models\Types\PhysicalAddressPurpose.ps1",
        "private\db\models\Types\PhysicalAddressType.ps1"
    )
    return $enums
}

function __import_dotsourcing {
    $dotsourceImports = @(
        "Psm1Build\dotsource_imports.ps1"
    )
    return $dotsourceImports
}

function __import_classes {
    $classes = @(
        "private\bin\powershell\Networking\GetMacAddressAnalysis\Types\MacAddressAnalyzer.ps1"
        "private\db\core\AppendOnlyStore\Types\LiteDbAppendOnlyCollection.ps1",
        "private\db\core\AppendOnlyStore\Types\LiteDbAppendOnlyDocument.ps1",
        "private\db\models\Types\PhysicalAddress.ps1"
    )
    return $classes
}

function __exports {
    $moduleExports = @(
        "Psm1Build\module_exports.ps1"
    )
    return $moduleExports
}

function Add-ToPsm1 {
    param (
        [string]$psm1Path,
        [string[]]$scriptPaths
    )

    foreach ($script in $scriptPaths) {
        if (Test-Path -Path $script) {
            Get-Content -Path $script -Raw | Add-Content -Path $psm1Path
        } else {
            Write-Warning "Missing file: $script"
        }
    }
}
