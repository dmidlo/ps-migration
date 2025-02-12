function Normalize-Data {
    <#
    .SYNOPSIS
        Normalizes a PowerShell object into a stable and canonical representation.

    .DESCRIPTION
        Produces a stable and canonical representation of an object by imposing
        a consistent ordering and excluding specified fields. Supports deeply
        nested structures.

    .PARAMETER InputObject
        The object to normalize.

    .PARAMETER IgnoreFields
        A hash set of field names to exclude from normalization.

    .OUTPUTS
        A normalized object with consistent ordering.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowNull()]
        [object] $InputObject,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.Collections.Generic.HashSet[string]] $IgnoreFields
    )

    # If it *is* a dictionary (hashtable) or obviously not a single-property scalar,
    # skip the unwrapping logic altogether.
    if ($InputObject -is [System.Collections.IDictionary]) {
        return Normalize-Dictionary -Dictionary $InputObject -IgnoreFields $IgnoreFields
    }

    if ($InputObject -is [PSCustomObject]) {
        $base = $InputObject.PSObject.BaseObject
        
        # If it is not a PSCustomObject, but is a single "scalar" object,
        # unwrap it so we don't treat "PSCustomObject(1)" as a dictionary.
        if ($base -isnot [PSCustomObject] -and $base.GetType().IsPrimitive) {
            $InputObject = $base
        }
        # Also treat strings as scalars (since IsPrimitive=$false for string).
        elseif ($base -is [string]) {
            $InputObject = $base
        }
        elseif ($base.GetType().IsArray) {
            $InputObject = $base
        }
    }

    if ($null -eq $InputObject) {
        return $null
    }

    # Remainder of the original logic:
    if ($InputObject -is [System.Collections.IDictionary] -or $InputObject -is [PSCustomObject]) {
        return Normalize-Dictionary -Dictionary $InputObject -IgnoreFields $IgnoreFields
    }

    if (Is-Enumerable -Value $InputObject) {
        return Normalize-List -List $InputObject -IgnoreFields $IgnoreFields
    }

    return $InputObject
}
