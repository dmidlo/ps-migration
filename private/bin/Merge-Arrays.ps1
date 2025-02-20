function Merge-Arrays {
    param(
        [Parameter(Mandatory)] [Array[]]$Arrays  # Accepts multiple arrays
    )

    $hashSet = @{}
    $mergedList = New-Object System.Collections.Generic.List[PSObject]

    foreach ($array in $Arrays) {
        foreach ($item in $array) {
            $hash = Get-DataHash -DataObject $item
            if (-not $hashSet.ContainsKey($hash)) {
                $hashSet[$hash] = $true
                $mergedList.Add($item)
            }
        }
    }

    return $mergedList
}
