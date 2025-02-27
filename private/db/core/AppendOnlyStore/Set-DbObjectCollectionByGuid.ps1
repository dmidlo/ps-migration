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
        $dbObject = $Guid | Get-DbDocumentVersionsByGuid -Database $Database -Collection $Collection
        $dbObject = $dbObject | Where-Object { $_.PSObject.Properties.Name -notcontains '$Ref'}        

        foreach ($version in $dbObject) {
            $props = $version.PSObject.Properties.Name

            if ($props -contains '$Ref') {
                throw "Should be a real object version not a DbRef."
            }

            if ($props -contains '$hashArcs') {
                foreach ($hashArc in $version.'$hashArcs') {
                    # If it is a ref for the same App Object move the ref too
                    # refs store a copy of themselves in hashArcs, the actual 
                    # DbRef is still in its home collection (RefCol). It must be
                    # moved as well.
                    if ($hashArc.Guid -eq $Guid) {
                        $RefCollection = Get-LiteCollection -Database $Database -CollectionName $hashArc.RefCol
                        ($baseHashArc = $hashArc.Hash | Get-DbDocumentByHash -Database $Database -Collection $RefCollection) | Out-Null
                        $baseHashArc
                        $hashArc.RefCol = $DestCollection.Name
                        $hashArc.'$Ref' = $DestCollection.Name
                        
                    }
                }
                
                $version
            }

            if ($props -contains '$guidArcs') {
                $version | Out-Null
            }

        }
    }
}