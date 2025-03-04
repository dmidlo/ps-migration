function Set-DbObjectCollectionByGuid {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        $Guid,

        [Parameter(Mandatory)]
        $Database,

        [Parameter(Mandatory)]
        $SourceCollection,

        [Parameter(Mandatory)]
        $DestCollection
    )

    process {
        ($dbObject = $Guid | Get-DbDocumentVersionsByGuid -Database $Database -Collection $SourceCollection) | Out-Null
        ($dbObject = $dbObject | Where-Object { $_.PSObject.Properties.Name -notcontains '$Ref'}) | Out-Null

        $firstGuidArc = $true

        foreach ($version in $dbObject) {
            ($props = $version.PSObject.Properties.Name) | Out-Null
            ($stagedVersion = $version.Hash | Get-DbDocumentByHash -Database $Database -Collection $SourceCollection) | Out-Null

            if ($props -contains '$Ref') {
                throw "Should be a real object version not a DbRef."
            }

            if ($props -contains '$hashArcs') {
                ($stagedVersion.'$hashArcs' = [System.Collections.ArrayList]::New()) | Out-Null

                foreach ($hashArc in $version.'$hashArcs') {
                    # If it is a ref for the same App Object move the ref too
                    # refs store a copy of themselves in hashArcs, the actual 
                    # DbRef is still in its home collection (RefCol). It must be
                    # moved as well.
                    ($RefCollection = Get-LiteCollection -Database $Database -CollectionName $hashArc.RefCol) | Out-Null
                    ($stagedHashArc = $hashArc.Hash | Get-DbDocumentByHash -Database $Database -Collection $RefCollection) | Out-Null
                    if ($stagedHashArc.PSObject.Properties.Name -notcontains '$Ref') {
                        ($stagedHashArc = $hashArc.Hash | Get-DbDocumentByHash -Database $Database -Collection $DestCollection) | Out-Null
                    }
                    ($stagedHashArc.'$Ref' = $DestCollection.Name) | Out-Null

                    if ($hashArc.Guid -eq $Guid) {
                        ($stagedHashArc.RefCol = $DestCollection.Name) | Out-Null
                        $stagedVersion.'$hashArcs'.Add($stagedHashArc) | Out-Null
                        ($IsAlreadyPresent_hashArc = $stagedHashArc.Hash | Get-DbDocumentByHash -Database $Database -Collection $DestCollection) | Out-Null
                        if (-not $IsAlreadyPresent_hashArc) {
                            Add-DbDocument -Database $Database -Collection $DestCollection -Data $stagedHashArc -NoVersionUpdate -NoTimestampUpdate | Out-Null
                        }
                        Remove-LiteData -Collection $SourceCollection -Where 'Hash = @Hash', @{Hash = $hashArc.Hash} | Out-Null
                    }
                    else {
                        $stagedVersion.'$hashArcs'.Add($stagedHashArc) | Out-Null
                        Set-LiteData -Collection $hashArc.RefCol -InputObject $stagedHashArc | Out-Null
                    }
                }
            }
            
            if ($props -contains '$guidArcs') {
                $stagedVersion.'$guidArcs' = [System.Collections.ArrayList]::New()

                foreach ($guidArc in $version.'$guidArcs') {
                    $RefCollection = $null
                    if ($firstGuidArc) {
                        ($RefCollection = Get-LiteCollection -Database $Database -CollectionName $guidArc.RefCol) | Out-Null
                        $firstGuidArc = $false
                    } else {
                        ($RefCollection = Get-LiteCollection -Database $Database -CollectionName $DestCollection.Name) | Out-Null
                    }
                    ($stagedGuidArc = $guidArc.Hash | Get-DbDocumentByHash -Database $Database -Collection $RefCollection) | Out-Null
                    $stagedGuidArc.'$Ref' = $DestCollection.Name

                    if ($guidArc.Guid -eq $Guid){
                        # This part here allows for self-referencing guids
                        $stagedGuidArc.RefCol = $DestCollection.Name
                        $stagedVersion.'$guidArcs'.Add($stagedGuidArc) | Out-Null
                        $IsAlreadyPresent_guidArc = $stagedGuidArc.Hash | Get-DbDocumentByHash -Database $Database -Collection $DestCollection
                        if(-not $IsAlreadyPresent_guidArc) {
                            Add-DbDocument -Database $Database -Collection $DestCollection -Data $stagedGuidArc -NoVersionUpdate -NoTimestampUpdate | Out-Null
                        }
                        Remove-LiteData -Collection $SourceCollection -Where 'Hash = @Hash', @{Hash = $guidArc.Hash} | Out-Null
                    }
                    else {
                        $stagedVersion.'$guidArcs'.Add($stagedGuidArc) | Out-Null
                        Set-LiteData -Collection $guidArc.RefCol -InputObject $stagedGuidArc | Out-Null
                    }
                }
            }
            
            ($IsAlreadyPresent_version = $stagedVersion.Hash | Get-DbDocumentByHash -Database $Database -Collection $DestCollection) | Out-Null
            if (-not $IsAlreadyPresent_version) {
                Add-DbDocument -Database $Database -Collection $DestCollection -Data $stagedVersion -NoVersionUpdate -NoTimestampUpdate | Out-Null
            }
            Remove-LiteData -Collection $SourceCollection -Where 'Hash = @Hash', @{Hash = $version.Hash} | Out-Null
        }
    }
}