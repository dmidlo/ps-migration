function Set-DbBundleCollection {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        $BundleId,

        [Parameter(Mandatory)]
        $Database,

        [Parameter(Mandatory)]
        $SourceCollection,

        [Parameter(Mandatory)]
        $DestCollection,

        [bool]$NoVersionUpdate = $true,

        [bool]$NoTimestampUpdate = $true,

        [bool]$UseBundleRegistry = $true
    )

    process {
        $null = ($dbObject = $BundleId | Get-DbDocumentVersionsByBundle -Database $Database -Collection $SourceCollection)

        $Database.beginTrans()
        try {
            foreach ($version in $dbObject) {
                try {
                    $null = ($props = $version.PSObject.Properties.Name)
                    $null = ($stagedVersion = $version.VersionId | Get-DbDocumentByVersion -Database $Database -Collection $SourceCollection)
                    
                    $null = ($IsAlreadyPresent_version = $stagedVersion.VersionId | Get-DbDocumentByVersion -Database $Database -Collection $DestCollection)
                    if (-not $IsAlreadyPresent_version) {
                        $AddParams = @{
                            Database = $Database
                            Collection = $DestCollection
                            Data = $stagedVersion
                            NoVersionUpdate = $NoVersionUpdate
                            NoTimestampUpdate = $NoTimestampUpdate
                            UseBundleRegistry = $UseBundleRegistry
                            UseTransaction = $false
                        }
                        $null = Add-DbDocument @AddParams
                    }
                    $null = Remove-LiteData -Collection $SourceCollection -Where 'VersionId = @VersionId', @{VersionId = $version.VersionId}
                }
                catch {
                    throw $_
                }
            }
            $Database.Commit()
            $out = Get-DbDocumentVersionsByBundle -Database $Database -Collection $DestCollection -BundleId $BundleId
            return $out
        }
        catch {
            $Database.rollback()
            throw $_
        }
    }
}