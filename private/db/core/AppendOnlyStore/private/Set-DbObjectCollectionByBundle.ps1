function Set-DbObjectCollectionByBundle {
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

        [switch]$NoTimestampUpdate
    )

    process {
        ($dbObject = $BundleId | Get-DbDocumentVersionsByBundle -Database $Database -Collection $SourceCollection) | Out-Null
        ($dbObject = $dbObject | Where-Object { $_.PSObject.Properties.Name -notcontains '$Ref'}) | Out-Null

        $firstBundleArc = $true

        foreach ($version in $dbObject) {
            try {
                ($props = $version.PSObject.Properties.Name) | Out-Null
                ($stagedVersion = $version.VersionId | Get-DbDocumentByVersionId -Database $Database -Collection $SourceCollection) | Out-Null

                if ($props -contains '$Ref') {
                    throw "Should be a real object version not a DbRef."
                }

                if ($props -contains '$VersionArcs') {
                    ($stagedVersion.'$VersionArcs' = [System.Collections.ArrayList]::New()) | Out-Null

                    foreach ($VersionArc in $version.'$VersionArcs') {
                        # If it is a ref for the same App Object move the ref too
                        # refs store a copy of themselves in VersionArcs, the actual 
                        # DbRef is still in its home collection (RefCol). It must be
                        # moved as well.
                        ($RefCollection = Get-LiteCollection -Database $Database -CollectionName $VersionArc.RefCol) | Out-Null
                        ($stagedVersionArc = $VersionArc.VersionId | Get-DbDocumentByVersionId -Database $Database -Collection $RefCollection) | Out-Null
                        if ($stagedVersionArc.PSObject.Properties.Name -notcontains '$Ref') {
                            ($stagedVersionArc = $VersionArc.VersionId | Get-DbDocumentByVersionId -Database $Database -Collection $DestCollection) | Out-Null
                        }
                        ($stagedVersionArc.'$Ref' = $DestCollection.Name) | Out-Null

                        if ($VersionArc.BundleId -eq $BundleId) {
                            ($stagedVersionArc.RefCol = $DestCollection.Name) | Out-Null
                            $stagedVersion.'$VersionArcs'.Add($stagedVersionArc) | Out-Null
                            ($IsAlreadyPresent_VersionArc = $stagedVersionArc.VersionId | Get-DbDocumentByVersionId -Database $Database -Collection $DestCollection) | Out-Null
                            if (-not $IsAlreadyPresent_VersionArc) {
                                Add-DbDocument -Database $Database -Collection $DestCollection -Data $stagedVersionArc -NoVersionUpdate:$NoVersionUpdate.IsPresent -NoTimestampUpdate:$NoTimestampUpdate.IsPresent | Out-Null
                            }
                            Remove-LiteData -Collection $SourceCollection -Where 'VersionId = @VersionId', @{VersionId = $VersionArc.VersionId} | Out-Null
                        }
                        else {
                            $stagedVersion.'$VersionArcs'.Add($stagedVersionArc) | Out-Null
                            Set-LiteData -Collection $VersionArc.RefCol -InputObject $stagedVersionArc | Out-Null
                        }
                    }
                }
                
                if ($props -contains '$BundleArcs') {
                    $stagedVersion.'$BundleArcs' = [System.Collections.ArrayList]::New()

                    foreach ($BundleArc in $version.'$BundleArcs') {
                        $RefCollection = $null
                        if ($firstBundleArc) {
                            ($RefCollection = Get-LiteCollection -Database $Database -CollectionName $BundleArc.RefCol) | Out-Null
                            $firstBundleArc = $false
                        } else {
                            ($RefCollection = Get-LiteCollection -Database $Database -CollectionName $DestCollection.Name) | Out-Null
                        }
                        ($stagedBundleArc = $BundleArc.VersionId | Get-DbDocumentByVersionId -Database $Database -Collection $RefCollection) | Out-Null
                        $stagedBundleArc.'$Ref' = $DestCollection.Name

                        if ($BundleArc.BundleId -eq $BundleId){
                            # This part here allows for self-referencing Bundles
                            $stagedBundleArc.RefCol = $DestCollection.Name
                            $stagedVersion.'$BundleArcs'.Add($stagedBundleArc) | Out-Null
                            $IsAlreadyPresent_BundleArc = $stagedBundleArc.VersionId | Get-DbDocumentByVersionId -Database $Database -Collection $DestCollection
                            if(-not $IsAlreadyPresent_BundleArc) {
                                Add-DbDocument -Database $Database -Collection $DestCollection -Data $stagedBundleArc -NoVersionUpdate:$NoVersionUpdate.IsPresent -NoTimestampUpdate:$NoTimestampUpdate.IsPresent | Out-Null
                            }
                            Remove-LiteData -Collection $SourceCollection -Where 'VersionId = @VersionId', @{VersionId = $BundleArc.VersionId} | Out-Null
                        }
                        else {
                            $stagedVersion.'$BundleArcs'.Add($stagedBundleArc) | Out-Null
                            Set-LiteData -Collection $BundleArc.RefCol -InputObject $stagedBundleArc | Out-Null
                        }
                    }
                }
                
                ($IsAlreadyPresent_version = $stagedVersion.VersionId | Get-DbDocumentByVersionId -Database $Database -Collection $DestCollection) | Out-Null
                if (-not $IsAlreadyPresent_version) {
                    Add-DbDocument -Database $Database -Collection $DestCollection -Data $stagedVersion -NoVersionUpdate:$NoVersionUpdate.IsPresent -NoTimestampUpdate:$NoTimestampUpdate.IsPresent | Out-Null
                }
                Remove-LiteData -Collection $SourceCollection -Where 'VersionId = @VersionId', @{VersionId = $version.VersionId} | Out-Null
            }
            catch {
                throw $_
            }
        }
    }
}