function Get-DataHash {
    <#
    .SYNOPSIS
        Computes a SHA-256 hash of a PowerShell object after normalizing its structure.

    .DESCRIPTION
        - Recursively normalizes a given PowerShell object by:
          - Removing specified fields (e.g., `_id`, `Guid`, `Hash`, etc.).
          - Sorting dictionary keys deterministically.
          - Sorting lists if they contain comparable scalar values.
          - Supports heterogeneous and deeply nested types.

        - Converts the normalized object to a JSON string.
        - Computes and returns the SHA-256 hash of the JSON string.

    .PARAMETER DataObject
        The input object to be normalized and hashed.

    .PARAMETER FieldsToIgnore
        An array of field names to be excluded from the normalization and hashing process.

    .PARAMETER Debug
        If specified, outputs intermediate debugging information.

    .OUTPUTS
        A hashtable containing:
        - `NormalizedData`: The processed object after normalization.
        - `Json`: The serialized JSON representation of the normalized object.
        - `Hash`: The computed SHA-256 hash.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [PSObject]$DataObject,

        [string[]]$FieldsToIgnore = @('_id', 'Guid', 'Hash', 'UTC_Created', 'UTC_Updated', 'Count', 'Length')

    )

    # Convert FieldsToIgnore array into a HashSet for O(1) lookups
    $ignoreFields = [System.Collections.Generic.HashSet[string]]::new($FieldsToIgnore, [System.StringComparer]::OrdinalIgnoreCase)

    if ($null -eq $DataObject) {
        $json = 'null'
        return @{
            NormalizedData = $null
            Json           = $json
            Hash           = Compute-HashSHA256 $json
        }
    }

    try {
        $normalizedData = Normalize-Data -InputObject $DataObject -IgnoreFields $ignoreFields
    }
    catch {
        throw "Normalization Error: $_"
    }

    try {
        $json = ConvertTo-Json -InputObject $normalizedData -Compress -Depth 50
    }
    catch {
        throw "JSON Serialization Error: $_"
    }

    # Compute the hash once and store
    $hash = Compute-HashSHA256 $json

    # Write-Host "`n=== Normalized Data ===`n$(ConvertTo-Json -InputObject $normalizedData -Depth 50 | Out-String)"
    # Write-Host "`n=== Serialized JSON ===`n$json"
    # Write-Host "`n=== Computed Hash ===`n$hash"

    return @{
        NormalizedData = $normalizedData
        Json           = $json
        Hash           = $hash
    }
}

