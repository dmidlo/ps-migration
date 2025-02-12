function Normalize-Dictionary {
    <#
    .SYNOPSIS
        Normalizes a PowerShell dictionary by sorting keys and removing specified fields.

    .DESCRIPTION
        - Removes fields specified in `$IgnoreFields`.
        - Sorts dictionary keys deterministically.
        - Recursively normalizes values using `Normalize-Data`.

    .PARAMETER Dictionary
        The input dictionary (hashtable or PSCustomObject) to be normalized.

    .PARAMETER IgnoreFields
        A hash set of field names to be excluded.

    .OUTPUTS
        A new, normalized dictionary.
    #> 
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [object] $Dictionary,  

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.Collections.Generic.HashSet[string]] $IgnoreFields
    )

    # 1. If the input is *actually* an IDictionary, just use it as-is.
    if ($Dictionary -is [System.Collections.IDictionary]) {
        $hashTable = $Dictionary
    }
    # 2. Otherwise, if it's a PSCustomObject but *not* a pure dictionary, extract its note properties:
    elseif ($Dictionary -is [PSCustomObject]) {
        $temp = @{}
        foreach ($property in $Dictionary.PSObject.Properties) {
            if (-not $IgnoreFields.Contains($property.Name)) {
                $temp[$property.Name] = $property.Value
            }
        }
        $hashTable = $temp
    }
    else {
        throw "Expected IDictionary or PSCustomObject, but got [$($Dictionary.GetType().FullName)]"
    }

    if ($hashTable -isnot [System.Collections.IDictionary]) {
        throw "Expected IDictionary or PSCustomObject, but got [$($hashTable.GetType().FullName)]"
    }

    # 3. Sort keys safely even with mixed types
    $sortedKeys = @($hashTable.Keys) | Sort-Object { $_.ToString() }

    $normalizedDict = [Ordered]@{}

    foreach ($key in $sortedKeys) {
        if (-not $IgnoreFields.Contains($key)) {
            $value = $hashTable[$key]
            $normalizedValue = Normalize-Data -InputObject $value -IgnoreFields $IgnoreFields

            if (
                $normalizedValue -is [System.Collections.IEnumerable] -and
                $normalizedValue -isnot [string]               -and
                $normalizedValue -isnot [System.Collections.IDictionary]
            ) {
                # Only wrap if it is not already an array.
                if (-not ($normalizedValue -is [System.Array])) {
                    $normalizedDict.Add($key.ToString(), @($normalizedValue))
                }
                else {
                    $normalizedDict.Add($key.ToString(), $normalizedValue)
                }
            }
            else {
                $normalizedDict.Add($key.ToString(), $normalizedValue)
            }
        }
    }

    return $normalizedDict
}
