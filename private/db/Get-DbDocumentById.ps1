function Get-DbDocumentById {
    <#
    .SYNOPSIS
    Retrieves a single LiteDB document by its _id.

    .PARAMETER Connection
    Active LiteDB.LiteDatabase object.

    .PARAMETER CollectionName
    The target LiteDB collection name.

    .PARAMETER Id
    The LiteDB _id value to look up. Adjust type if needed 
    (e.g., [String], [int], or [LiteDB.ObjectId]).

    .EXAMPLE
    Get-DbDocumentById -Connection $db -CollectionName 'Domains' -Id 123
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [LiteDB.LiteDatabase] $Connection,

        [Parameter(Mandatory)]
        [string] $CollectionName,

        [Parameter(Mandatory, ValueFromPipeline)]
        [Object] $Id
    )

    process {

        $result = Find-LiteDBDocument `
            -Collection $CollectionName `
            -Connection $Connection `
            -ID $Id `
            -As PSObject

        if (-not $result) {
            return $null
        }

        # If multiple found (unexpected for an _id), return first + warning
        if ($result.Count -gt 1) {
            Write-Warning "Multiple documents found for _id '$Id'. Returning the first match."
            Write-Output $result | Select-Object -First 1
        }
        Write-Output $result
    }
}
