function Get-DbDocumentVersionsByGuid {
    <#
    .SYNOPSIS
    Retrieves all LiteDB documents that share the same Guid (application-level object identifier).

    .DESCRIPTION
    This command looks up all documents in the specified collection matching a given `Guid`. 
    It then sorts them by the `UTC_Updated` timestamp in descending order, so the most 
    recently updated version appears at index 0.

    This is useful for scenarios where multiple versions of the same application object 
    (identified by `Guid`) exist, each with its own unique `Hash`.

    .PARAMETER Connection
    The active LiteDB.LiteDatabase connection object.

    .PARAMETER CollectionName
    The name of the collection to query.

    .PARAMETER Guid
    The application-level object identifier (`Guid`) for which you want 
    to retrieve all record versions.

    .EXAMPLE
    Get-DbDocumentVersionsByGuid -Connection $db -CollectionName 'Domains' -Guid 2a1f9e5b-d6b2-478f-9bea-aab25298044c

    .NOTES
    Returns a collection (array) of matching documents as PSCustomObjects, 
    sorted by `UTC_Updated` (descending). If no matches are found, 
    returns an empty array.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [LiteDB.LiteDatabase] $Database,

        [Parameter(Mandatory)]
        $Collection,

        [switch]$ResolveRefs,

        [switch]$AsDbObject,

        [Parameter(Mandatory, ValueFromPipeline)]
        [Guid] $Guid
    )

    process {
        # Query all documents matching the provided Guid
        $results = Get-LiteData -Collection $Collection -Where 'Guid = @Guid', @{Guid = $Guid} -As PS

        if (-not $results) {
            return @()  # Return empty array if no documents found
        }

        # Sort by UTC_Updated in descending order (most recent first)
        $sortedResults = $results | Sort-Object '$ObjVer' -Descending

        if ($ResolveRefs) {
            $resolvedResults = $sortedResults | ForEach-Object {
                if ($_.PSObject.Properties.Name -contains '$Ref') {
                    $_ | Get-DbHashRef -Database $Database -Collection $Collection
                }
                else {
                    $_
                }
            }

            Write-Output $resolvedResults
        }
        elseif ($AsDbObject) {
            $resolvedResults = $sortedResults | ForEach-Object {
                if ($_.PSObject.Properties.Name -contains '$Ref' -and $_.PSObject.Properties.Name -contains '$Hash') {
                    ($return = $_ | Get-DbHashRef -Database $Database -Collection $Collection) | Out-Null
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