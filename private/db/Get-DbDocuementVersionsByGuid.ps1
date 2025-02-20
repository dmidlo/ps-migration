function Get-DbDocumentVersionsByGuid {
    <#
    .SYNOPSIS
    Retrieves all LiteDB documents that share the same Guid (application-level object identifier).

    .DESCRIPTION
    This command looks up all documents in the specified collection matching a given `Guid`. 
    It then sorts them by the `META_UTCUpdated` timestamp in descending order, so the most 
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
    sorted by `META_UTCUpdated` (descending). If no matches are found, 
    returns an empty array.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [LiteDB.LiteDatabase] $Connection,

        [Parameter(Mandatory)]
        [string] $CollectionName,

        [switch]$ResolveRefs,

        [Parameter(Mandatory, ValueFromPipeline)]
        [Guid] $Guid
    )

    process {
        # Query all documents matching the provided Guid
        $results = Find-LiteDBDocument `
            -Collection $CollectionName `
            -Connection $Connection `
            -Where "Guid = '$($Guid)'" `
            -Select "*" `
            -As PSObject

        if (-not $results) {
            return @()  # Return empty array if no documents found
        }

        # Sort by META_UTCUpdated in descending order (most recent first)
        $sortedResults = $results | Sort-Object META_UTCUpdated -Descending

        if ($ResolveRefs) {
            $resolvedResults = $sortedResults | ForEach-Object {
                $data = Normalize-Data -InputObject $_ -IgnoreFields @('none')
                if ($data.Keys -contains '$Ref') {
                    Write-Host "Resolving."
                    $data | Get-DbHashRef -Connection $Connection
                }
                else {
                    Write-Host "record not ref."
                    $data
                }
            }

            Write-Output $resolvedResults
        }
        else {
            Write-Output $sortedResults
        }
    }
}