function Get-DbDocumentVersionsByBundle {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [LiteDB.LiteDatabase] $Database,

        [Parameter(Mandatory)]
        $Collection,

        [switch]$ResolveRefs,

        [switch]$AsDbObject,

        [Parameter(Mandatory, ValueFromPipeline)]
        [Guid] $BundleId
    )

    process {
        # Query all documents matching the provided BundleId
        $results = Get-LiteData -Collection $Collection -Where 'BundleId = @BundleId', @{BundleId = $BundleId} -As PS

        if (-not $results) {
            return @()  # Return empty array if no documents found
        }

        # Sort by UTC_Updated in descending order (most recent first)
        $sortedResults = $results | Sort-Object '$ObjVer' -Descending

        if ($ResolveRefs) {
            $resolvedResults = $sortedResults | ForEach-Object {
                if ($_.PSObject.Properties.Name -contains '$Ref') {
                    $_ | Get-DbVersionRef -Database $Database -Collection $Collection
                }
                else {
                    $_
                }
            }

            Write-Output $resolvedResults
        }
        elseif ($AsDbObject) {
            $resolvedResults = $sortedResults | ForEach-Object {
                if ($_.PSObject.Properties.Name -contains '$Ref' -and $_.PSObject.Properties.Name -contains '$VersionId') {
                    ($return = $_ | Get-DbVersionRef -Database $Database -Collection $Collection) | Out-Null
                    ($return.UTC_Updated = $_.UTC_Updated) | Out-Null
                    ($return.'$ObjVer' = $_.'$ObjVer') | Out-Null
                    $return
                }
                else {
                    $_
                }
            }

            Write-Output $resolvedResults
        }
        else {
            Write-Output $sortedResults
        }
    }
}