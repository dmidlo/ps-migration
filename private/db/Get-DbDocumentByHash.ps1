function Get-DbDocumentByHash {
    <#
    .SYNOPSIS
    Retrieves a single LiteDB document by its unique Hash.

    .DESCRIPTION
    This command performs a **single-document** lookup based on the `Hash` field, which 
    is expected to be unique (within the given collection). If no document is found, 
    the function returns `$null`.

    .PARAMETER Connection
    The active LiteDB.LiteDatabase connection object.

    .PARAMETER CollectionName
    The name of the collection to query.

    .PARAMETER Hash
    The unique record identifier (application-level). This function assumes 
    `Hash` is unique in the specified collection.

    .EXAMPLE
    Get-DbDocumentByHash -Connection $db -CollectionName 'Domains' -Hash '836ACF9340B24BD98B82EB882C585C57'

    .NOTES
    Returns the single matching document as a PSCustomObject or `$null` if not found.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [LiteDB.LiteDatabase] $Connection,

        [Parameter(Mandatory)]
        [string] $CollectionName,

        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $Hash
    )

    process {
        # Perform a direct lookup by Hash using your existing helper
        $result = Find-LiteDBDocument `
            -Collection $CollectionName `
            -Connection $Connection `
            -Where "Hash = '$($Hash)'" `
            -Select "*" `

        if (-not $result) {
            # Return null if nothing is found
            return $null
        }

        Write-Host "============================ BSON"
        # $result = [PSCustomObject]($result.ToString() | ConvertFrom-Json)
        # If multiple records somehow matched, assume the first is the canonical
        if ($result.Count -gt 1) {
            Write-Warning "Multiple documents found for Hash '$Hash'. Returning the first match."
            Write-Output (Normalize-Data -InputObject ($result | Select-Object -First 1) -IgnoreFields @('none'))
        }
        Write-Output (Normalize-Data -InputObject $result -IgnoreFields @('none'))
    }

}
