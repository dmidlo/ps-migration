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
        
        foreach ($version in $dbObject) {
            $props = $version.PSObject.Properties.Name

            if ($props -contains '$Ref') {
                if($props -contains '$Hash') {
                    $version
                }
                elseif ($props -contains '$Guid') {
                    $version | Out-Null
                }
            }
            else {
                $version | Out-Null
            }

            if ($props -contains '$hashArcs') {
                $version | Out-Null
            }

            if ($props -contains '$guidArcs') {
                $version | Out-Null
            }
        }
    }
}