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

        [switch]$NoVersionUpdate,

        [switch]$NoTimestampUpdate,

        [switch]$UseBundleRegistry
    )

    process {
        ($dbObject = $BundleId | Get-DbDocumentVersionsByBundle -Database $Database -Collection $SourceCollection) | Out-Null

        $Database.beginTrans()
        try {
            foreach ($version in $dbObject) {
                try {
                    ($props = $version.PSObject.Properties.Name) | Out-Null
                    ($stagedVersion = $version.VersionId | Get-DbDocumentByVersion -Database $Database -Collection $SourceCollection) | Out-Nul
                    
                    ($IsAlreadyPresent_version = $stagedVersion.VersionId | Get-DbDocumentByVersion -Database $Database -Collection $DestCollection) | Out-Null
                    if (-not $IsAlreadyPresent_version) {
                        $AddParams = @{
                            Database = $Database
                            Collection = $DestCollection
                            Data = $stagedVersion
                            NoVersionUpdate = $NoVersionUpdate.IsPresent
                            NoTimestampUpdate = $NoTimestampUpdate.IsPresent
                            UseBundleRegistry = $UseBundleRegistry.IsPresent
                            UseTransaction = $false
                        }
                        $null = Add-DbDocument @AddParams
                    }
                    Remove-LiteData -Collection $SourceCollection -Where 'VersionId = @VersionId', @{VersionId = $version.VersionId} | Out-Null
                }
                catch {
                    throw $_
                }
            }
            $Database.Commit()
        }
        catch {
            $Database.rollback()
            throw $_
        }
    }
}