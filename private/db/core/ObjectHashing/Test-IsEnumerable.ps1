function Test-IsEnumerable {
    <#
    .SYNOPSIS
        Determines whether an object is an enumerable collection, excluding strings.

    .DESCRIPTION
        - Returns `$true` if the input object implements `IEnumerable` and is **not** a string.

    .PARAMETER Value
        The object to evaluate.

    .OUTPUTS
        [bool] - `$true` if the object is enumerable, otherwise `$false`.
    #> 
    param (
        [Parameter(Mandatory)]
        [AllowNull()]
        [object]$Value
    )

    return ($Value -is [System.Collections.IEnumerable]) -and ($Value -isnot [string]) -and ($Value -isnot [System.__ComObject])
}