function Initialize-BundleRegistry {
    param(
        [LiteDB.LiteDatabase]$Database,
        [string]$RegistryName = '_bundles'
    )

    Initialize-LiteDBCollection -Database $Database -CollectionName $RegistryName -Indexes @(
        [PSCustomObject]@{ Field="VersionId"; Unique=$true },
        [PSCustomObject]@{ Field="BundleId"; Unique=$false },
        [PSCustomObject]@{ Field="ContentMark"; Unique=$false }
    )
    return (Get-LiteCollection -Database $Database -CollectionName $RegistryName)
}