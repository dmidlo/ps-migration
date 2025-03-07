function Convert-ToNormalizedList {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.Collections.IEnumerable]$List,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.Collections.Generic.HashSet[string]]$IgnoreFields
    )

    # Step 1: Normalize each element
    $normalizedList = $List | ForEach-Object { Convert-ToNormalizedData -InputObject $_ -IgnoreFields $IgnoreFields }

    # Step 2: Extract non-null values
    $nonNullValues = $normalizedList | Where-Object { $_ -ne $null }

    # If no non-null values exist, return as-is
    if ($nonNullValues.Count -eq 0) {
        return $normalizedList
    }

    # Step 3: Ensure all non-null values are of the same type and sortable
    $firstType = $nonNullValues[0].GetType()
    $canSort = ($nonNullValues | ForEach-Object {
        $_ -is [System.IComparable] -and $_.GetType() -eq $firstType
    }) -notcontains $false

    if (-not $canSort) {
        #  sorting dictionaries by their canonical string form:
        # 1. Check if *all* non-null items are dictionaries:
        $allDicts = $true
        foreach ($item in $nonNullValues) {
            if ($item -isnot [System.Collections.IDictionary]) {
                $allDicts = $false
                break
            }
        }

        if ($allDicts) {
            # 2. Sort them by their canonical JSON representation
            #    (They are already "normalized," so the JSON keys will be in sorted order.)
            $sortedNonNulls = $nonNullValues |
                Sort-Object { ConvertTo-Json $_ -Depth 10 -Compress }

            # 3. Reinsert $nulls in their original positions
            $sortedIndex = 0
            $finalList = $normalizedList | ForEach-Object {
                if ($_ -eq $null) {
                    $null
                } else {
                    $sortedNonNulls[$sortedIndex++]
                }
            }

            return ,$finalList
        }

        # If we get here, we do *not* sort. Return original order.
        return $normalizedList
    }

    # Step 4: Sort non-null values (the built-in way for scalar comparables)
    $sortedNonNulls = $nonNullValues | Sort-Object

    # Step 5: Reinsert `$null`s in original positions
    $sortedIndex = 0
    $finalList = $normalizedList | ForEach-Object {
        if ($_ -eq $null) {
            $null
        }
        else {
            $sortedNonNulls[$sortedIndex++]
        }
    }

    return ,$finalList
}

