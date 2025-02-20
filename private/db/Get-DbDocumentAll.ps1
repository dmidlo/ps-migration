function Get-DbDocumentAll {
    <#
    .SYNOPSIS
    Returns all documents in the specified LiteDB collection.

    .PARAMETER Connection
    Active LiteDB.LiteDatabase object.

    .PARAMETER CollectionName
    The target LiteDB collection name.

    .EXAMPLE
    Get-DbDocumentAll -Connection $db -CollectionName 'Domains'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [LiteDB.LiteDatabase] $Connection,

        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $Collection
    )

    process {
        $result = Find-LiteDBDocument $Collection -Connection $Connection -As PSObject

        # If none found, returns empty array
        Write-Output $result
    }
}
